import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:reef_chain_flutter/js_api_service.dart';
import 'package:reef_mobile_app/components/modals/auth_url_aproval_modal.dart';
import 'package:reef_mobile_app/components/modals/metadata_aproval_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/auth_url/auth_url.dart';
import 'package:reef_mobile_app/model/metadata/metadata.dart';

enum AuthUrlStatus {
  authorized,
  notAuthorized,
  notFound,
}

class DAppRequestService {
  // Track active subscriptions to prevent memory leaks
  final Map<String, StreamSubscription> _activeSubscriptions = {};

  DAppRequestService();

  void handleDAppMsgRequest(JsApiMessage message,
      void Function(String reqId, dynamic value) responseFn) async {
    if (message.msgType == 'pub(phishing.redirectIfDenied)') {
      responseFn(message.reqId, _redirectIfPhishing(message.value['url']));
    }

    if (message.msgType != 'pub(authorize.tab)' &&
        await _getAuthUrlStatus(message.url) != AuthUrlStatus.authorized) {
      print('Domain not authorized= ${message.url} - ${message.msgType}');
      return;
    }

    switch (message.msgType) {
      case 'pub(bytes.sign)':
        try {
          var signature = await ReefAppState.instance.signingCtrl
              .signRaw(message.value['address'], message.value['data'])
              .timeout(const Duration(seconds: 30));
          responseFn(message.reqId, '${jsonEncode(signature)}');
        } catch (e) {
          print('ERROR signing raw message: $e');
          responseFn(message.reqId, jsonEncode({'error': 'Signing timeout or network error'}));
        }
        break;
      case 'pub(extrinsic.sign)':
        try {
          var signature = await ReefAppState.instance.signingCtrl
              .signPayload(message.value['address'], message.value)
              .timeout(const Duration(seconds: 30));
          responseFn(message.reqId, '${jsonEncode(signature)}');
        } catch (e) {
          print('ERROR signing payload: $e');
          responseFn(message.reqId, jsonEncode({'error': 'Signing timeout or network error'}));
        }
        break;
      case 'pub(authorize.tab)':
        responseFn(message.reqId,
            await _authorizeDapp(message.value['origin'], message.url));
        break;
      case 'pub(accounts.list)':
        var accounts =
            await ReefAppState.instance.accountCtrl.getStorageAccountsList();
        responseFn(message.reqId, jsonEncode(accounts));
        break;
      case 'pub(accounts.subscribe)':
        // Handle subscription with proper cleanup to prevent memory leaks
        final subscriptionKey = message.url ?? 'default';

        // Cancel previous subscription for this DApp if exists
        await _activeSubscriptions[subscriptionKey]?.cancel();

        // Create new subscription and store it
        _activeSubscriptions[subscriptionKey] =
          ReefAppState.instance.accountCtrl
            .availableSignersStream
            .listen((event) {
              // DApp accounts update notification
              // In a full implementation, this would send updates back to the DApp
              if (kDebugMode) {
                print('accounts.subscribe event for $subscriptionKey: $event');
              }
            });

        responseFn(message.reqId, 'true');
        break;

      case 'pub(accounts.unsubscribe)':
        // Allow DApps to explicitly unsubscribe
        final subscriptionKey = message.url ?? 'default';
        await _activeSubscriptions[subscriptionKey]?.cancel();
        _activeSubscriptions.remove(subscriptionKey);
        responseFn(message.reqId, 'true');
        break;
      case 'pub(metadata.list)':
        responseFn(message.reqId, await _metadataList());
        break;
      case 'pub(metadata.provide)':
        responseFn(message.reqId, await _metadataProvide(message.value));
        break;
    }
  }

  /// Dispose of all active subscriptions to prevent memory leaks
  /// Call this when the service is being destroyed
  Future<void> dispose() async {
    for (var subscription in _activeSubscriptions.values) {
      await subscription.cancel();
    }
    _activeSubscriptions.clear();
  }

  // === PHISHING PROTECTION ===

  /// Trusted domains whitelist - verified DApps that are safe
  static const Set<String> _trustedDomains = {
    'app.uniswap.org',
    'app.reef.io',
    'reefscan.com',
    'reefscan.info',
    'squid.subsquid.io',
    'app.squid.subsquid.io',
    'console.reefscan.com',
  };

  /// Blacklist of known phishing domains
  static const Set<String> _blacklistedDomains = {
    'fake-uniswap.com',
    'reef-airdrop.xyz',
    'free-reef.com',
    'claim-reef.com',
  };

  /// Check if URL is a phishing attempt
  /// Returns true if the URL should be BLOCKED
  bool _redirectIfPhishing(String url) {
    try {
      final uri = Uri.parse(url);
      final domain = uri.host.toLowerCase();

      // 1. Blacklist check - immediate block
      if (_blacklistedDomains.contains(domain)) {
        if (kDebugMode) {
          print('⚠️ PHISHING DETECTED: $domain is blacklisted!');
        }
        return true;
      }

      // 2. Suspicious pattern detection
      if (_isSuspiciousDomain(domain)) {
        if (kDebugMode) {
          print('⚠️ SUSPICIOUS DOMAIN: $domain looks like phishing');
        }
        return true;
      }

      // 3. Log unverified domains (don't block, but warn user via UI)
      if (!_trustedDomains.contains(domain)) {
        if (kDebugMode) {
          print('⚠️ UNVERIFIED DOMAIN: $domain - user should be warned');
        }
      }

      return false;
    } catch (e) {
      // If URL parsing fails, block for safety
      if (kDebugMode) {
        print('Error parsing URL for phishing check: $e');
      }
      return true;
    }
  }

  /// Detect typosquatting and suspicious domain patterns
  bool _isSuspiciousDomain(String domain) {
    // Common phishing patterns
    final suspiciousPatterns = [
      'reef-airdrop',
      'reef-claim',
      'reef-free',
      'free-reef',
      'metamask-',
      'meta-mask',
      'unisvvap', // typo: vv instead of w
      'unisawp', // swapped letters
      'pancake-swap', // incorrect separator
    ];

    for (var pattern in suspiciousPatterns) {
      if (domain.contains(pattern)) {
        return true;
      }
    }

    // Excessive hyphens (common in phishing)
    if (domain.split('-').length > 3) {
      return true;
    }

    // Numbers in domain (if not whitelisted)
    if (domain.contains(RegExp(r'\d')) && !_trustedDomains.contains(domain)) {
      return true;
    }

    return false;
  }

  Future<AuthUrlStatus> _getAuthUrlStatus(String? url) async {
    if (url == null) return AuthUrlStatus.notFound;

    var authUrl = await ReefAppState.instance.storage.getAuthUrl(url);
    if (authUrl == null) return AuthUrlStatus.notFound;

    return authUrl.isAllowed
        ? AuthUrlStatus.authorized
        : AuthUrlStatus.notAuthorized;
  }

  Future<bool> _authorizeDapp(String dAppName, String? url) async {
    switch (await _getAuthUrlStatus(url)) {
      case AuthUrlStatus.authorized:
        return true;
      case AuthUrlStatus.notFound:
        var response =
            await showAuthUrlAprovalModal(origin: dAppName, url: url);
        await ReefAppState.instance.storage
            .saveAuthUrl(AuthUrl(url!, response == true));
        return response == true;
      case AuthUrlStatus.notAuthorized:
      default:
        return false;
    }
  }

  Future<bool> _metadataProvide(Map metadataMap) async {
    Metadata metadata = Metadata.fromMap(metadataMap);
    var chain =
        await ReefAppState.instance.storage.getMetadata(metadata.genesisHash);
    var currVersion = chain != null ? chain.specVersion.toString() : 0;
    var response = await showMetadataAprovalModal(
      metadata: metadata,
      currVersion: currVersion,
    );
    if (response == true) {
      await ReefAppState.instance.storage.saveMetadata(metadata);
      return true;
    }
    return false;
  }

  Future<String> _metadataList() async {
    var metadatas = await ReefAppState.instance.storage.getAllMetadatas();
    var injectedMetadataKnown = [];
    for (var metadata in metadatas) {
      injectedMetadataKnown.add(metadata.toInjectedMetadataKnownJson());
    }
    return jsonEncode(injectedMetadataKnown);
  }
}
