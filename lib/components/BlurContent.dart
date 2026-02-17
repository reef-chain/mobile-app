import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class BlurableContent extends StatelessObserverWidget {
  final Widget child;
  final bool isChildBlur;

  const BlurableContent(this.child, this.isChildBlur, {super.key});

  @override
  Widget build(BuildContext context) {
    if (!isChildBlur) {
      return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 23.0, sigmaY: 23.0),
          child: child);
    }
    return child;
  }
}
