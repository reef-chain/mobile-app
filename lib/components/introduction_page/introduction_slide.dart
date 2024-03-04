import 'package:flutter/material.dart';
import 'package:reef_mobile_app/utils/liquid_edge/liquid_carousel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IntroductionSlide extends StatelessWidget {
  final GlobalKey<LiquidCarouselState> liquidCarouselKey;
  final Color color;
  final Color buttonColor;
  final String title;
  final Widget child;
  final Future<void> Function()? done;

  const IntroductionSlide(
      {Key? key,
      this.title = "",
      required this.liquidCarouselKey,
      required this.color,
      required this.buttonColor,
      required this.child,
      this.done})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
      ),
      child: Center(child: _buildBottomContent(context)),
    );
  }

  Widget _buildBottomContent(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
      child: Flex(
        direction: Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(child: child),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Row(
              mainAxisAlignment:  MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextButton(
                    style: ButtonStyle(
                        foregroundColor: MaterialStateProperty.resolveWith(
                            (states) => buttonColor)),
                    onPressed: () async {
                      if (done != null) {
                        await done!();
                      }
                      liquidCarouselKey.currentState?.swipeXNext();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Text(
                          AppLocalizations.of(context)!.next,
                          style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: .8,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
