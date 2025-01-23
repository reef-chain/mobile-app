import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:reef_chain_flutter/js_api_service.dart';
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

  AccountCtrl(this._storage, this._accountModel,this._reefChainApi) {
    _initJsObservables(_storage);
    _initSavedDeviceAccountAddress(_storage);
  }

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

  Future<String> formatBalance(
      String value, double price) async { 
    return await _reefChainApi.reefState.accountApi.formatBalance(value, price);
  }

Future<dynamic> listenBindActivity(String address) async {
  await _reefChainApi.reefState.accountApi.listenBindActivity(address);
}


  Future<dynamic> exportAccountQr(String address, String password) async {
    return await _reefChainApi.reefState.accountApi.exportAccountQr(address,password);
  }

  Future<dynamic> changeAccountPassword(
      String address, String newPass, String oldPass) async {
    return await _reefChainApi.reefState.accountApi.changeAccountPassword(address, newPass, oldPass);
  }

  Future<dynamic> accountsCreateSuri(String mnemonic, String password) async {
    return await _reefChainApi.reefState.accountApi.accountsCreateSuri(mnemonic, password);
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
    return await _reefChainApi.reefState.accountApi.isValidSubstrateAddress(address);
  }

  Future<String?> resolveToNativeAddress(String evmAddress) async {
    return await _reefChainApi.reefState.accountApi.resolveToNativeAddress(evmAddress);
  }

  Future<String> sanitizeEvmAddress(String evmAddress) async{
    return await _reefChainApi.reefState.accountApi.sanitizeEvmAddress(evmAddress);
  }

  Future<bool> isEvmAddressExist(String address) async {
    var res = await this.resolveToNativeAddress(address);
    return res != null;
  }

Stream get availableSignersStream => _reefChainApi.reefState.accountApi.availableSignersStream();

  void _initJsObservables( StorageService storage) {
    _reefChainApi.reefState.accountApi.selectedAddressStream
        .listen((address) async {
      if (address == null || address == '') {
        return;
      }
      print('SELECTED addr=${address}');
      await storage.setValue(StorageKey.selected_address.name, address);
      _accountModel.setSelectedAddress(address);
    });

      _reefChainApi.reefState.accountApi.availableAccounts().listen((accs) async {
      ParseListFn<StatusDataObject<ReefAccount>> parsableListFn =
          getParsableListFn(ReefAccount.fromJson);
      var accsListFdm = StatusDataObject.fromJsonList(accs, parsableListFn);

      print(
          'GOT ACCOUNTS ${accsListFdm.hasStatus(StatusCode.completeData)} ${accsListFdm.statusList[0].message} len =${accsListFdm.data.length}');

      _setAccountIconsFromStorage(accsListFdm);

      _accountModel.setAccountsFDM(accsListFdm);
    });
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

  Future<dynamic> toReefEVMAddressWithNotificationString(String evmAddress) async {
    return await _reefChainApi.reefState.accountApi.toReefEVMAddressWithNotificationString(evmAddress);
  }

  toReefEVMAddressNoNotificationString(String evmAddress) async {
     return await _reefChainApi.reefState.accountApi.toReefEVMAddressWithNotificationString(evmAddress);
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
          orElse: () => null);
      accFdm.data.iconSVG = accIcon?['svg'];
    });
  }
}
