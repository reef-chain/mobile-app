import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:local_auth/local_auth.dart';
import 'package:reef_mobile_app/components/account_box.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/bind_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/model/signing/signature_request.dart';
import 'package:reef_mobile_app/model/signing/tx_decoded_data.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/styles.dart';

import '../../model/status-data-object/StatusDataObject.dart';

List<TableRow> createTable(
    {required keyTexts,
    required valueTexts,
    double fontSizeLabel = 12,
    double fontSizeValue = 12}) {
  List<TableRow> rows = [];
  for (int i = 0; i < keyTexts.length; ++i) {
    rows.add(TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: GradientText(
          keyTexts[i],
          gradient: textGradient(),
          textAlign: TextAlign.right,
          style:
              TextStyle(fontWeight: FontWeight.w600, fontSize: fontSizeLabel),
        ),
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
          child: Text(
            valueTexts[i],
            style: TextStyle(fontSize: fontSizeValue),
            overflow: TextOverflow.fade,
          ),
        ),
      ),
    ]));
  }
  return rows;
}
