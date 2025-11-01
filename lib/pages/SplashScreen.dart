import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:reef_chain_flutter/js_api_service.dart';
import 'package:reef_chain_flutter/reef_api.dart';
import 'package:reef_mobile_app/components/introduction_page/hero_video.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/locale/LocaleCtrl.dart';
import 'package:reef_mobile_app/model/locale/locale_model.dart';
import 'package:reef_mobile_app/pages/introduction_page.dart';
import 'package:reef_mobile_app/service/WalletConnectService.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../model/ReefAppState.dart';
import '../service/StorageService.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';

typedef WidgetCallback = Widget Function();

final navigatorKey = GlobalKey<NavigatorState>();



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

  // If something calls this, we guard inside to avoid setState after dispose.
  static void setLocale(BuildContext context, String newLocale) {
    final state = context.findAncestorStateOfType<_SplashAppState>();
    if (state != null && state.mounted) {
      state.setLocale(newLocale);
    }
  }
}

class _SplashAppState extends State<SplashApp> {
  String _locale = ReefAppState.instance.model.locale.selectedLanguage;

  static const _firstLaunch = "firstLaunch";
  bool _hasError = false;
  bool _isGifFinished = false;
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

  Future<bool> _checkBiometricsSupport() async {
    final isDeviceSupported = await localAuth.isDeviceSupported();
    final isAvailable = await localAuth.canCheckBiometrics;
    final isEnrolled =
        (await localAuth.getAvailableBiometrics()).isNotEmpty;
    return isAvailable && isDeviceSupported && isEnrolled;
  }

  Future<bool> _checkRequiresPasswordAuth() async {
    final storedPassword =
    await ReefAppState.instance.storage.getValue(StorageKey.password.name);
    return storedPassword != null && storedPassword != "";
  }

  Future<String> _getSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("languageCode") ?? 'en';
  }

  @override
  void initState() {
    super.initState();

    _getSavedLocale().then((value) {
      if (!mounted) return;
      setLocale(value);
    });

    _initializeAsyncDependencies();
    _initAuthentication();

    _passwordController.addListener(() {
      if (!mounted) return;
      setState(() => password = _passwordController.text);
    });

    _gifTimer = Timer(const Duration(milliseconds: 3830), () {
      if (!mounted) return;
      setState(() => _isGifFinished = true);
    });
  }

  @override
  void dispose() {
    _gifTimer?.cancel();
    _passwordController.dispose();
    super.dispose();
  }

  Future<bool> _checkIfFirstLaunch() async {
    final isFirstLaunch =
    await ReefAppState.instance.storage.getValue(_firstLaunch);
    return isFirstLaunch == null;
  }

  Future<void> _initAuthentication() async {
    try {
      final first = await _checkIfFirstLaunch();
      if (!mounted) return;
      setState(() => _isFirstLaunch = first);

      if (first || kDebugMode) {
        if (!mounted) return;
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
        await ReefAppState.instance.storage.getValue("biometricAuth");
        if (!mounted) return;
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
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  Future<void> _initializeAsyncDependencies() async {
    try {
      final storageService = StorageService();
      final walletConnectService = WalletConnectService();
      await ReefAppState.instance
          .init(storageService, walletConnectService, widget.reefChainApi);
      if (!mounted) return;
      setState(() => appReady = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  Future<void> _authenticateWithPassword(String value) async {
    final stored =
    await ReefAppState.instance.storage.getValue(StorageKey.password.name);
    if (!mounted) return;
    if (stored == value) {
      setState(() {
        _wrongPassword = false;
        _isAuthenticated = true;
      });
    } else {
      setState(() => _wrongPassword = true);
    }
  }

  Future<void> _authenticateWithBiometrics() => _authenticateWithBiometrics();


  @override
  Widget build(BuildContext context) {
    // NOTE: No MaterialApp here — main.dart provides it.
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    if (_hasError) {
      return Center(
        child: ElevatedButton(
          child: const Text('Retry'),
          onPressed: () {
            // simple retry: rerun both
            if (!mounted) return;
            setState(() {
              _hasError = false;
              appReady = false;
            });
            _initializeAsyncDependencies();
            _initAuthentication();
          },
        ),
      );
    }

    return Stack(
      children: <Widget>[
        if ((appReady == false || _isAuthenticated == false) ||
            _isFirstLaunch == null)
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
                      height: 128.0,
                      width: 128.0,
                    ),
                    const Gap(16),
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
              Positioned(
                bottom: 24,
                right: 24,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCirc,
                  opacity: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.loading ?? "Initializing app",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: Styles.textLightColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const Gap(4),
                      // Note: StreamBuilder is fine; it doesn't call setState on Splash
                      // It's internal; no leak.
                      StreamBuilder<String>(
                        stream: ReefAppState.instance.initStatusStream.stream,
                        initialData: ".",
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          final text = snapshot.hasData
                              ? snapshot.data ?? "..."
                              : "..";
                          return Text(
                            text,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              color: Styles.textLightColor,
                              decoration: TextDecoration.none,
                            ),
                          );
                        },
                      ),
                      const Gap(4),
                      const SizedBox(
                        height: 12,
                        width: 12,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Styles.textLightColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else if (_isFirstLaunch == true && appReady == true && _isAuthenticated == true)
          IntroductionPage(
            heroVideo: widget.heroVideo,
            onDone: () async {
              await ReefAppState.instance.storage.setValue(_firstLaunch, false);
              if (!mounted) return;
              setState(() => _isFirstLaunch = false);
            },
          )
        else
          widget.displayOnInit(),
      ],
    );
  }

  Widget _buildAuth(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "PASSWORD FOR REEF APP",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Styles.textLightColor,
              ),
            ),
            const Gap(8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Styles.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0x20000000),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration.collapsed(hintText: ''),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Gap(8),
            if (_wrongPassword)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    color: Styles.errorColor,
                    size: 16,
                  ),
                  const Gap(8),
                  Flexible(
                    child: Text(
                      "Password is incorrect",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ),
                ],
              ),
            const Gap(12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  splashFactory: !(password.isNotEmpty)
                      ? NoSplash.splashFactory
                      : InkSplash.splashFactory,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
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
                child: Text(
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
            const Gap(36),
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
                  padding: const EdgeInsets.all(0.0),
                  child: Ink(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black87,
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Styles.primaryAccentColor,
                          Styles.secondaryAccentColor,
                        ],
                      ),
                    ),
                    child: Icon(Icons.fingerprint,
                        size: 36, color: Styles.whiteColor),
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

