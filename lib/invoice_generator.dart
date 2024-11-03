import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:invoice_generator/enums/template_type.dart';
import 'package:invoice_generator/models/barcode_model.dart';
import 'package:invoice_generator/models/email_model.dart';
import 'package:invoice_generator/models/fnb_invoice_model.dart';
import 'package:invoice_generator/models/pdf_settings.dart';
import 'package:invoice_generator/templates/barcode_template/barcode_template_second.dart';
import 'package:invoice_generator/templates/email_template/email_template.dart';
import 'package:invoice_generator/templates/fbn_invoice_template/fbn_invoice_template.dart';
import 'package:invoice_generator/templates/qr_generator/qr_generator.dart';
import 'package:invoice_generator/templates/receipt_templates/e_receipt_template.dart';
import 'package:invoice_generator/templates/tax_template/half_print.dart';
import 'package:invoice_generator/templates/tax_template/half_print_non_gst.dart';
import 'package:invoice_generator/templates/tax_template/tax_template_1.dart';
import 'package:invoice_generator/templates/tax_template/tax_template_2.dart';
import 'package:invoice_generator/templates/tax_template/tax_template_3.dart';
import 'package:invoice_generator/templates/tax_template/tax_template_4.dart';
import 'package:invoice_generator/templates/tax_template/tax_template_5.dart';
import 'package:invoice_generator/templates/tax_template/tax_template_6.dart';
import 'package:invoice_generator/templates/tax_template/tax_template_7.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import 'models/qr_model.dart';
import 'templates/barcode_template/barcode_template.dart';
import 'templates/invoice_templates/e_invoice_template.dart';
import 'templates/invoice_templates/thermal_invoice_template.dart';
import 'templates/journal_templates/e_journal_template.dart';

part 'models/invoice_models.dart';
part 'models/journal_models.dart';
part 'models/receipt_models.dart';

class PrintGenerator {
  PrintGenerator._privateConstructor();
  static final PrintGenerator instance = PrintGenerator._privateConstructor();

  Future<Uint8List> generateEmail(EmailModel data) async {
    final pdf = await EmailTemplate(emailModel: data).getEmailPdf();
    return pdf.save();
  }

  Future<Uint8List> generateEInvoice(InvoiceModel data) async {
    Document pdf;
    if (data.settings.templateType == TemplateType.standard) {
      pdf = await EInvoiceTemplate.getPdf(data);
    } else if (data.settings.templateType == TemplateType.standard1) {
      pdf = await TaxTemplate1.getPdf(data);
    } else if (data.settings.templateType == TemplateType.standard2) {
      pdf = await TaxTemplate2.getPdf(data);
    } else if (data.settings.templateType == TemplateType.standard3) {
      pdf = await TaxTemplate7.getPdf(data);
    } else if (data.settings.templateType == TemplateType.standard4) {
      pdf = await TaxTemplate4.getPdf(data);
    } else if (data.settings.templateType == TemplateType.standard5) {
      pdf = await TaxTemplate5.getPdf(data);
    } else if (data.settings.templateType == TemplateType.standard6) {
      pdf = await TaxTemplate6.getPdf(data);
    } else if (data.settings.templateType == TemplateType.standard7) {
      pdf = await TaxTemplate3.getPdf(data);
    } else if (data.settings.templateType == TemplateType.halfPrint) {
      pdf = await HalfPrint.getPdf(data);
    } else if (data.settings.templateType == TemplateType.halfPrintNonGST) {
      pdf = await HalfPrintNonGst.getPdf(data);
    } else {
      pdf = await EInvoiceTemplate.getPdf(data);
    }

    return pdf.save();
  }

  Future<Uint8List> generateThermalInvoice(InvoiceModel data) async {
    ThermalInvoiceTemplate.fallbackFont = await PdfGoogleFonts.lateefRegular();
    final pdf = await ThermalInvoiceTemplate.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> generateEJournal(JournalModel data) async {
    final pdf = await EJournalTemplate.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> generateEReceipt(ReceiptModel data) async {
    final pdf = await EReceiptTemplate.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> generateEBarcode(BarcodeModel data) async {
    if (!Barcode.ean13().isValid(data.barCode)) {
      throw Exception('Barcode should be in EAN13 format');
    }

    final pdf = await BarcodeTemplate(data: data).getBarcodePdf();
    return pdf.save();
  }

  Future<Uint8List> generateEBarcodeSecond(BarcodeModel data) async {
    if (!Barcode.ean13().isValid(data.barCode)) {
      throw Exception('Barcode should be in EAN13 format');
    }

    final pdf = await BarcodeTemplateSecond(data: data).getBarcodePdf();
    return pdf.save();
  }

  Future<Uint8List> generateETax(InvoiceModel data) async {
    final pdf = await TaxTemplate1.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> generateETax2(InvoiceModel data) async {
    final pdf = await TaxTemplate2.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> generateETax3(InvoiceModel data) async {
    final pdf = await TaxTemplate3.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> generateETax4(InvoiceModel data) async {
    final pdf = await TaxTemplate4.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> generateETax5(InvoiceModel data) async {
    final pdf = await TaxTemplate5.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> generateETax6(InvoiceModel data) async {
    final pdf = await TaxTemplate6.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> generateETax7(InvoiceModel data) async {
    final pdf = await TaxTemplate7.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> halfPrint(InvoiceModel data) async {
    final pdf = await HalfPrint.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> qrGenerator(QRDataModel data) async {
    final pdf = await QRGenerator.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> halfPrintNonGst(InvoiceModel data) async {
    final pdf = await HalfPrintNonGst.getPdf(data);
    return pdf.save();
  }

  Future<Uint8List> fnbInvoiceTemplate({
    required List itemList,
    required List gstBreakupList,
    required String orderNo,
    required String billNo,
    required String waiterName,
    required String customerPhone,
    required String customerName,
    required String customerAddress,
    required String companyName,
    required String address,
    required String companyPhoneNo,
    required String companyGstin,
    required String branchFssaiNo,
    required String mergeTableList,
    required String paymentStatus,
    required String customerGst,
    required String roundOffValue,
    required String qrcode,
    required String noOfPerson,
    required String totalOrderDiscount,
    required String showGstBreakup,
    required String dateTime,
  }) async {
    // await FnbInvoiceTemplate.setFonts();
    final pdf = await FnbInvoiceTemplate.getFbnInvoice(
      orderNo: orderNo,
      billNo: billNo,
      itemList: itemList,
      gstBreakupList: gstBreakupList,
      waiterName: waiterName,
      customerPhone: customerPhone,
      customerName: customerName,
      customerAddress: customerAddress,
      companyName: companyName,
      address: address,
      branchFssaiNo: branchFssaiNo,
      companyGstin: companyGstin,
      companyPhoneNo: companyPhoneNo,
      mergeTableList: mergeTableList,
      paymentStatus: paymentStatus,
      customerGst: customerGst,
      roundOffValue: roundOffValue,
      qrcode: qrcode,
      noOfPerson: noOfPerson,
      totalOrderDiscount: totalOrderDiscount,
      showGstBreakup: showGstBreakup,
      dateTime: dateTime,
    );
    return pdf.save();
  }
}
