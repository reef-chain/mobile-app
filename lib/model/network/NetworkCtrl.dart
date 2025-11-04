import 'package:flutter/cupertino.dart';
import 'package:reef_chain_flutter/network/ws-conn-state.dart';
import 'package:reef_chain_flutter/reef_api.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/network/network_model.dart';
import 'package:reef_mobile_app/service/StorageService.dart';
import '../../components/modals/alert_modal.dart';

enum Network { mainnet, testnet }


class NetworkCtrl {
  final StorageService storage;
  final ReefChainApi reefChainApi;
  final NetworkModel networkModel;

  NetworkCtrl(this.storage, this.networkModel, this.reefChainApi) {
    reefChainApi.reefState.networkApi.selectedNetwork$.listen((network) async {
      debugPrint("selected network === $network");
      networkModel.setSelectedNetworkSwitching(false);

      final incomingName = (network != null && network['name'] != null)
          ? network['name'].toString()
          : null;

      if (incomingName != null) {
        // If tx-lock active and incoming change differs → revert
        if (_txLock.value &&
            _lockedNetworkName.isNotEmpty &&
            incomingName != _lockedNetworkName) {
          _revertToLockedNetwork(incomingName);
          return; // don't persist the unwanted network when locked
        }

        await storage.setValue(StorageKey.network.name, incomingName);
        networkModel.setSelectedNetworkName(incomingName);
      }
    }, onError: (e, st) {
      // Either remove the dollar or escape it:
      // debugPrint('selectedNetwork stream error: $e');
      debugPrint('selectedNetwork\$ stream error: $e');
    });
  }

  // -------------------- Network Lock (TX-safety) --------------------
  final ValueNotifier<bool> _txLock = ValueNotifier<bool>(false);
  String _lockedNetworkName = '';
  bool _reverting = false; // loop guard during auto-revert

  String get current =>
      (networkModel.selectedNetworkName ?? '').toString();

  bool get isLocked => _txLock.value;
  String get lockedNetwork => _lockedNetworkName;

  bool tryLockForTx() {
    if (_txLock.value) return false;
    _lockedNetworkName = current;
    _txLock.value = true;
    debugPrint('🔒 Network locked for TX on: $_lockedNetworkName');
    return true;
  }

  void releaseLock() {
    debugPrint('🔓 Network lock released (was: $_lockedNetworkName)');
    _lockedNetworkName = '';
    _txLock.value = false;
  }

  bool validateLockedOrWarn() {
    if (!_txLock.value) return true;
    final now = current;
    final ok = now == _lockedNetworkName;
    if (!ok) {
      _warn(
        title: "Network changed",
        message:
        "Selected network switched from $_lockedNetworkName to $now during transaction. The transaction was cancelled for safety.",
      );
    }
    return ok;
  }

  // -------------------- Public API --------------------
  Future<void> setNetwork(Network network) async {
    debugPrint("setNetwork called: ${network.name}");
    // If locked, block user-initiated switch to a different network
    if (_txLock.value &&
        _lockedNetworkName.isNotEmpty &&
        network.name != _lockedNetworkName) {
      _warn(
        title: "Switch blocked",
        message:
        "A transaction is in progress on $_lockedNetworkName. Network switch to ${network.name} is blocked until it completes.",
      );
      return;
    }

    networkModel.setSelectedNetworkSwitching(true);
    reefChainApi.reefState.networkApi.setNetwork(network.name);
  }

  Stream<bool?> getIndexerConnected() =>
      reefChainApi.getIndexerConnected().map((event) => event == true);

  Stream<WsConnState?> getProviderConnLogs() =>
      reefChainApi.getProviderConnLogs().handleError((value) {
        debugPrint('getProviderConnLogs error --------------> $value');
      });

  Future<void> reconnectProvider() async {
    reefChainApi.reconnectProvider();
  }

  // -------------------- Internals --------------------
  void _revertToLockedNetwork(String incoming) {
    if (_reverting) return; // prevent loop
    if (_lockedNetworkName.isEmpty) return;

    _reverting = true;
    debugPrint(
        '⛔ Incoming network "$incoming" ignored during lock. Reverting to "$_lockedNetworkName"...');

    // Re-issue setNetwork at API level to restore locked network
    // (don’t flip switching flag here; keep UX subtle)
    reefChainApi.reefState.networkApi.setNetwork(_lockedNetworkName);

    // Tell user once
    _warn(
      title: "Network switch blocked",
      message:
      "A transaction is in progress on $_lockedNetworkName. Please wait before switching network.",
    );

    // small delay to avoid rapid oscillation, then clear guard
    Future<void>.delayed(const Duration(milliseconds: 150)).then((_) {
      _reverting = false;
    });
  }

  void _warn({required String title, required String message}) {

    try {
      showAlertModal(title, [message]); // if available in your codebase
    } catch (_) {
      debugPrint('⚠️ $title: $message');
    }
  }
}
