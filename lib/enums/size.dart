

import 'package:collection/collection.dart';

enum LogoSize { small, medium, large }

LogoSize? getLogoSize(double? size) {
  return LogoSize.values.firstWhereOrNull((element) => element.size == size);
}

extension SizeMapping on LogoSize {
  String get title {
    switch (this) {
      case LogoSize.small:
        return 'Small';
      case LogoSize.medium:
        return 'Medium';
      case LogoSize.large:
        return 'Large';
    }
  }

  double get size {
    switch (this) {
      case LogoSize.small:
        return 64;
      case LogoSize.medium:
        return 80;
      case LogoSize.large:
        return 96;
    }
  }
}
