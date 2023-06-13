import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qfinr/widgets/styles.dart';

class AddPortfolioStyles {

  static const String iconImportExcel = "assets/icon/icon_import_excel.png";
  static const String iconAddManually = "assets/icon/icon_add_manually.png";
  static const String iconStatement = "assets/icon/icon_statement.png";

  static const String tileHedingImportExcel = "Import";
  static const String tileHedingAddManually = "Add Manually";
  static const String tileHedingStatement = "Upload Statements";

  static const String tileContentTextImportExcel = "Import NSDL/CDSL pdf statements or Excel/csv files from your broker or using the simple qfinr excel template";
  static const String tileContentTextAddManually = "Add/edit all holdings right here";
  static const String tileContentTextStatement = "";

  static const TextStyle blueLinkTextBold = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'nunito',
        letterSpacing: 0.4,
        color: AppColor.colorBlue,
      );

  static const TextStyle heding = TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w800,
        fontFamily: 'nunito',
        letterSpacing: 0.26,
        color: Colors.black,
      );

  static const TextStyle subHeading = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'nunito',
        letterSpacing: 0.4,
        color: Colors.black54,
      );

  static const TextStyle tileTilte = TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        fontFamily: 'nunito',
        letterSpacing: 0.26,
        color: Colors.black,
      );

  static const TextStyle tileDescription = TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'nunito',
        letterSpacing: 0.4,
        color: Color(0xff707070),
      );
}