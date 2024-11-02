part of '../invoice_generator.dart';

// Mark: Journal Model
// =====================
class JournalModel {
  final String id;
  final String date;
  final String autoReversingDate;
  final Uint8List? logoBytes;
  List<JournalItemModel> items;
  late final List<List<JournalItemModel>> slicedItems;
  final String totalCreditAmount;
  final String totalDebitAmount;
  final String narration;
  final String gstin;
  final String termsAndConditions;
  final String termsAndConditionsLink;
  final String customerSupportEmail;

  JournalModel({
    required this.id,
    required this.date,
    required this.autoReversingDate,
    this.logoBytes,
    required this.items,
    required this.totalCreditAmount,
    required this.totalDebitAmount,
    required this.narration,
    required this.gstin,
    required this.termsAndConditions,
    required this.termsAndConditionsLink,
    required this.customerSupportEmail,
  }) {
    const lastPageLength = 3;
    const otherPageLength = 15;
    slicedItems = [];
    int i = 0;
    int length = items.length;
    while ((i==0&& i + 15 < length)||i+20<length) {
      if (i == 0) {
        slicedItems.add(items.slice(i, i + 15));
      } else {
        slicedItems.add(items.slice(i, i + 20));
      }

      i += 15;
    }
    slicedItems.add(items.slice(i));
    return;
    // const lastPageLength = 3;
    // const otherPageLength = 13;

    if (items.length <= lastPageLength) {
      slicedItems = [items];
      return;
    }

    List<List<JournalItemModel>> tempSlicedItemList = [];
    List<JournalItemModel> tempItemList = items;

    int lastPageItemCount = tempItemList.length % lastPageLength;
    if (lastPageItemCount == 0) lastPageItemCount = lastPageLength;
    int lastPageFirstItemIndex = tempItemList.length - lastPageItemCount;
    tempSlicedItemList.add(tempItemList.sublist(lastPageFirstItemIndex));
    tempItemList.removeRange(lastPageFirstItemIndex, tempItemList.length);
    tempSlicedItemList.insertAll(0, tempItemList.slices(otherPageLength));
    slicedItems = tempSlicedItemList;
  }
}

/// Journal Model Functions
extension JournalModelFunctions on JournalModel {}

// Mark: Journal Item Model
// ==========================
class JournalItemModel {
  final int index;
  final String id;
  final String? description;
  final String account;
  final String debitAmount;
  final String creditAmount;
  final DateTime date;
  final String dateString;

  JournalItemModel({
    required this.index,
    required this.id,
     this.description,
    required this.account,
    required this.debitAmount,
    required this.creditAmount,
    required this.date,
    required this.dateString,
  });
}
