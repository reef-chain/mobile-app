import 'package:flutter/foundation.dart';
import 'package:reef_chain_flutter/js_api_service.dart';
import 'package:reef_chain_flutter/reef_api.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/model/tokens/TokenActivity.dart';
import 'package:reef_mobile_app/model/tokens/TokenNFT.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';

import 'token_model.dart';

import 'dart:async';



class TokenCtrl {
  final ReefChainApi reefChainApi;

  // Keep refs so we can cancel on dispose()
  StreamSubscription? _selTokenPricesSub;
  StreamSubscription? _selNftsSub;
  StreamSubscription? _reefPriceSub;
  StreamSubscription? _txHistorySub;

  TokenCtrl(TokenModel tokenModel, this.reefChainApi) {
    // 1) Selected ERC20 prices/status
    _selTokenPricesSub = _listenWithRetry<dynamic>(
      stream: reefChainApi.reefState.tokenApi.selectedTokenPrices_status$,
      name: 'selectedTokenPrices_status\$',
      onData: (tokens) {
        // ⬇️ your original logic kept as-is
        ParseListFn<StatusDataObject<TokenWithAmount>> parsableListFn =
        getParsableListFn(TokenWithAmount.fromJson);
        var tokensListFdm = StatusDataObject.fromJsonList(tokens, parsableListFn);

        if (kDebugMode) {
          try {
            print('GOT TOKENS ${tokensListFdm.data.length}');
          } catch (e) {
            print('Error getting tokens');
          }
        }
        tokenModel.setSelectedErc20s(tokensListFdm);
      },
    );

    // 2) Selected NFTs
    _selNftsSub = _listenWithRetry<dynamic>(
      stream: reefChainApi.reefState.tokenApi.selectedNFTs_status$,
      name: 'selectedNFTs_status\$',
      onData: (tokens) {
        // ⬇️ your original logic kept as-is
        ParseListFn<StatusDataObject<TokenNFT>> parsableListFn =
        getParsableListFn(TokenNFT.fromJson);
        var tokensListFdm = StatusDataObject.fromJsonList(tokens, parsableListFn);

        if (kDebugMode) {
          print('NFTs=${tokensListFdm.data.length}');
        }
        tokenModel.setSelectedNFTs(tokensListFdm);
      },
    );

    // 3) Reef price
    _reefPriceSub = _listenWithRetry<dynamic>(
      stream: reefChainApi.reefState.tokenApi.reefPrice$,
      name: 'reefPrice\$',
      onData: (value) {
        // ⬇️ your original logic kept as-is
        var fdm = StatusDataObject.fromJson(value, (v) => v);
        if (fdm != null && fdm.hasStatus(StatusCode.completeData)) {
          if (fdm.data is int) {
            fdm.data = (fdm.data as int).toDouble();
          }
          tokenModel.setReefPrice(fdm.data);
        }
      },
    );

    // 4) Selected transaction history
    _txHistorySub = _listenWithRetry<dynamic>(
      stream: reefChainApi.reefState.tokenApi.selectedTransactionHistory$,
      name: 'selectedTransactionHistory\$',
      onData: (items) {
        // ⬇️ your original logic kept as-is
        parsableFn(accList) =>
            List<TokenActivity>.from(accList.map(TokenActivity.fromJson));
        var tokensListFdm = StatusDataObject.fromJsonList(items, parsableFn);

        tokenModel.setTxHistory(tokensListFdm);
        if (kDebugMode) {
          print('GOT HISTORY=${tokensListFdm.data.length}');
        }
      },
    );
  }

  /// Call this from your lifecycle (e.g., controller/service dispose)
  void dispose() {
    _selTokenPricesSub?.cancel();
    _selNftsSub?.cancel();
    _reefPriceSub?.cancel();
    _txHistorySub?.cancel();
  }

  // ─────────────────────────────────────────────────────────────
  // Exponential-backoff listener for robust stream handling
  // Adds: onError, onDone, logs, retries.
  StreamSubscription<T> _listenWithRetry<T>({
    required Stream<T> stream,
    required String name,
    required void Function(T data) onData,
    Duration initialDelay = const Duration(milliseconds: 500),
    Duration maxDelay = const Duration(seconds: 8),
  }) {
    int attempt = 0;
    late StreamSubscription<T> sub;

    Duration _nextDelay() {
      attempt++;
      int ms = initialDelay.inMilliseconds * (1 << (attempt - 1));
      if (ms > maxDelay.inMilliseconds) ms = maxDelay.inMilliseconds;
      return Duration(milliseconds: ms);
    }

    void _subscribe() {
      sub = stream.listen(
            (data) {
          // success ⇒ reset attempts
          attempt = 0;
          try {
            onData(data);
          } catch (e, st) {
            debugPrint('[$name] onData EXCEPTION: $e\n$st');
          }
        },
        onError: (e, st) {
          debugPrint('[$name] ERROR: $e\n$st');
          final delay = _nextDelay();
          debugPrint('[$name] Retrying in ${delay.inMilliseconds}ms');
          Future.delayed(delay, _subscribe);
          // TODO: surface UI indicator (e.g., via a model flag) if desired.
        },
        onDone: () {
          debugPrint('[$name] DONE. Re-subscribing…');
          Future.delayed(_nextDelay(), _subscribe);
        },
        cancelOnError: true,
      );
    }

    _subscribe();
    return sub;
  }

  // ─────────────────────────────────────────────────────────────
  // Your existing methods unchanged
  Future<dynamic> findToken(String address) async {
    return reefChainApi.reefState.tokenApi.findToken(address);
  }

  Future<dynamic> getTxInfo(String timestamp) async {
    return reefChainApi.reefState.tokenApi.getTxInfo(timestamp);
  }

  Future<dynamic> getPools(dynamic offset) async {
    return reefChainApi.reefState.tokenApi.getPools(offset);
  }

  Future<dynamic> getPoolPairs(String tokenAddress) async {
    return reefChainApi.reefState.tokenApi.getPoolPairs(tokenAddress);
  }

  Future<dynamic> getTokenInfo(String tokenAddress) async {
    return reefChainApi.reefState.tokenApi.getTokenInfo(tokenAddress);
  }

  void reload(bool force) async {
    var isProvConn =
    await ReefAppState.instance.networkCtrl.getProviderConnLogs().first;
    if (force || isProvConn == null || !isProvConn.isConnected) {
      if (kDebugMode) {
        print('RELOADING TOKENS');
      }
      reefChainApi.reefState.tokenApi.reloadTokens();
    }
  }

  Future<dynamic> getNftInfo(String nftId, String ownerAddress) async {
    return reefChainApi.reefState.tokenApi.getNftInfo(nftId, ownerAddress);
  }
}
