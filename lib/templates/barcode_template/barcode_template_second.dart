import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

import '../../models/barcode_model.dart';

class BarcodeTemplateSecond {
  final BarcodeModel data;
  BarcodeTemplateSecond({required this.data});

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

  // setFontFamily(String fontFamily) async {
  //   if (fontFamily == 'Poppins') {
  //     titleFont = await PdfGoogleFonts.mochiyPopPOneRegular();
  //     subTitleFont = await PdfGoogleFonts.mochiyPopPOneRegular();
  //     invoiceNumberFont = await PdfGoogleFonts.mochiyPopPOneRegular();
  //     invoiceDateFont = await PdfGoogleFonts.mochiyPopPOneRegular();
  //     valuesFont = await PdfGoogleFonts.mochiyPopPOneRegular();
  //     labelFont = await PdfGoogleFonts.mochiyPopPOneRegular();
  //     extraBoldFont = await PdfGoogleFonts.mochiyPopPOneRegular();
  //   } else {
  //     titleFont = await PdfGoogleFonts.mulishRegular();
  //     invoiceNumberFont = await PdfGoogleFonts.mulishRegular();
  //     subTitleFont = await PdfGoogleFonts.mulishRegular();
  //     invoiceDateFont = await PdfGoogleFonts.mulishRegular();
  //     valuesFont = await PdfGoogleFonts.mulishRegular();
  //     labelFont = await PdfGoogleFonts.mulishRegular();
  //     extraBoldFont = await PdfGoogleFonts.mulishRegular();
  //   }
  // }
  setFontFamily(String fontFamily) async {
    titleFont = await PdfGoogleFonts.robotoRegular();
    subTitleFont = await PdfGoogleFonts.robotoRegular();
    invoiceNumberFont = await PdfGoogleFonts.robotoRegular();
    invoiceDateFont = await PdfGoogleFonts.robotoRegular();
    valuesFont = await PdfGoogleFonts.robotoRegular();
    labelFont = await PdfGoogleFonts.robotoRegular();
    extraBoldFont = await PdfGoogleFonts.robotoRegular();
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
          Padding(
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Wt : ",
                        style: TextStyle(
                          font: labelFont,
                          fontSize: labelFontSize,
                        ),
                      ),
                      TextSpan(
                        text: data.weight,
                        style: TextStyle(
                          font: valuesFont,
                          fontSize: valuesFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: data.price,
                        style: TextStyle(
                            font: valuesFont, fontSize: valuesFontSize),
                      ),
                    ],
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: data.itemCode,
                        style: TextStyle(
                            font: valuesFont, fontSize: valuesFontSize),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (data.itemName != null && data.itemName!.isNotEmpty)
            Padding(
              padding: EdgeInsets.zero,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: data.itemName,
                          style: TextStyle(
                            font: valuesFont,
                            fontSize: valuesFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: data.goldPurity,
                          style: TextStyle(
                              font: valuesFont, fontSize: valuesFontSize),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: BarcodeWidget(
              data: data.barCode,
              width: double.infinity,
              height: data.nutrition.isNotEmpty ? 12 : 32,
              drawText: data.showNumber,
              barcode: Barcode.ean13(),
            ),
          )
        ],
      ),
    );
  }
}
