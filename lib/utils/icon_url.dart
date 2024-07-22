import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jovial_svg/jovial_svg.dart';

class IconFromUrl extends StatelessWidget {
  final dynamic iconUrl;
  final double? size;

  const IconFromUrl(this.iconUrl, {Key? key, this.size = 24}) : super(key: key);

  String processSvgUrl(String value) {
    if (!value.startsWith("data:image/svg+xml;base64,")) {
      return value;
    }
    value = value.substring(26);
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String base64Decoded = stringToBase64.decode(value);
    String uriEncoded = Uri.encodeComponent(base64Decoded);
    return "data:image/svg+xml,$uriEncoded";
  }

  @override
  Widget build(BuildContext context) {
    if (iconUrl == null) {
      return Icon(CupertinoIcons.question_circle,
          color: Colors.grey[600]!, size: size);
    }

    if (iconUrl.startsWith("data:image/svg+xml")) {
    return ClipOval(      // Added ClipOval
            child: Container(   // Added Container
              width: size,
              height: size,
              child: FittedBox( // Added FittedBox
                fit: BoxFit.cover,
                child: SizedBox( // Added SizedBox for even sizing
                  width: size,
                  height: size,
                  child: ScalableImageWidget.fromSISource(
                    si: ScalableImageSource.fromSvgHttpUrl(
                      Uri.parse(processSvgUrl(iconUrl))
                    )
                  ),
                ),
              ),
            ),
          );
    }

    return buildIcon(iconUrl);
  }

    Widget buildIcon(String dataUrl){
    return ClipOval(
      child: isValidSVG(dataUrl)
          ? SvgPicture.string(
              utf8.decode(base64
                  .decode(dataUrl.split('data:image/svg+xml;base64,')[1])),
              width: size,
              height: size)
          : CachedNetworkImage(
            imageUrl: dataUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
                  width: size,
                  height: size,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            errorWidget: (context, url, error) {
              return Icon(
                CupertinoIcons.exclamationmark_circle_fill,
                color: Colors.black12,
                size: size,
              );
            })
        );
  }

  bool isValidSVG(String? dataUrl) {
    return dataUrl != null && dataUrl.contains("data:image/svg+xml;base64,");
  }
}
