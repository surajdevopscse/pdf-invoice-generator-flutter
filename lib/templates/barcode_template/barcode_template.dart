import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import '../../models/barcode_model.dart';

class BarcodeTemplate {
  final BarcodeModel data;
  BarcodeTemplate({required this.data});

  ///FONTS
  late Font titleFont;
  late Font subTitleFont;
  late Font invoiceNumberFont;
  late Font invoiceDateFont;
  late Font valuesFont;
  late Font labelFont;
  late Font extraBoldFont;

  ///FONT SIZE
  double titleFontSize = 14;
  double valuesFontSize = 8;
  double labelFontSize = 10;
  double extraBoldFontSize = 10;

  ///FONT COLOR
  PdfColor valueColor = PdfColors.grey100;
  PdfColor labelColor = PdfColors.grey500;

  setFontFamily(String fontFamily) async {
    if (fontFamily == 'Poppins') {
      titleFont = await PdfGoogleFonts.mochiyPopPOneRegular();
      subTitleFont = await PdfGoogleFonts.mochiyPopPOneRegular();
      invoiceNumberFont = await PdfGoogleFonts.mochiyPopPOneRegular();
      invoiceDateFont = await PdfGoogleFonts.mochiyPopPOneRegular();
      valuesFont = await PdfGoogleFonts.mochiyPopPOneRegular();
      labelFont = await PdfGoogleFonts.mochiyPopPOneRegular();
      extraBoldFont = await PdfGoogleFonts.mochiyPopPOneRegular();
    } else {
      titleFont = await PdfGoogleFonts.mulishRegular();
      invoiceNumberFont = await PdfGoogleFonts.mulishRegular();
      subTitleFont = await PdfGoogleFonts.mulishRegular();
      invoiceDateFont = await PdfGoogleFonts.mulishRegular();
      valuesFont = await PdfGoogleFonts.mulishRegular();
      labelFont = await PdfGoogleFonts.mulishRegular();
      extraBoldFont = await PdfGoogleFonts.mulishRegular();
    }
  }

  setFontSize(double size) {
    valuesFontSize = size;
    labelFontSize = size + 1;
    titleFontSize = 14;
    extraBoldFontSize = size + 2;
  }

  Future<Document> getBarcodePdf() async {
    await setFontFamily(data.fontFamily);

    setFontSize(data.fontSize.toDouble());

    final barcode = Document();
    barcode.addPage(
      MultiPage(
        pageFormat: PdfPageFormat(data.width * 2.55, PdfPageFormat.a4.height),
        margin: const EdgeInsets.only(top: 4),
        build: (context) {
          return [
            barcodeView(),
          ];
          // Center
        },
      ),
    );
    return barcode;
  }

  Widget barcodeView() {
    return Column(
        children: List.generate(data.count, (_) => barcodePreviewWidget()));
  }

  Widget barcodePreviewWidget() {
    return SizedBox(
        height: data.height * 2.55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.itemName != null && data.itemName!.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text(
                    data.itemName ?? '',
                    style: TextStyle(
                        font: extraBoldFont, fontSize: extraBoldFontSize),
                  )),
            if (data.ingredients != null && data.ingredients!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: "Ingredients :",
                        style: TextStyle(
                            font: labelFont, fontSize: labelFontSize)),
                    TextSpan(
                        text: data.ingredients,
                        style: TextStyle(
                            font: valuesFont, fontSize: valuesFontSize)),
                  ]),
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data.itemName != null &&
                          data.itemName!.isNotEmpty) ...[
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "Net Qty :",
                                style: TextStyle(
                                    font: labelFont, fontSize: labelFontSize)),
                            TextSpan(
                                text: data.netQyt,
                                style: TextStyle(
                                    font: valuesFont,
                                    fontSize: valuesFontSize)),
                          ]),
                        ),
                      ],
                      if (data.packedDate != null &&
                          data.packedDate!.isNotEmpty)
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "PKD :",
                                style: TextStyle(
                                    font: labelFont, fontSize: labelFontSize)),
                            TextSpan(
                                text: data.packedDate,
                                style: TextStyle(
                                    font: valuesFont,
                                    fontSize: valuesFontSize)),
                          ]),
                        ),
                      if (data.expDate != null && data.expDate!.isNotEmpty)
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: "EXP :",
                                style: TextStyle(
                                    font: labelFont, fontSize: labelFontSize)),
                            TextSpan(
                                text: data.expDate,
                                style: TextStyle(
                                    font: valuesFont,
                                    fontSize: valuesFontSize)),
                          ]),
                        ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: "MRP :",
                              style: TextStyle(
                                  font: labelFont, fontSize: labelFontSize)),
                          TextSpan(
                              text: data.price,
                              style: TextStyle(
                                  font: valuesFont, fontSize: valuesFontSize)),
                        ]),
                      ),
                      if (data.price != null &&
                          data.price!.isNotEmpty &&
                          data.taxInclusive != null)
                        Text(
                            '(${data.taxInclusive! ? 'Incl' : 'Excl'}.of all Taxes)',
                            style: TextStyle(
                                font: valuesFont, fontSize: valuesFontSize)),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Column(
                        children: [
                          if (data.nutrition.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              decoration: BoxDecoration(
                                  border: Border.all(color: PdfColors.black)),
                              child: Column(
                                children: [
                                  Text(
                                    'Nutrition value Per (100 G)',
                                    style: TextStyle(
                                        fontSize: valuesFontSize,
                                        font: valuesFont),
                                  ),
                                  Divider(
                                    color: PdfColors.black,
                                    height: 0.5,
                                  ),
                                  ...data.nutrition
                                      .map((e) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    child: Text(
                                                  e.name,
                                                  style: TextStyle(
                                                      fontSize: valuesFontSize,
                                                      font: valuesFont),
                                                )),
                                                Expanded(
                                                    child: Text(
                                                  e.value,
                                                  style: TextStyle(
                                                      fontSize: valuesFontSize,
                                                      font: valuesFont),
                                                  textAlign: TextAlign.right,
                                                )),
                                              ],
                                            ),
                                          ))
                                      .toList()
                                ],
                              ),
                            ),
                          BarcodeWidget(
                              data: data.barCode,
                              height: data.nutrition.isNotEmpty ? 12 : 32,
                              drawText: data.showNumber,
                              barcode: Barcode.ean13()),
                        ],
                      )),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data.packedBy != null && data.packedBy!.isNotEmpty)
                          Text(
                            data.packedBy ?? '',
                            style: TextStyle(
                                font: labelFont, fontSize: labelFontSize),
                          ),
                        if (data.phone.isNotEmpty)
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: "Phone : ",
                                  style: TextStyle(
                                      font: valuesFont,
                                      fontSize: labelFontSize)),
                              TextSpan(
                                  text: data.phone,
                                  style: TextStyle(
                                      font: valuesFont,
                                      fontSize: valuesFontSize)),
                            ]),
                          ),
                        if (data.customerCare != null &&
                            data.customerCare!.isNotEmpty)
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: "Customer care : ",
                                  style: TextStyle(
                                      font: valuesFont,
                                      fontSize: labelFontSize)),
                              TextSpan(
                                  text: data.customerCare,
                                  style: TextStyle(
                                      font: valuesFont,
                                      fontSize: valuesFontSize)),
                            ]),
                          ),
                        if (data.email != null && data.email!.isNotEmpty)
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: "E-mail : ",
                                  style: TextStyle(
                                      font: valuesFont,
                                      fontSize: labelFontSize)),
                              TextSpan(
                                  text: data.email,
                                  style: TextStyle(
                                      font: valuesFont,
                                      fontSize: valuesFontSize)),
                            ]),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 16,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (data.mfd != null && data.mfd!.isNotEmpty)
                          Text('MFD By : ${data.mfd!}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  font: valuesFont, fontSize: valuesFontSize)),
                        if (data.mkd != null && data.mkd!.isNotEmpty)
                          Text('MKD By : ${data.mkd!}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  font: valuesFont, fontSize: valuesFontSize)),
                        if (data.address != null && data.address!.isNotEmpty)
                          Text(data.address!,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  font: valuesFont, fontSize: valuesFontSize)),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
