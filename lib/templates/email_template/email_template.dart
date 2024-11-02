import 'package:flutter/services.dart';
import 'package:invoice_generator/models/email_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

class EmailTemplate {
  final EmailModel emailModel;

  EmailTemplate({required this.emailModel});

  ///FONTS
  late Font titleFont;
  late Font subTitleFont;
  late Font invoiceNumberFont;
  late Font invoiceDateFont;
  late Font valuesFont;
  late Font labelFont;
  late Font extraBoldFont;

  ///FONT SIZE
  double titleFontSize = 16;
  double valuesFontSize = 10;
  double labelFontSize = 12;
  double extraBoldFontSize = 14;

  ///FONT COLOR
  PdfColor valueColor = PdfColors.grey100;
  PdfColor labelColor = PdfColors.grey500;

  setFontFamily() async {
    titleFont = await PdfGoogleFonts.mulishBold();
    invoiceNumberFont = await PdfGoogleFonts.mulishBold();
    subTitleFont = await PdfGoogleFonts.mulishSemiBold();
    invoiceDateFont = await PdfGoogleFonts.mulishRegular();
    valuesFont = await PdfGoogleFonts.mulishRegular();
    labelFont = await PdfGoogleFonts.mulishSemiBold();
    extraBoldFont = await PdfGoogleFonts.mulishExtraBold();
  }

  Future<Document> getEmailPdf() async {
    final email = Document();

    await setFontFamily();

    String image = await rootBundle.loadString('assets/icons/hb_power.svg');

    email.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.symmetric(horizontal: 64, vertical: 16),
        build: (context) {
          return [
            header(),
            separator(),
            emailContent(),
            separator(),
            invoiceSection(),
            SizedBox(height: 32),
            taxSection(),
            SizedBox(height: 16),
            buttonSectionWidget(),
            SizedBox(height: 32),
            hbPowerWidget(image)
          ]; // Center
        },
      ),
    );

    return email;
  }

  Widget header() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          RichText(
              text: TextSpan(
                  text: 'Document Amount : ',
                  style: TextStyle(font: valuesFont, fontSize: valuesFontSize),
                  children: [
                TextSpan(
                    text: emailModel.invoiceDetail.txnAmount,
                    style: TextStyle(fontSize: labelFontSize, font: labelFont))
              ])),
          Spacer(),
          if (emailModel.invoiceDetail.otherDate != null)
            RichText(
                text: TextSpan(
                    text: 'Document Due Date : ',
                    style:
                        TextStyle(font: valuesFont, fontSize: valuesFontSize),
                    children: [
                  TextSpan(
                      text: emailModel.invoiceDetail.otherDate,
                      style:
                          TextStyle(fontSize: labelFontSize, font: labelFont))
                ])),
        ]));
  }

  Widget separator() {
    return Container(
        height: 1,
        width: double.infinity,
        color: PdfColors.grey200,
        margin: const EdgeInsets.symmetric(vertical: 8));
  }

  Widget emailContent() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: RichText(
              text: TextSpan(
                  text: 'Thanks for choosing ',
                  style: TextStyle(fontSize: titleFontSize, font: subTitleFont),
                  children: [
                TextSpan(
                    text: emailModel.businessName,
                    style: TextStyle(
                        font: titleFont,
                        fontSize: titleFontSize,
                        color: PdfColors.blueAccent))
              ]))),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
            '${emailModel.greeting},\n${emailModel.contactName}\n${emailModel.body}',
            style: TextStyle(font: valuesFont, fontSize: valuesFontSize)),
      ),
    ]);
  }

  Widget invoiceSection() {
    return Column(children: [
      invoiceField('Document Number', emailModel.invoiceDetail.txnNumber,
          emailModel.emailSettings.showTxnNumber),
      invoiceField('Document Date', emailModel.invoiceDetail.txnDate,
          emailModel.emailSettings.showTxnDate),
      invoiceField('Total Amount', emailModel.invoiceDetail.txnAmount,
          emailModel.emailSettings.showTxnAmount),
      invoiceField('Amount Received', emailModel.invoiceDetail.received,
          emailModel.emailSettings.showReceivedAmount),
      invoiceField('Amount Unpaid', emailModel.invoiceDetail.balanceDue,
          emailModel.emailSettings.showBalanceDue),
      invoiceField('Current Status', emailModel.invoiceDetail.status, true),
    ]);
  }

  Widget taxSection() {
    return Column(children: [
      taxField('Taxable Value', emailModel.invoiceDetail.taxableValue),
      taxField('CGST', emailModel.invoiceDetail.cgstAmount),
      taxField('SGST', emailModel.invoiceDetail.sgstAmount),
      taxField('IGST', emailModel.invoiceDetail.igstAmount),
      taxField('CESS', emailModel.invoiceDetail.cessAmount),
      separator(),
      taxField('Total', emailModel.invoiceDetail.txnAmount, isBold: true),
    ]);
  }

  Widget taxField(String label, String value, {bool isBold = false}) {
    return Row(children: [
      Expanded(
          child: Text(label,
              textAlign: TextAlign.left,
              style: TextStyle(
                font: (isBold) ? labelFont : valuesFont,
                fontSize: extraBoldFontSize,
              ))),
      Expanded(
          child: Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(
                font: (isBold) ? labelFont : valuesFont,
                fontSize: extraBoldFontSize,
              ))),
    ]);
  }

  Widget invoiceField(String label, String value, bool visible) {
    if (!visible) return SizedBox();

    return Row(children: [
      Expanded(
          child: Text(label,
              style: TextStyle(
                font: valuesFont,
                fontSize: valuesFontSize,
              ))),
      Text(':  '),
      Expanded(
          child: Text(value,
              textAlign: TextAlign.left,
              style: TextStyle(
                font: valuesFont,
                fontSize: valuesFontSize,
              ))),
    ]);
  }

  Widget buttonSectionWidget() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (emailModel.emailSettings.viewInvoice)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: PdfColors.blueAccent,
          ),
          child: Text('View Document',
              style: const TextStyle(color: PdfColors.white)),
        ),
      SizedBox(width: 16),
      if (emailModel.emailSettings.showPayNow)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          width: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: PdfColors.lightGreen,
          ),
          child:
              Text('Pay Now', style: const TextStyle(color: PdfColors.white)),
        ),
    ]);
  }

  Widget hbPowerWidget(String image) {
    if (!emailModel.emailSettings.showHbPower) {
      return SizedBox();
    }

    return Container(child: SvgImage(svg: image));
  }
}
