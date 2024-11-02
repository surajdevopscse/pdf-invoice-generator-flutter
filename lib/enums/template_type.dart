import 'package:collection/collection.dart';

enum TemplateType {
  standard,
  standard1,
  standard2,
  standard3,
  standard4,
  standard5,
  standard6,
  standard7,
  halfPrint,
  halfPrintNonGST,
}

TemplateType getTemplateType(String? name, bool isGstEnabled) {
  return TemplateType.values
          .firstWhereOrNull((element) => name == element.key) ??
      (isGstEnabled ? TemplateType.standard : TemplateType.standard3);
}

extension TemplateTypeMapping on TemplateType {
  String get title {
    switch (this) {
      case TemplateType.standard:
        return 'Standard';
      case TemplateType.standard1:
        return 'Custom-1';
      case TemplateType.standard2:
        return 'Custom-2';
      case TemplateType.standard4:
        return 'Custom-3';
      case TemplateType.standard5:
        return 'Custom-4';
      case TemplateType.standard7:
        return 'Custom-5';
      case TemplateType.standard3:
        return 'Standard';
      case TemplateType.standard6:
        return 'Custom-1';
      case TemplateType.halfPrint:
        return 'Half Print';
      case TemplateType.halfPrintNonGST:
        return 'Half Print';
    }
  }

  List<String> get countrySupported {
    switch (this) {
      case TemplateType.standard:
      case TemplateType.standard3:
        return ['AED', 'INR'];
      default:
        return ['INR'];
    }
  }

  String get key {
    switch (this) {
      case TemplateType.standard:
        return 'STR';
      case TemplateType.standard1:
        return 'C1';
      case TemplateType.standard2:
        return 'C2';
      case TemplateType.standard7:
        return 'C7';
      case TemplateType.standard4:
        return 'C4';
      case TemplateType.standard5:
        return 'C5';
      case TemplateType.standard6:
        return 'C6';
      case TemplateType.standard3:
        return 'C3';
      case TemplateType.halfPrint:
        return 'HP';
      case TemplateType.halfPrintNonGST:
        return 'HP-N';
    }
  }

  bool get gstTemplate {
    return !(this == TemplateType.standard3 ||
        this == TemplateType.standard6 ||
        this == TemplateType.halfPrintNonGST);
  }
}
