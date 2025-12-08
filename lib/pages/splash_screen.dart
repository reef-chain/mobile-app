import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:local_auth/local_auth.dart';
import 'package:reef_chain_flutter/reef_api.dart';
import 'package:reef_mobile_app/components/introduction_page/hero_video.dart';
import 'package:reef_mobile_app/pages/introduction_page.dart';
import 'package:reef_mobile_app/service/WalletConnectService.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/ReefAppState.dart';
import '../service/StorageService.dart';

typedef WidgetCallback = Widget Function();

final navigatorKey = GlobalKey<NavigatorState>();



// Timing
const int kSplashGifDurationMs = 3830;

// Biometrics
const int kBioMaxAttemptsConst = 3;

// Padding / Sizes
const double kSplashAuthPadding = 24.0;
const double kSplashInputPaddingV = 14.0;
const double kSplashInputPaddingH = 12.0;

const double kSplashGifSize = 128.0;
const double kSplashGap16 = 16.0;
const double kSplashGap8 = 8.0;
const double kSplashGap12 = 12.0;
const double kSplashGap36 = 36.0;
const double kSplashGap4 = 4.0;

// UI values
const double kSplashPasswordTitleSize = 14.0;
const double kSplashPasswordFontSize = 16.0;

const double kSplashLoadingIconSize = 12.0;
const double kSplashErrorIconSize = 16.0;
const double kSplashFingerprintSize = 36.0;

// Border / Radius
const double kSplashBorderRadius = 12.0;
const double kSplashBtnRadius = 40.0;
const double kSplashInputBorderWidth = 1.0;

// String Keys
const String kKeyFirstLaunch = "firstLaunch";
const String kKeyLanguageCode = "languageCode";
const String kKeyBiometricAuth = "biometricAuth";


// =============================================================
//                        SplashApp
// =============================================================
class SplashApp extends StatefulWidget {
  final WidgetCallback displayOnInit;
  final Widget heroVideo = const HeroVideo();
  final ReefChainApi reefChainApi = ReefChainApi();

  SplashApp({
    required Key key,
    required this.displayOnInit,
  }) : super(key: key);

  @override
  _SplashAppState createState() => _SplashAppState();

  static void setLocale(BuildContext context, String newLocale) {
    final state = context.findAncestorStateOfType<_SplashAppState>();
    if (state != null && state.mounted) {
      state.setLocale(newLocale);
    }
  }
}

class _SplashAppState extends State<SplashApp> {
  String _locale = ReefAppState.instance.model.locale.selectedLanguage;

  int _bioAttempts = 0;
  bool _bioLockedOut = false;

  bool _hasError = false;
  bool _requiresAuth = false;
  bool _isAuthenticated = false;
  bool _wrongPassword = false;
  bool _biometricsIsAvailable = false;
  bool? _isFirstLaunch;

  bool appReady = false;
  final TextEditingController _passwordController = TextEditingController();
  String password = "";

  static final LocalAuthentication localAuth = LocalAuthentication();
  Timer? _gifTimer;

  void setLocale(String locale) {
    if (!mounted) return;
    setState(() => _locale = locale);
  }

  /// Checks if biometric authentication is supported and enrolled
  Future<bool> _checkBiometricsSupport() async {
    try {
      final isDeviceSupported = await localAuth.isDeviceSupported();
      final isAvailable = await localAuth.canCheckBiometrics;
      final isEnrolled =
          (await localAuth.getAvailableBiometrics()).isNotEmpty;
      return isAvailable && isDeviceSupported && isEnrolled;
    } catch (_) {
      return false;
    }
  }

  /// Checks if user has password authentication enabled
  Future<bool> _checkRequiresPasswordAuth() async {
    return await ReefAppState.instance.storage.hasPasswordSet();
  }

  /// Gets saved language locale from storage
  Future<String> _getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kKeyLanguageCode) ?? 'en';
  }

  @override
  void initState() {
    super.initState();

    _getSavedLocale().then((value) {
      if (!mounted) return;
      setLocale(value);
    });

    _gifTimer = Timer(const Duration(milliseconds: kSplashGifDurationMs), () {});

    _bootstrap();

    _passwordController.addListener(() {
      if (!mounted) return;
      setState(() => password = _passwordController.text);
    });
  }

  Future<void> _bootstrap() async {
    try {
      await _initializeAsyncDependencies();
      if (!mounted) return;
      await _initAuthentication();
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _gifTimer?.cancel();
    _passwordController.dispose();
    super.dispose();
  }

  /// Checks if app is launched for the first time
  Future<bool> _checkIfFirstLaunch() async {
    final isFirstLaunch =
    await ReefAppState.instance.storage.getValue(kKeyFirstLaunch);
    return isFirstLaunch == null;
  }

  /// Initializes authentication flow on app start
  Future<void> _initAuthentication() async {
    try {
      final first = await _checkIfFirstLaunch();
      if (!mounted) return;
      setState(() => _isFirstLaunch = first);

      if (first || kDebugMode) {
        setState(() {
          _requiresAuth = false;
          _isAuthenticated = true;
        });
        return;
      }

      final supportsBio = await _checkBiometricsSupport();
      if (!mounted) return;

      if (supportsBio) {
        final hasUserEnabledBio =
        await ReefAppState.instance.storage.getValue(kKeyBiometricAuth);

        if (hasUserEnabledBio == true) {
          setState(() => _biometricsIsAvailable = true);
          await _authenticateWithBiometrics();
          return;
        }
      }

      final requiresPwd = await _checkRequiresPasswordAuth();
      if (!mounted) return;

      setState(() {
        _requiresAuth = requiresPwd;
        _isAuthenticated = !requiresPwd;
      });
    } catch (_) {
      setState(() => _hasError = true);
    }
  }

  /// Initializes async app dependencies
  Future<void> _initializeAsyncDependencies() async {
    try {
      final storageService = StorageService();
      final walletConnectService = WalletConnectService();

      await ReefAppState.instance.init(
        storageService,
        walletConnectService,
        widget.reefChainApi,
      );

      if (!mounted) return;
      setState(() => appReady = true);
    } catch (_) {
      setState(() => _hasError = true);
    }
  }


  /// Authenticates user using secure password
  Future<void> _authenticateWithPassword(String enteredPassword) async {
    final ok = await ReefAppState.instance.storage
        .verifyPasswordSecure(enteredPassword);

    if (!mounted) return;

    if (ok) {
      setState(() {
        _wrongPassword = false;
        _isAuthenticated = true;
      });
    } else {
      setState(() => _wrongPassword = true);
    }
  }

  /// Authenticates user using biometrics
  Future<void> _authenticateWithBiometrics() async {
    if (_bioLockedOut) return;
    if (!mounted) return;

    try {
      final didAuth = await localAuth.authenticate(
        localizedReason: 'Authenticate to unlock Reef',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!mounted) return;

      if (didAuth) {
        setState(() {
          _isAuthenticated = true;
          _wrongPassword = false;
          _bioAttempts = 0;
          _bioLockedOut = false;
        });
        return;
      }

      _bioAttempts += 1;

      if (_bioAttempts < kBioMaxAttemptsConst) {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted || _bioLockedOut) return;
        _authenticateWithBiometrics();
      } else {
        setState(() {
          _isAuthenticated = false;
          _wrongPassword = true;
          _biometricsIsAvailable = false;
          _bioLockedOut = true;
        });
      }
    } catch (_) {
      setState(() {
        _wrongPassword = true;
        _biometricsIsAvailable = false;
        _bioLockedOut = true;
      });
    }
  }

  // =============================================================
  //                         UI BUILD
  // =============================================================
  @override
  Widget build(BuildContext context) => _buildBody(context);

  Widget _buildBody(BuildContext context) {
    if (_hasError) {
      return Center(
        child: ElevatedButton(
          child: const Text('Retry'),
          onPressed: () {
            setState(() {
              _hasError = false;
              appReady = false;
            });
            _bootstrap();
          },
        ),
      );
    }

    final stillLoading =
    (!appReady || !_isAuthenticated || _isFirstLaunch == null);

    return Stack(
      children: <Widget>[
        if (stillLoading)
          Stack(
            children: [
              Container(
                width: double.infinity,
                color: Styles.splashBackgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/intro.gif",
                      height: kSplashGifSize,
                      width: kSplashGifSize,
                    ),
                    const SizedBox(height: kSplashGap16),
                    Visibility(
                      maintainSize: true,
                      maintainAnimation: true,
                      maintainState: true,
                      visible: _requiresAuth && !_isAuthenticated,
                      child: _buildAuth(context),
                    ),
                  ],
                ),
              ),
            ],
          )
        else if (_isFirstLaunch == true &&
            appReady == true &&
            _isAuthenticated == true)
          IntroductionPage(
            heroVideo: widget.heroVideo,
            onDone: () async {
              await ReefAppState.instance.storage
                  .setValue(kKeyFirstLaunch, false);
              if (!mounted) return;
              setState(() => _isFirstLaunch = false);
            },
          )
        else
          widget.displayOnInit(),
      ],
    );
  }

  // =============================================================
  //                      Password Auth UI
  // =============================================================
  Widget _buildAuth(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(kSplashAuthPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PASSWORD FOR REEF APP",
              style: TextStyle(
                fontSize: kSplashPasswordTitleSize,
                fontWeight: FontWeight.w500,
                color: Styles.textLightColor,
              ),
            ),
            const SizedBox(height: kSplashGap8),

            // Password Box
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: kSplashInputPaddingH,
                vertical: kSplashInputPaddingV,
              ),
              decoration: BoxDecoration(
                color: Styles.whiteColor,
                borderRadius: BorderRadius.circular(kSplashBorderRadius),
                border: Border.all(
                  color: const Color(0x20000000),
                  width: kSplashInputBorderWidth,
                ),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration.collapsed(hintText: ''),
                style: const TextStyle(fontSize: kSplashPasswordFontSize),
              ),
            ),

            const SizedBox(height: kSplashGap8),

            // Incorrect Password
            if (_wrongPassword)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: Styles.errorColor,
                    size: kSplashErrorIconSize,
                  ),
                  const SizedBox(width: kSplashGap8),
                  Flexible(
                    child: Text(
                      "Password is incorrect",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: kSplashGap12),

            // Send Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  splashFactory: !(password.isNotEmpty)
                      ? NoSplash.splashFactory
                      : InkSplash.splashFactory,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(kSplashBtnRadius),
                  ),
                  shadowColor: const Color(0x559d6cff),
                  elevation: 5,
                  backgroundColor: (password.isNotEmpty)
                      ? Styles.secondaryAccentColor
                      : const Color(0xff9d6cff),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  if (password.isNotEmpty) {
                    _authenticateWithPassword(password);
                  }
                },
                child:  Text(
                  'Send',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Styles.whiteColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: kSplashGap36),

            // Biometrics Button
            Visibility(
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              visible: _biometricsIsAvailable,
              child: Center(
                child: MaterialButton(
                  minWidth: 0,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: _authenticateWithBiometrics,
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  child: Ink(
                    padding: const EdgeInsets.all(kSplashGap8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Styles.primaryAccentColor,
                          Styles.secondaryAccentColor,
                        ],
                      ),
                    ),
                    child:  Icon(
                      Icons.fingerprint,
                      size: kSplashFingerprintSize,
                      color: Styles.whiteColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

