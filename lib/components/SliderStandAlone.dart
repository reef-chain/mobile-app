import 'package:flutter/material.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class SliderStandAlone extends StatefulWidget {
  final double rating;
  final Function(double) onChanged;
  final bool? isDisabled;

  const SliderStandAlone({Key? key, required this.rating, required this.onChanged,this.isDisabled})
      : super(key: key);

  @override
  _SliderStandAloneState createState() => _SliderStandAloneState();
}

class _SliderStandAloneState extends State<SliderStandAlone> {
  late TextEditingController amountController;
  late TextEditingController amountTopController;

  @override
  void initState() {
    amountController = TextEditingController();
    amountTopController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        showValueIndicator: ShowValueIndicator.never,
        overlayShape: SliderComponentShape.noOverlay,
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: Styles.secondaryAccentColorDark,
        thumbColor: Styles.secondaryAccentColorDark,
        inactiveTickMarkColor: Color(0xffc0b8dc),
        trackShape: GradientRectSliderTrackShape(
            gradient: Styles.buttonGradient,
            darkenInactive: true),
        activeTickMarkColor: const Color(0xffffffff),
        tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 4),
        thumbShape: const ThumbShape(),
      ),
      child: Slider(
        value: widget.rating,
        onChanged:(newRating){
          if(widget.isDisabled!)return;
          widget.onChanged(newRating);
          },
        divisions: 100,
        label: "${(widget.rating * 100).toInt()}%",
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    amountTopController.dispose();
    super.dispose();
  }
}
