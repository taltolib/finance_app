import 'package:flutter/material.dart';
import 'app_selection_sheet.dart';

Future<void> customShowBottomSheetDialog(
    BuildContext context,
    double? heightSizeDialog,
    Widget header,
    Widget body,
    Widget? bottom, {
      double? selectionSheetPaddingHeader,
      double? selectionSheetPaddingBody,
      double? selectionSheetPaddingBottom,
      Radius? heightRadius ,
    }) async {
  showModalBottomSheet(
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    context: context,
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: heightSizeDialog ?? 0.7,
        minChildSize: heightSizeDialog ?? 0.7,
        builder: (BuildContext context, ScrollController _) {
          return AppSelectionSheet(header: header, body: body, bottom: bottom,heightRadius: heightRadius ,);

        },
      );
    },
  );
}
