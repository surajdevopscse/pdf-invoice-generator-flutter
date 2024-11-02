import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:invoice_generator/enums/template_type.dart';

class PdfSettings {
  double logoSize;
  String logoAlign;
  Color backgroundColor;
  Color textColor;
  String fontFamily;
  int fontSize;
  double marginLeft;
  double marginRight;
  double marginTop;
  double marginBottom;
  String orientation;
  String printCopy;
  bool isPreparedBy;
  bool isCheckedBy;
  bool isAuthSign;
  Uint8List? preparedBySignature;
  Uint8List? checkedBySignature;
  Uint8List? authorizedSignatory;
  FieldSettings fieldSettings;
  TemplateType templateType;

  PdfSettings({
    this.isAuthSign = false,
    this.isCheckedBy = false,
    this.isPreparedBy = false,
    this.preparedBySignature,
    this.checkedBySignature,
    this.authorizedSignatory,
    this.orientation = 'Portrait',
    this.fontSize = 8,
    this.logoSize = 80,
    this.backgroundColor = Colors.blueAccent,
    this.fontFamily = 'Mulish',
    this.logoAlign = 'Left',
    this.marginBottom = 16,
    this.marginLeft = 16,
    this.marginRight = 16,
    this.marginTop = 16,
    this.printCopy = '2',
    this.fieldSettings = const FieldSettings(),
    this.textColor = Colors.white,
    this.templateType = TemplateType.standard1,
  });
}

class FieldSettings {
  final bool shippingAddress,
      dispatchAddress,
      itemCode,
      hsn,
      uom,
      qty,
      description,
      unitDiscount,
      unitFreight,
      unitDelivery,
      poNumber,
      poDate,
      gstin,
      pan,
      placeOfSupply,
      validTill,
      deliveryDate,
      ewayBillNumber,
      ewayBillDate,
      transportDetails,
      bankDetails,
      notes,
      termAndCondition,
      qrCode;

  const FieldSettings(
      {this.itemCode = false,
      this.notes = false,
      this.bankDetails = false,
      this.dispatchAddress = false,
      this.ewayBillDate = false,
      this.ewayBillNumber = false,
      this.hsn = false,
      this.poDate = false,
      this.poNumber = false,
      this.qrCode = false,
      this.shippingAddress = false,
      this.termAndCondition = false,
      this.transportDetails = false,
      this.uom = false,
      this.qty = false,
      this.description = false,
      this.unitDelivery = false,
      this.unitDiscount = false,
      this.unitFreight = false,
      this.gstin = false,
      this.pan = false,
      this.validTill = false,
      this.deliveryDate = false,
      this.placeOfSupply = false});

  factory FieldSettings.fromMap(Map<String, dynamic> map,
      {bool isSaleInvoice = false}) {
    return FieldSettings(
      shippingAddress: map['shipping_address'] == 1,
      bankDetails: map['bank_details'] == 1,
      dispatchAddress: map['dispatch_address'] == 1,
      ewayBillDate: map['eway_bill_date'] == 1,
      ewayBillNumber: map['eway_bill_number'] == 1,
      hsn: map['hsn'] == 1,
      itemCode: map['item_code'] == 1,
      notes: map['notes'] == 1,
      poDate: map['po_date'] == 1,
      poNumber: map['po_number'] == 1,
      qrCode: map['qr_code'] == 1,
      termAndCondition: map['term_condition'] == 1,
      transportDetails: map['transport_details'] == 1,
      uom: map['uom'] == 1,
      qty: map['qty'] == 1,
      description: map['description'] == 1,
      unitDiscount: map['unit_discount'] == 1,
      unitFreight: map['unit_freight'] == 1,
      unitDelivery: map['unit_delivery'] == 1,
      validTill: map['valid_till'] == 1,
      deliveryDate: map['delivery_date'] == 1,
      gstin: isSaleInvoice ? true : map['gstin'] == 1,
      pan: isSaleInvoice ? true : map['pan'] == 1,
      placeOfSupply: isSaleInvoice ? true : map['place_of_supply'] == 1,
    );
  }
}
