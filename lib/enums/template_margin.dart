import 'package:collection/collection.dart';

enum TemplateMargin { defaultMargin, none, custom }

TemplateMargin? getMargin(double margin) {
  return TemplateMargin.values
      .firstWhereOrNull((element) => element.margin == margin);
}

TemplateMargin? getMarginFromTitle(String? title) {
  return TemplateMargin.values
      .firstWhereOrNull((element) => element.title == title);
}

extension MarginMapping on TemplateMargin {
  String get title {
    switch (this) {
      case TemplateMargin.defaultMargin:
        return 'Default';
      case TemplateMargin.none:
        return 'None';
      case TemplateMargin.custom:
        return 'Custom';
    }
  }

  double? get margin {
    switch (this) {
      case TemplateMargin.defaultMargin:
        return 16;
      case TemplateMargin.none:
        return 0;
      case TemplateMargin.custom:
        return null;
    }
  }
}
