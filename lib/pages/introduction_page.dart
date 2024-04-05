import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reef_mobile_app/components/introduction_page/introduction_slide.dart';
import 'package:reef_mobile_app/components/navigation/liquid_carousel_wrapper.dart';
import 'package:reef_mobile_app/utils/liquid_edge/liquid_carousel.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class IntroductionPage extends StatefulWidget {
  final Future<void> Function() onDone;
  final Widget heroVideo;

  const IntroductionPage(
      {Key? key, required this.heroVideo, required this.onDone})
      : super(key: key);

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
    //? Use a key to interact with the carousel from another widget (for triggering swipeToNext or swipeToPrevious from a button for example)
    final carouselKey = GlobalKey<LiquidCarouselState>();
    return Scaffold(
      body: LiquidCarousel(
        parentContext: context,
        key: carouselKey,
        children: <Widget>[
          const LiquidCarouselWrapper(),
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
                      height: 240.0,
                      width: 240.0,
                      child: Padding(
                          padding: const EdgeInsets.all(35), child: heroVideo),
                    ),
                  ),
                  Flexible(
                      child: FittedBox(
                          child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          AppLocalizations.of(context)!.reliable,
                          style: const TextStyle(fontSize: 35),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          AppLocalizations.of(context)!.extensible,
                          style: const TextStyle(fontSize: 35),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          AppLocalizations.of(context)!.efficient,
                          style: const TextStyle(fontSize: 35),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          AppLocalizations.of(context)!.fast,
                          style: const TextStyle(fontSize: 35),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            AppLocalizations.of(context)!.blockchain_for_defi,
                            style: const TextStyle(fontSize: 16),
                          )),
                    ],
                  )))
                ],
              )),
          const LiquidCarouselWrapper()
        ],
      ),
    );
  }
}
