import 'package:flutter/material.dart';

enum OrderStatus {
  cancelled,
  completed,
  pending,
  processing,
  served,
  ready;

  static OrderStatus getStatus(String s) {
    return OrderStatus.values
        .firstWhere((element) => s.toLowerCase() == element.key);
  }
}

extension OrderStatusMapping on OrderStatus {
  String get title {
    return name;
  }

  Color get color {
    switch (this) {
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  Color get bgColor {
    switch (this) {
      case OrderStatus.cancelled:
        return Colors.redAccent;
      default:
        return Colors.black;
    }
  }

  bool get isCompletedOrCancelled =>
      this == OrderStatus.cancelled || this == OrderStatus.completed;

  String get key {
    return name.toLowerCase();
  }
}
