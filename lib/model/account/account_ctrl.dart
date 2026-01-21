import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:reef_chain_flutter/reef_api.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/utils/constants.dart';

import 'account_model.dart';

class AccountCtrl {
  final AccountModel _accountModel;

  // TODO check/make these props are private in other Ctrl classes
  final StorageService _storage;
  final ReefChainApi _reefChainApi;

  // ⬇️ track subscriptions so we can dispose safely
  StreamSubscription? _selectedAddrSub;
  StreamSubscription? _availableAccsSub;

  AccountCtrl(this._storage, this._accountModel, this._reefChainApi) {
    _initJsObservables(_storage);
    _initSavedDeviceAccountAddress(_storage);
  }

  // ─────────────────────────────────────────────────────────────
  // Exponential-backoff listener (dynamic-friendly)
  StreamSubscription _listenWithRetryDynamic({
    required Stream stream,
    required String name,
    required void Function(dynamic data) onData,
    Duration initialDelay = const Duration(milliseconds: 500),
    Duration maxDelay = const Duration(seconds: 8),
  }) {
    int attempt = 0;
    late StreamSubscription sub;

    Duration _nextDelay() {
      attempt++;
      int ms = initialDelay.inMilliseconds * (1 << (attempt - 1));
      if (ms > maxDelay.inMilliseconds) ms = maxDelay.inMilliseconds;
      return Duration(milliseconds: ms);
    }

    void _subscribe() {
      sub = stream.listen(
        (data) {
          attempt = 0; // reset on success
          try {
            onData(data);
          } catch (e, st) {
            debugPrint('[$name] onData EXCEPTION: $e\n$st');
            // TODO: optionally raise a UI flag via _accountModel
          }
        },
        onError: (e, st) {
          debugPrint('[$name] ERROR: $e\n$st');
          final delay = _nextDelay();
          debugPrint('[$name] Retrying in ${delay.inMilliseconds}ms');
          // TODO: optionally raise a UI flag via _accountModel
          Future.delayed(delay, _subscribe);
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
  Future<List> getStorageAccountsList() async {
    var accounts = [];
    (await _storage.getAllAccounts())
        .forEach(((account) => {accounts.add(account.toJsonSkinny())}));
    return accounts;
  }

  Future getStorageAccount(String address) async {
    return await _storage.getAccount(address);
  }

  Future<void> setSelectedAddress(String address) {
    return _reefChainApi.reefState.accountApi.setSelectedAddress(address);
  }

  Future<String> generateAccount() async {
    return await _reefChainApi.reefState.accountApi.generateAccount();
  }

  Future<dynamic> restoreJson(
      Map<String, dynamic> file, String password) async {
    return await _reefChainApi.reefState.accountApi.restoreJson(file, password);
  }

  Future<String> formatBalance(String value, double price, int decimals) async {
    return await _reefChainApi.reefState.accountApi.formatBalance(
      value,
      price,
    );
  }

  Future<dynamic> listenBindActivity(String address) async {
    await _reefChainApi.reefState.accountApi.listenBindActivity(address);
  }

  Future<dynamic> exportAccountQr(String address, String password) async {
    return await _reefChainApi.reefState.accountApi
        .exportAccountQr(address, password);
  }

  Future<dynamic> changeAccountPassword(
      String address, String newPass, String oldPass) async {
    return await _reefChainApi.reefState.accountApi
        .changeAccountPassword(address, newPass, oldPass);
  }

  Future<dynamic> accountsCreateSuri(String mnemonic, String password) async {
    return await _reefChainApi.reefState.accountApi
        .accountsCreateSuri(mnemonic, password);
  }

  Future<bool> checkMnemonicValid(String mnemonic) async {
    return _reefChainApi.reefState.accountApi.checkMnemonicValid(mnemonic);
  }

  Future<dynamic> resolveEvmAddress(String nativeAddress) async {
    return _reefChainApi.reefState.accountApi.resolveEvmAddress(nativeAddress);
  }

  Future<String> accountFromMnemonic(String mnemonic) async {
    return _reefChainApi.reefState.accountApi.accountFromMnemonic(mnemonic);
  }

  Future saveAccount(StoredAccount account) async {
    await _storage.saveAccount(account);
    await updateAccounts();
    _initJsObservables(_storage);
    setSelectedAddress(account.address);
  }

  void deleteAccount(String address) async {
    var account = await _storage.getAccount(address);
    debugPrint('-------> $account');

    if (account != null) {
      await account.delete();
    }
    if (address == _accountModel.selectedAddress) {
      await _storage.getAllAccounts().then((accounts) {
        if (accounts.isNotEmpty) {
          setSelectedAddress(accounts[0].address);
        } else {
          setSelectedAddress(Constants.ZERO_ADDRESS);
        }
      });
      _accountModel.selectedAddress = null;
    }
    await updateAccounts();
  }

  Future<void> updateAccounts() async {
    var accounts = [];
    (await _storage.getAllAccounts())
        .forEach(((account) => {accounts.add(account.toJsonSkinny())}));

    return await _reefChainApi.reefState.accountApi.updateAccounts(accounts);
  }

  Future<dynamic> bindEvmAccount(String address) async {
    return await _reefChainApi.reefState.accountApi.bindEvmAccount(address);
  }

  Future<bool> isValidEvmAddress(String address) async {
    return await _reefChainApi.reefState.accountApi.isValidEvmAddress(address);
  }

  Future<bool> isValidSubstrateAddress(String address) async {
    return await _reefChainApi.reefState.accountApi
        .isValidSubstrateAddress(address);
  }

  Future<String?> resolveToNativeAddress(String evmAddress) async {
    return await _reefChainApi.reefState.accountApi
        .resolveToNativeAddress(evmAddress);
  }

  Future<String> sanitizeEvmAddress(String evmAddress) async {
    return await _reefChainApi.reefState.accountApi
        .sanitizeEvmAddress(evmAddress);
  }

  Future<bool> isEvmAddressExist(String address) async {
    var res = await this.resolveToNativeAddress(address);
    return res != null;
  }

  Stream get availableSignersStream =>
      _reefChainApi.reefState.accountApi.availableSignersStream();

  // ─────────────────────────────────────────────────────────────
  void _initJsObservables(StorageService storage) {
    // selected address stream (with retry)
    _selectedAddrSub = _listenWithRetryDynamic(
      stream: _reefChainApi.reefState.accountApi.selectedAddressStream,
      name: 'selectedAddressStream',
      onData: (address) async {
        final addr = (address == null) ? '' : address.toString();
        if (addr.isEmpty) return;
        print('SELECTED addr=$addr');
        await storage.setValue(StorageKey.selected_address.name, addr);
        _accountModel.setSelectedAddress(addr);
      },
    );

    // available accounts stream (with retry)
    _availableAccsSub = _listenWithRetryDynamic(
      stream: _reefChainApi.reefState.accountApi.availableAccounts(),
      name: 'availableAccounts()',
      onData: (accs) async {
        // ⬇️ your original parsing kept as-is (uses your project helpers)
        ParseListFn<StatusDataObject<ReefAccount>> parsableListFn =
            getParsableListFn(ReefAccount.fromJson);
        var accsListFdm = StatusDataObject.fromJsonList(accs, parsableListFn);

        print('GOT ACCOUNTS ${accsListFdm.hasStatus(StatusCode.completeData)} '
            '${accsListFdm.statusList[0].message} '
            'len = ${accsListFdm.data.length}');

        _setAccountIconsFromStorage(accsListFdm);
        _accountModel.setAccountsFDM(accsListFdm);
      },
    );
  }

  void _initSavedDeviceAccountAddress(StorageService storage) async {
    var savedAddress = await storage.getValue(StorageKey.selected_address.name);

    if (savedAddress != null) {
      // check if the saved address exists in the allAccounts list
      var allAccounts = await storage.getAllAccounts();
      for (var account in allAccounts) {
        if (account.address == savedAddress) {
          await setSelectedAddress(account.address);
          return; //return from here after saving the selected address
        }
      }

      //if the saved address is not found then set first address as saved
      if (allAccounts.length > 0) {
        await setSelectedAddress(allAccounts[0].address);
      }
    }
  }

  Future<dynamic> toReefEVMAddressWithNotificationString(
      String evmAddress) async {
    return await _reefChainApi.reefState.accountApi
        .toReefEVMAddressWithNotificationString(evmAddress);
  }

  toReefEVMAddressNoNotificationString(String evmAddress) async {
    return await _reefChainApi.reefState.accountApi
        .toReefEVMAddressWithNotificationString(evmAddress);
  }

  void _setAccountIconsFromStorage(
      StatusDataObject<List<StatusDataObject<ReefAccount>>> accsListFdm) async {
    var accIcons = [];

    (await _storage.getAllAccounts()).forEach(((account) {
      accIcons.add({"address": account.address, "svg": account.svg});
    }));

    accsListFdm.data.forEach((accFdm) {
      var accIcon = accIcons.firstWhere(
        (accIcon) => accIcon['address'] == accFdm.data.address,
        orElse: () => null,
      );
      accFdm.data.iconSVG = accIcon?['svg'];
    });
  }

  // Call when disposing controller/service
  void dispose() {
    _selectedAddrSub?.cancel();
    _availableAccsSub?.cancel();
  }
}
