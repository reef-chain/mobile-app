import 'package:flutter/material.dart';
import 'package:reef_mobile_app/l10n/app_localizations.dart';
import 'package:reef_mobile_app/components/introduction_page/introduction_slide.dart';
import 'package:reef_mobile_app/components/navigation/liquid_carousel_wrapper.dart';
import 'package:reef_mobile_app/utils/liquid_edge/liquid_carousel.dart';
import 'package:reef_mobile_app/utils/styles.dart';


const double kIntroVideoSize = 240.0;
const double kIntroHeadingFont = 35.0;
const double kIntroSubtitleFont = 16.0;

const double kIntroPaddingSmall = 4.0;
const double kIntroPaddingLarge = 35.0;

const double kIntroGapLarge = 30.0;

class IntroductionPage extends StatefulWidget {
  final Future<void> Function() onDone;
  final Widget heroVideo;

  const IntroductionPage(
      {super.key, required this.heroVideo, required this.onDone});

  @override
  State<IntroductionPage> createState() => _IntroductionPageState();
}

class _IntroductionPageState extends State<IntroductionPage>
    with AutomaticKeepAliveClientMixin {
  late final Widget child;

  @override
  void initState() {
    super.initState();
    child = IntroView(
      onDone: widget.onDone,
      heroVideo: widget.heroVideo,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return child;
  }

  @override
  bool get wantKeepAlive => true;
}

class IntroView extends StatelessWidget {
  final Future<void> Function() onDone;
  final Widget heroVideo;

  const IntroView({super.key, required this.onDone, required this.heroVideo});

  @override
  Widget build(BuildContext context) {
    final carouselKey = GlobalKey<LiquidCarouselState>();
    return Scaffold(
      body: LiquidCarousel(
        parentContext: context,
        key: carouselKey,
        children: <Widget>[
          const LiquidCarouselWrapper(),

          // --------------------------- SLIDE ---------------------------
          IntroductionSlide(
            done: onDone,
            liquidCarouselKey: carouselKey,
            color: Styles.splashBackgroundColor,
            buttonColor: Colors.deepPurpleAccent,
            title: "First View",
            child: Flex(
              crossAxisAlignment: CrossAxisAlignment.start,
              direction: Axis.vertical,
              children: [
                Expanded(
                  child: SizedBox(
                    height: kIntroVideoSize,
                    width: kIntroVideoSize,
                    child: Padding(
                      padding: const EdgeInsets.all(kIntroPaddingLarge),
                      child: heroVideo,
                    ),
                  ),
                ),

                // TEXT SECTION
                Flexible(
                  child: FittedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                          const EdgeInsets.all(kIntroPaddingSmall),
                          child: Text(
                            AppLocalizations.of(context)!.reliable,
                            style: const TextStyle(
                                fontSize: kIntroHeadingFont),
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.all(kIntroPaddingSmall),
                          child: Text(
                            AppLocalizations.of(context)!.extensible,
                            style: const TextStyle(
                                fontSize: kIntroHeadingFont),
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.all(kIntroPaddingSmall),
                          child: Text(
                            AppLocalizations.of(context)!.efficient,
                            style: const TextStyle(
                                fontSize: kIntroHeadingFont),
                          ),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.all(kIntroPaddingSmall),
                          child: Text(
                            AppLocalizations.of(context)!.fast,
                            style: const TextStyle(
                                fontSize: kIntroHeadingFont),
                          ),
                        ),

                        const SizedBox(height: kIntroGapLarge),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: kIntroPaddingSmall),
                          child: Text(
                            AppLocalizations.of(context)!
                                .blockchain_for_defi,
                            style: const TextStyle(
                              fontSize: kIntroSubtitleFont,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),

          const LiquidCarouselWrapper(),
        ],
      ),
    );
  }
}
