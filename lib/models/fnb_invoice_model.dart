import 'package:invoice_generator/enums/fnb_item_status.dart';
import 'package:invoice_generator/enums/fnb_order_status.dart';
import 'package:tuple/tuple.dart';

class OrderDetail {
  String orderId;
  String orderNo;
  String invoiceNo;
  int tokenNo;
  int tableId;
  String tableName;
  int floorNo;
  int tableOccupiedBy;
  int totalItems;
  double totalAmount;
  String paidAmount;
  DateTime orderedAt;
  String customerName;
  String customerEmail;
  String customerPhone;
  String customerAddress;
  List<Tuple2<String, String>> mergedTables;
  OrderStatus status;
  List<PrinterWiseKots> printerWiseKots;
  List<Kot> kotItems;
  int tableCapacity;
  List<Map<String, List<Kot>>> kotsForPrinting(List<String> filterIds) {
    List<Map<String, List<Kot>>> tempList = [];
    Map<String, List<Kot>> tempMap = {};
    final filteredkots = kotItems.where((e) {
      return (filterIds.isEmpty || filterIds.contains(e.id.toString()));
    }).toList();
    final kitchenIdSet =
        filteredkots.map((e) => e.kitchenDetail.kitchenId).toSet().toList();
    for (var p in kitchenIdSet) {
      final arr = filteredkots.where((e) => e.kitchenDetail.kitchenId == p);
      tempMap.addAll({p.toString(): arr.toList()});
      tempList.add(tempMap);
    }
    return tempList;
  }

  BilledBy billedBy;
  DateTime billedAt;

  OrderDetail({
    required this.orderId,
    required this.orderNo,
    required this.invoiceNo,
    required this.tokenNo,
    required this.tableId,
    required this.tableName,
    required this.floorNo,
    required this.tableOccupiedBy,
    required this.totalItems,
    required this.totalAmount,
    required this.paidAmount,
    required this.orderedAt,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    required this.mergedTables,
    required this.tableCapacity,
    required this.kotItems,
    required this.printerWiseKots,
    required this.billedBy,
    required this.billedAt,
    required this.status,
  });

  void calculateTotalAmount() {
    totalAmount = kotItems.fold(0, (previousValue, element) {
      if (element.status == ItemStatus.cancelled) return previousValue;
      return (element.itemQty * element.itemPrice) + previousValue;
    });
  }
}

class BilledBy {
  String name;
  int phone;

  BilledBy({
    required this.name,
    required this.phone,
  });
}

class Kot {
  String uuid;
  int id;
  String itemName;
  String variantName;
  String itemThumbnail;
  int itemQty;
  List<String?> itemImages;
  double itemPrice;
  String note;
  ItemStatus status;
  Printer printer;
  KitchenDetail kitchenDetail;

  Kot({
    required this.id,
    required this.itemName,
    required this.variantName,
    required this.uuid,
    required this.itemThumbnail,
    required this.itemQty,
    required this.itemImages,
    required this.itemPrice,
    required this.note,
    required this.status,
    required this.printer,
    required this.kitchenDetail,
  });
}

class PrinterWiseKots {
  Map<String, PrinterKitchen> kitchens;
  String printerId;
  String printerName;
  String printerPort;
  String printerIpAddress;
  bool isDefault;

  PrinterWiseKots({
    required this.kitchens,
    required this.printerId,
    required this.printerName,
    required this.printerPort,
    required this.printerIpAddress,
    required this.isDefault,
  });

  Map<String, dynamic> toJson() => {
        "kitchens": Map.from(kitchens)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "printerId": printerId,
        "printerName": printerName,
        "printerPort": printerPort,
        "printerIPAddress": printerIpAddress,
        "isDefault": isDefault,
      };
}

class PrinterKitchen {
  Map<String, PrinterKitchenItem> items;
  String kitchenId;
  String? kitchenName;

  PrinterKitchen({
    required this.items,
    required this.kitchenId,
    this.kitchenName,
  });

  Map<String, dynamic> toJson() => {
        "items": Map.from(items)
            .map((k, v) => MapEntry<String, dynamic>(k, v.toJson())),
        "kitchenId": kitchenId,
        "kitchenName": kitchenName,
      };
}

class PrinterKitchenItem {
  String itemUuid;
  String itemId;
  String name;
  String variantName;
  int qty;
  String note;
  ItemStatus status;
  int price;

  PrinterKitchenItem({
    required this.itemUuid,
    required this.itemId,
    required this.name,
    required this.variantName,
    required this.qty,
    required this.note,
    required this.status,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        "itemUUID": itemUuid,
        "itemId": itemId,
        "name": name,
        "variantName": variantName,
        "qty": qty,
        "note": note,
        "status": status,
        "price": price,
      };
}

class KitchenDetail {
  int kitchenId;
  String kitchenName;
  KitchenDetail({
    required this.kitchenId,
    required this.kitchenName,
  });
}

class Printer {
  String printerId;
  String printerName;
  String printerPort;
  String printerIPAddress;

  Printer({
    required this.printerId,
    required this.printerName,
    required this.printerPort,
    required this.printerIPAddress,
  });
}
