part of '../invoice_generator.dart';

// Mark: Receipt Model
// =====================
class ReceiptModel {
  final String title;
  final String id;
  final String modelSubType;
  final String date;
  final Uint8List? logoBytes;
  final ReceiptCompanyModel buyer;
  final ReceiptCompanyModel seller;
  List<ReceiptItemModel> items;
  late final List<List<ReceiptItemModel>> slicedItems;
  final String sgstLabel;
  final String sgstValue;
  final String cgstLabel;
  final String cgstValue;
  final bool? isReversedCharge;
  final String unadjustedAmount;
  final String totalAmount;
  final String totalAmountInWords;
  final ReceiptTransactionModel transaction;
  final String termsAndConditions;
  final String termsAndConditionsLink;
  final String customerSupportEmail;

  ReceiptModel({
    required this.title,
    required this.id,
    required this.date,
    this.logoBytes,
    required this.modelSubType,
    required this.buyer,
    required this.seller,
    required this.items,
    required this.sgstLabel,
    required this.sgstValue,
    required this.cgstLabel,
    required this.cgstValue,
    required this.isReversedCharge,
    required this.unadjustedAmount,
    required this.totalAmount,
    required this.totalAmountInWords,
    required this.transaction,
    required this.termsAndConditions,
    required this.termsAndConditionsLink,
    required this.customerSupportEmail,
  }) {
    const lastPageLength = 3;
    const otherPageLength = 15;

    if (items.length <= lastPageLength) {
      slicedItems = [items];
      return;
    }

    List<List<ReceiptItemModel>> tempSlicedItemList = [];
    List<ReceiptItemModel> tempItemList =
        items.sortedByCompare((e) => e.index, (a, b) => a.compareTo(b));

    int lastPageItemCount = tempItemList.length % lastPageLength;
    if (lastPageItemCount == 0) lastPageItemCount = lastPageLength;
    int lastPageFirstItemIndex = tempItemList.length - lastPageItemCount;
    tempSlicedItemList.add(tempItemList.sublist(lastPageFirstItemIndex));
    tempItemList.removeRange(lastPageFirstItemIndex, tempItemList.length);
    tempSlicedItemList.insertAll(0, tempItemList.slices(otherPageLength));
    slicedItems = tempSlicedItemList;
  }
}

/// Receipt Model Functions
extension ReceiptModelFunctions on ReceiptModel {}

// Mark: Receipt Buyer Model
// ============================
class ReceiptCompanyModel {
  final String name;
  final String? phone;
  final String? email;
  final String? gstNumber;
  final ReceiptAddressModel address;
  final ReceiptAddressModel? billingAddress;
  final ReceiptAddressModel? customerAddress;
  final ReceiptBankAccountModel? bankAccount;

  ReceiptCompanyModel({
    required this.name,
    this.phone,
    this.email,
    required this.address,
    this.gstNumber,
    this.billingAddress,
    this.customerAddress,
    this.bankAccount,
  });
}

// Mark: Receipt Address Model
// ============================
class ReceiptAddressModel {
  final String? name;
  final int? countryCode;
  final int? phone;
  final String? city;
  final String? state;
  final String? country;
  final String address;
  final int pincode;

  ReceiptAddressModel({
    this.name,
    this.countryCode,
    this.phone,
    this.city,
    this.state,
    this.country,
    required this.address,
    required this.pincode,
  });
}

// Mark: Receipt Bank Account Type
// ==================================
enum ReceiptBankAccountType {
  saving,
  current,
  investment,
  cashCredit,
  moneyMarket,
  certificateOfDeposit
}

// Mark: Receipt Bank Account Model
// ==================================
class ReceiptBankAccountModel {
  final String bankName;
  final String holderName;
  final String accountNumber;
  final String ifsc;
  final ReceiptBankAccountType type;

  ReceiptBankAccountModel({
    required this.bankName,
    required this.holderName,
    required this.accountNumber,
    required this.ifsc,
    required this.type,
  });
}

// Mark: Receipt Transaction Model
// ==================================
class ReceiptTransactionModel {
  final String transferType;
  final String accountNumber;
  final String ifsc;
  final String date;
  final String amount;
  final String receivedAs;

  ReceiptTransactionModel({
    required this.transferType,
    required this.accountNumber,
    required this.ifsc,
    required this.date,
    required this.amount,
    required this.receivedAs,
  });
}

// Mark: Receipt Item Model
// ==========================
class ReceiptItemModel {
  final int index;
  final String id;
  final String name;
  final String date;
  final String gst;
  final String amount;

  ReceiptItemModel({
    required this.index,
    required this.id,
    required this.name,
    required this.date,
    required this.gst,
    required this.amount,
  });
}
