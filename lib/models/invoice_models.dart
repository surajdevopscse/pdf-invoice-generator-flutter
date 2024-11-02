part of '../invoice_generator.dart';

class InvoiceModel {
  final String id;
  final String date;
  final String dueDate;
  final String time;
  final String title;
  final Uint8List? logoBytes;
  final String? paymentQrBytes;
  final String salesman;
  final String? placeOfSupply;
  final InvoiceCompanyModel buyer;
  final InvoiceCompanyModel seller;
  final List<InvoiceItemModel> items;
  final List<InvoiceHsnModel> hsnItems;
  final List<TenderDetails> tenderDetails;
  final List<AdditionalFieldsModel> additionalFields;
  final String subTotalAmount;
  final String discount;
  final String sgstLabel;
  final String sgstValue;
  final String txnLevelDiscount;
  final String companyName;
  final String companyGST;
  final String companyPan;
  String printCopyTitle;
  final String? companyAddress;
  final String? companyPINCode;
  final String cgstLabel;
  final String cgstValue;
  final String cessLabel;
  final String cessValue;
  final String totalQuantities;
  final String totalDiscount;
  final String totalTaxable;
  final String totalGst;
  final String totalAmount;
  final String totalItemAmount;

  final String roundOff;
  final bool is3mm;
  final String? validTillDate;
  final String? deliveryDate;

  final String footerTotalAmount;
  final String totalAmountInWords;
  final String totalTaxAmountInWords;
  final String receivedAmount;
  final String? balanceAmount;
  final String savedAmount;
  final String termsAndConditions;
  final String termsAndConditionsLink;
  final String customerSupportEmail;
  final String moduleType;
  final String due;
  final String? notes;
  final bool isIgst;
  final String hsnItemCount;
  final PdfSettings settings;
  final String currencySymbol;
  final String currencyCode;
  final String taxLabel;
  final String taxRateLabel;
  final bool advance;
  final String? advanceAmount;

  bool get isIndia => currencyCode == 'INR';

  InvoiceModel({
    required this.id,
    this.is3mm = false,
    required this.placeOfSupply,
    required this.currencyCode,
    required this.currencySymbol,
    required this.taxLabel,
    required this.taxRateLabel,
    required this.companyName,
    required this.companyGST,
    required this.companyPan,
    this.companyAddress,
    this.advance = false,
    this.advanceAmount,
    required this.moduleType,
    required this.date,
    required this.dueDate,
    required this.time,
    required this.logoBytes,
    required this.paymentQrBytes,
    required this.salesman,
    required this.buyer,
    required this.seller,
    required this.items,
    required this.printCopyTitle,
    required this.subTotalAmount,
    required this.discount,
    required this.sgstLabel,
    required this.sgstValue,
    required this.cgstLabel,
    required this.cgstValue,
    required this.cessLabel,
    required this.cessValue,
    required this.roundOff,
    this.companyPINCode,
    required this.title,
    this.notes,
    required this.txnLevelDiscount,
    required this.totalQuantities,
    required this.totalDiscount,
    required this.totalTaxable,
    required this.totalGst,
    required this.totalAmount,
    required this.totalItemAmount,
    required this.footerTotalAmount,
    required this.totalAmountInWords,
    required this.totalTaxAmountInWords,
    required this.receivedAmount,
    required this.isIgst,
    required this.hsnItemCount,
    this.balanceAmount,
    required this.due,
    this.tenderDetails = const [],
    this.additionalFields = const [],
    this.hsnItems = const [],
    required this.savedAmount,
    required this.termsAndConditions,
    required this.termsAndConditionsLink,
    required this.customerSupportEmail,
    required this.settings,
    this.deliveryDate,
    this.validTillDate,
  });
}

/// Invoice Model Functions
extension InvoiceModelFunctions on InvoiceModel {
  InvoiceModel copy(InvoiceModel originalInvoice) {
    return InvoiceModel(
      id: originalInvoice.id,
      date: originalInvoice.date,
      dueDate: originalInvoice.dueDate,
      time: originalInvoice.time,
      title: originalInvoice.title,
      logoBytes: originalInvoice.logoBytes,
      paymentQrBytes: originalInvoice.paymentQrBytes,
      salesman: originalInvoice.salesman,
      advanceAmount: originalInvoice.advanceAmount,
      placeOfSupply: originalInvoice.placeOfSupply,
      advance: originalInvoice.advance,
      buyer: originalInvoice.buyer.copy(),
      seller: originalInvoice.seller.copy(),
      additionalFields:
          originalInvoice.additionalFields.map((e) => e.copy()).toList(),
      items: List.from(originalInvoice.items.map((item) => item.copy())),
      hsnItems:
          List.from(originalInvoice.hsnItems.map((hsnItem) => hsnItem.copy())),
      tenderDetails:
          List.from(originalInvoice.tenderDetails.map((td) => td.copy())),
      subTotalAmount: originalInvoice.subTotalAmount,
      discount: originalInvoice.discount,
      sgstLabel: originalInvoice.sgstLabel,
      sgstValue: originalInvoice.sgstValue,
      txnLevelDiscount: originalInvoice.txnLevelDiscount,
      companyName: originalInvoice.companyName,
      companyGST: originalInvoice.companyGST,
      companyPan: originalInvoice.companyPan,
      printCopyTitle: originalInvoice.printCopyTitle,
      companyAddress: originalInvoice.companyAddress,
      companyPINCode: originalInvoice.companyPINCode,
      cgstLabel: originalInvoice.cgstLabel,
      cgstValue: originalInvoice.cgstValue,
      cessLabel: originalInvoice.cessLabel,
      cessValue: originalInvoice.cessValue,
      totalQuantities: originalInvoice.totalQuantities,
      totalDiscount: originalInvoice.totalDiscount,
      totalTaxable: originalInvoice.totalTaxable,
      totalGst: originalInvoice.totalGst,
      totalAmount: originalInvoice.totalAmount,
      totalItemAmount: originalInvoice.totalItemAmount,
      roundOff: originalInvoice.roundOff,
      is3mm: originalInvoice.is3mm,
      validTillDate: originalInvoice.validTillDate,
      deliveryDate: originalInvoice.deliveryDate,
      footerTotalAmount: originalInvoice.footerTotalAmount,
      totalAmountInWords: originalInvoice.totalAmountInWords,
      totalTaxAmountInWords: originalInvoice.totalTaxAmountInWords,
      receivedAmount: originalInvoice.receivedAmount,
      balanceAmount: originalInvoice.balanceAmount,
      savedAmount: originalInvoice.savedAmount,
      termsAndConditions: originalInvoice.termsAndConditions,
      termsAndConditionsLink: originalInvoice.termsAndConditionsLink,
      customerSupportEmail: originalInvoice.customerSupportEmail,
      moduleType: originalInvoice.moduleType,
      due: originalInvoice.due,
      notes: originalInvoice.notes,
      isIgst: originalInvoice.isIgst,
      hsnItemCount: originalInvoice.hsnItemCount,
      settings: originalInvoice.settings,
      currencySymbol: originalInvoice.currencySymbol,
      currencyCode: originalInvoice.currencyCode,
      taxLabel: originalInvoice.taxLabel,
      taxRateLabel: originalInvoice.taxRateLabel,
    );
  }
}

// Mark: Invoice Buyer Model
// ============================
class InvoiceCompanyModel {
  final String name;
  final String? phone;
  final String? email;
  final String? gstorPanNumber;
  final String? gstLabel;
  final InvoiceAddressModel address;
  final InvoiceAddressModel? billingAddress;
  final InvoiceAddressModel? shippingAddress;
  final InvoiceBankAccountModel? bankAccount;

  InvoiceCompanyModel({
    required this.name,
    this.phone,
    this.email,
    this.gstLabel,
    required this.address,
    this.gstorPanNumber,
    this.billingAddress,
    this.shippingAddress,
    this.bankAccount,
  });

  InvoiceCompanyModel copy() {
    return InvoiceCompanyModel(
      name: name,
      phone: phone,
      email: email,
      gstorPanNumber: gstorPanNumber,
      gstLabel: gstLabel,
      address: address.copy(),
      billingAddress: billingAddress?.copy(),
      shippingAddress: shippingAddress?.copy(),
      bankAccount: bankAccount?.copy(),
    );
  }
}

// Mark: Invoice Address Model
// ============================
class InvoiceAddressModel {
  final String? name;
  final int? countryCode;
  final int? phone;
  final String? city;
  final String? state;
  final String? country;
  final String? address;
  final String? gstLabel;
  final String? gstOrPanValue;
  final int? pincode;

  InvoiceAddressModel({
    this.name,
    this.countryCode,
    this.gstLabel,
    this.gstOrPanValue,
    this.phone,
    this.city,
    this.state,
    this.country,
    required this.address,
    required this.pincode,
  });

  InvoiceAddressModel copy() {
    return InvoiceAddressModel(
      name: name,
      countryCode: countryCode,
      phone: phone,
      city: city,
      state: state,
      country: country,
      address: address,
      gstLabel: gstLabel,
      gstOrPanValue: gstOrPanValue,
      pincode: pincode,
    );
  }
}

// Mark: Invoice Bank Account Type
// ==================================
enum InvoiceBankAccountType {
  saving,
  current,
  investment,
  cashCredit,
  moneyMarket,
  certificateOfDeposit
}

// Mark: Invoice Bank Account Model
// ==================================
class InvoiceBankAccountModel {
  final String holderName;
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String ifsc;
  final InvoiceBankAccountType type;

  InvoiceBankAccountModel({
    required this.holderName,
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.ifsc,
    required this.type,
  });

  InvoiceBankAccountModel copy() {
    return InvoiceBankAccountModel(
      holderName: holderName,
      bankName: bankName,
      branchName: branchName,
      accountNumber: accountNumber,
      ifsc: ifsc,
      type: type,
    );
  }
}

// Mark: Invoice Item Model
// ==========================
class InvoiceItemModel {
  final int index;

  final String name;
  final String code;
  final String hsnOrsacLabel;
  final String quantity;
  final String unit;
  final String price;
  final String discount;
  final String gst;
  final String cess;
  final String amount;
  final String mrp;
  final String taxable;
  final String delivery;
  final String freight;
  final String description;
  String hsn;
  final String gstRate;
  final List<AdditionalFieldsModel> afterUnitPriceFields;
  final List<AdditionalFieldsModel> afterDiscountPriceFields;
  final List<AdditionalFieldsModel> afterUnitAndDiscountFields;
  final List<AdditionalFieldsModel> afterTaxableFields;
  final List<AdditionalFieldsModel> nonNumericFields;

  InvoiceItemModel({
    required this.hsnOrsacLabel,
    required this.index,
    required this.code,
    required this.hsn,
    required this.description,
    required this.delivery,
    required this.freight,
    required this.taxable,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.cess,
    required this.discount,
    required this.gst,
    required this.amount,
    required this.mrp,
    required this.gstRate,
    this.afterDiscountPriceFields = const [],
    this.afterTaxableFields = const [],
    this.afterUnitAndDiscountFields = const [],
    this.afterUnitPriceFields = const [],
    this.nonNumericFields = const [],
  });

  InvoiceItemModel copy() {
    return InvoiceItemModel(
      index: index,
      name: name,
      code: code,
      hsnOrsacLabel: hsnOrsacLabel,
      quantity: quantity,
      unit: unit,
      price: price,
      discount: discount,
      gst: gst,
      cess: cess,
      amount: amount,
      mrp: mrp,
      taxable: taxable,
      delivery: delivery,
      freight: freight,
      description: description,
      hsn: hsn,
      gstRate: gstRate,
      afterDiscountPriceFields:
          afterDiscountPriceFields.map((e) => e.copy()).toList(),
      afterTaxableFields: afterTaxableFields.map((e) => e.copy()).toList(),
      afterUnitAndDiscountFields:
          afterUnitAndDiscountFields.map((e) => e.copy()).toList(),
      afterUnitPriceFields: afterUnitPriceFields.map((e) => e.copy()).toList(),
      nonNumericFields: nonNumericFields.map((e) => e.copy()).toList(),
    );
  }
}

// Mark: Invoice Item Model
// ==========================
class InvoiceHsnModel {
  String hsnCode;
  String gstRate;
  String taxableValue;
  String gstAmount;
  String cessAmount;
  String totalTaxAmount;

  InvoiceHsnModel(
      {required this.hsnCode,
      required this.totalTaxAmount,
      required this.gstRate,
      required this.cessAmount,
      required this.gstAmount,
      required this.taxableValue});

  InvoiceHsnModel copy() {
    return InvoiceHsnModel(
      hsnCode: hsnCode,
      gstRate: gstRate,
      taxableValue: taxableValue,
      gstAmount: gstAmount,
      cessAmount: cessAmount,
      totalTaxAmount: totalTaxAmount,
    );
  }
}

class TenderDetails {
  String tender;
  String refNo;
  String receivedAmount;
  TenderDetails(
      {required this.tender,
      required this.refNo,
      required this.receivedAmount});

  TenderDetails copy() {
    return TenderDetails(
      tender: tender,
      refNo: refNo,
      receivedAmount: receivedAmount,
    );
  }
}

class AdditionalFieldsModel {
  String name;
  String value;
  String totalValue;

  AdditionalFieldsModel(
      {required this.value, required this.name, required this.totalValue});

  AdditionalFieldsModel copy() {
    return AdditionalFieldsModel(
        value: value, name: name, totalValue: totalValue);
  }
}
