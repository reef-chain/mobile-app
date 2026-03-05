import 'dart:async';
import 'dart:convert';

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/model/auth_url/auth_url.dart';
import 'package:reef_mobile_app/model/metadata/metadata.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // NEW — secure password store
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  StorageService() {
    _initAsync();
  }

  // -------------------------
  // SECURE PASSWORD MANAGEMENT
  // -------------------------

  /// Save password SECURELY (bcrypt hash)
  Future<void> savePasswordSecure(String password) async {
    final hash = BCrypt.hashpw(password, BCrypt.gensalt());

    // Save hash in secure storage
    await _secureStorage.write(key: 'password_hash', value: hash);

    // Remove old insecure entry from Hive
    await deleteValue("password");
  }

  /// Check if password is set
  Future<bool> hasPasswordSet() async {
    final stored = await _secureStorage.read(key: 'password_hash');
    return stored != null && stored.isNotEmpty;
  }

  /// Verify password using bcrypt
  Future<bool> verifyPasswordSecure(String enteredPassword) async {
    final storedHash = await _secureStorage.read(key: 'password_hash');
    if (storedHash == null) return false;

    return BCrypt.checkpw(enteredPassword, storedHash);
  }

  /// Delete stored password (for reset)
  Future<void> deletePasswordSecure() async {
    await _secureStorage.delete(key: 'password_hash');
  }

  // -----------------------------
  // ORIGINAL STORAGE FUNCTIONS
  // -----------------------------

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

  // -----------------------
  // Initialization
  // -----------------------

  Future<void> _initAsync() async {
    try {
      // FIXED: Removed the unnecessary _checkPermission() block.
      // `getApplicationDocumentsDirectory()` is an internal app sandbox
      // and does NOT require any external storage permissions on Android.
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

    // Encrypted Accounts Box
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

  // FIXED: Simply return true.
  // We keep the function signature intact so other files don't break if they call it,
  // but it safely bypasses the Android 13+ crashing behavior.
  Future<bool> _checkPermission() async {
    return true;
  }

  void _completeAllWithError(Object e, [StackTrace? st]) {
    if (!mainBox.isCompleted)
      mainBox.completeError(e, st ?? StackTrace.current);
    if (!metadataBox.isCompleted)
      metadataBox.completeError(e, st ?? StackTrace.current);
    if (!authUrlsBox.isCompleted)
      authUrlsBox.completeError(e, st ?? StackTrace.current);
    if (!accountsBox.isCompleted)
      accountsBox.completeError(e, st ?? StackTrace.current);
    if (!jwtsBox.isCompleted)
      jwtsBox.completeError(e, st ?? StackTrace.current);
  }

  Future<void> openStoragePermissionSettings() async {
    await openAppSettings();
  }
}
