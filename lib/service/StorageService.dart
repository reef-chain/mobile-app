import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/model/auth_url/auth_url.dart';
import 'package:reef_mobile_app/model/metadata/metadata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';


/// Thrown when storage permission is not granted and Hive cannot be initialized.
class StoragePermissionException implements Exception {
  final String message;
  StoragePermissionException([this.message = 'Storage permission not granted']);
  @override
  String toString() => 'StoragePermissionException: $message';
}

class StorageService {
  final Completer<Box<dynamic>> mainBox = Completer();
  final Completer<Box<dynamic>> metadataBox = Completer();
  final Completer<Box<dynamic>> authUrlsBox = Completer();
  final Completer<Box<dynamic>> accountsBox = Completer();
  final Completer<Box<dynamic>> jwtsBox = Completer();

  StorageService() {
    _initAsync();
  }

  Future<dynamic> getValue(String key) =>
      mainBox.future.then((Box<dynamic> box) => box.get(key));

  Future<dynamic> setValue(String key, dynamic value) =>
      mainBox.future.then((Box<dynamic> box) => box.put(key, value));

  Future<dynamic> deleteValue(String key) =>
      mainBox.future.then((Box<dynamic> box) => box.delete(key));

  Future<dynamic> getMetadata(String genesisHash) =>
      metadataBox.future.then((Box<dynamic> box) => box.get(genesisHash));

  Future<List<Metadata>> getAllMetadatas() => metadataBox.future
      .then((Box<dynamic> box) => box.values.toList().cast<Metadata>());

  Future<dynamic> saveMetadata(Metadata metadata) => metadataBox.future
      .then((Box<dynamic> box) => box.put(metadata.genesisHash, metadata));

  Future<dynamic> deleteMetadata(String genesisHash) =>
      metadataBox.future.then((Box<dynamic> box) => box.delete(genesisHash));

  Future<dynamic> getAuthUrl(String url) =>
      authUrlsBox.future.then((Box<dynamic> box) => box.get(url));

  Future<List<AuthUrl>> getAllAuthUrls() => authUrlsBox.future
      .then((Box<dynamic> box) => box.values.toList().cast<AuthUrl>());

  Future<dynamic> saveAuthUrl(AuthUrl authUrl) => authUrlsBox.future
      .then((Box<dynamic> box) => box.put(authUrl.url, authUrl));

  Future<dynamic> deleteAuthUrl(String url) =>
      authUrlsBox.future.then((Box<dynamic> box) => box.delete(url));

  Future<dynamic> getAccount(String address) =>
      accountsBox.future.then((Box<dynamic> box) => box.get(address));

  Future<List<StoredAccount>> getAllAccounts() => accountsBox.future
      .then((Box<dynamic> box) => box.values.toList().cast<StoredAccount>());

  Future<dynamic> saveAccount(StoredAccount account) => accountsBox.future
      .then((Box<dynamic> box) => box.put(account.address, account));

  Future<dynamic> deleteAccount(String address) =>
      accountsBox.future.then((Box<dynamic> box) => box.delete(address));

  Future<dynamic> getJwt(String address) =>
      jwtsBox.future.then((Box<dynamic> box) => box.get(address));

  Future<dynamic> saveJwt(String address, String jwt) =>
      jwtsBox.future.then((Box<dynamic> box) => box.put(address, jwt));

  Future<dynamic> deleteJwt(String address) =>
      jwtsBox.future.then((Box<dynamic> box) => box.delete(address));

  Future<void> _initAsync() async {
    try {
      final allowed = await _checkPermission();
      if (!allowed) {
        final e = StoragePermissionException();
        _completeAllWithError(e);
        return; // do not init Hive
      }

      await _initHive();
    } catch (e, st) {
      debugPrint('StorageService _initAsync error: $e\n$st');
      _completeAllWithError(e, st);
    }
  }

  Future<void> _initHive() async {
    final prefs = await SharedPreferences.getInstance();
    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/hive_store";
    Hive.init(path);

    // Register adapters once
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(StoredAccountAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(MetadataAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(AuthUrlAdapter());
    }

    // Open unencrypted boxes
    if (!mainBox.isCompleted) {
      mainBox.complete(Hive.openBox('ReefChainBox'));
    }
    if (!metadataBox.isCompleted) {
      metadataBox.complete(Hive.openBox('MetadataBox'));
    }
    if (!authUrlsBox.isCompleted) {
      authUrlsBox.complete(Hive.openBox('AuthUrlsBox'));
    }
    if (!jwtsBox.isCompleted) {
      jwtsBox.complete(Hive.openBox('JwtsBox'));
    }

    // Encrypted box for accounts
    const secureStorage = FlutterSecureStorage();
    if (prefs.getBool('first_run') ?? true) {
      await secureStorage.deleteAll();
      prefs.setBool('first_run', false);
    }

    var key = await secureStorage.read(key: 'encryptionKey');
    if (key == null) {
      final generated = Hive.generateSecureKey();
      await secureStorage.write(
        key: 'encryptionKey',
        value: base64UrlEncode(generated),
      );
      key = await secureStorage.read(key: 'encryptionKey');
    }

    final encryptionKey = base64Url.decode(key!);

    if (!accountsBox.isCompleted) {
      accountsBox.complete(
        Hive.openBox(
          'AccountsBox',
          encryptionCipher: HiveAesCipher(encryptionKey),
        ),
      );
    }
  }

  Future<bool> _checkPermission() async {
    // NOTE: If you store in app documents dir, on modern Android this may not require
    // runtime storage permission. If you still rely on it, keep this.
    final status = await Permission.storage.status;
    debugPrint('PERMISSION STORAGE=$status');

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      debugPrint("PERMISSION PERMANENTLY DENIED");
      return false;
    }

    final result = await Permission.storage.request();

    if (result.isGranted) {
      debugPrint("PERMISSION GRANTED");
      return true;
    }

    if (result.isPermanentlyDenied) {
      debugPrint("PERMISSION PERMANENTLY DENIED (after request)");
      return false;
    }

    debugPrint("PERMISSION DENIED");
    return false;
  }

  void _completeAllWithError(Object e, [StackTrace? st]) {
    if (!mainBox.isCompleted) mainBox.completeError(e, st ?? StackTrace.current);
    if (!metadataBox.isCompleted) metadataBox.completeError(e, st ?? StackTrace.current);
    if (!authUrlsBox.isCompleted) authUrlsBox.completeError(e, st ?? StackTrace.current);
    if (!accountsBox.isCompleted) accountsBox.completeError(e, st ?? StackTrace.current);
    if (!jwtsBox.isCompleted) jwtsBox.completeError(e, st ?? StackTrace.current);
  }

  /// Optional helper: call from UI to open app settings for permanently denied case
  Future<void> openStoragePermissionSettings() async {
    await openAppSettings();
  }
}
