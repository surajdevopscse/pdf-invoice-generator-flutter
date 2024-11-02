import 'package:flutter/material.dart';




enum ItemStatus {
  cancelled,
  completed,
  pending,
  processing,
  served,
  ready;

  static ItemStatus getStatus(String s) {
    return ItemStatus.values
        .firstWhere((element) => s.toLowerCase() == element.key);
  }
}

extension ItemStatusMapping on ItemStatus {
  

  Color get color {
    switch (this) {
      case ItemStatus.cancelled:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Color get bgColor {
    switch (this) {
      case ItemStatus.cancelled:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  bool get isCompletedOrCancelled =>
      this == ItemStatus.cancelled || this == ItemStatus.completed;

  String get key {
    return name.toLowerCase();
  }
}
