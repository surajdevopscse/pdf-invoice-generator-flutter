import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import '../../models/barcode_model.dart';

class BarcodeTemplateSecond {
  final List<BarcodeModel> data;
  BarcodeTemplateSecond({required this.data});

  /// FONTS
  late Font valuesFont;
  late Font labelFont;

  /// FONT SIZE
  double valuesFontSize = 3; // Smaller font size
  double labelFontSize = 4; // Slightly larger for labels

  /// FONT COLOR
  PdfColor valueColor = PdfColors.black;
  PdfColor labelColor = PdfColors.grey700;

  Future<void> setFontFamily(String fontFamily) async {
    // Load fonts (use compact and clear fonts for better readability)
    valuesFont = await PdfGoogleFonts.robotoRegular();
    labelFont = await PdfGoogleFonts.robotoBold();
  }

  Future<Document> getBarcodePdf() async {
    final barcode = Document();
    for (var item in data) {
      await setFontFamily(item.fontFamily);
      barcode.addPage(
        Page(
          pageFormat: const PdfPageFormat(
            17 * PdfPageFormat.mm,
            10 * PdfPageFormat.mm,
          ),
          margin: EdgeInsets.zero,
          build: (context) {
            return barcodeView(item);
          },
        ),
      );
    }
    // barcode.addPage(
    //   Page(
    //     pageFormat: const PdfPageFormat(
    //       17 * PdfPageFormat.mm,
    //       10 * PdfPageFormat.mm,
    //     ),
    //     margin: EdgeInsets.zero,
    //     build: (context) {
    //       return barcodeView();
    //     },
    //   ),
    // );
    return barcode;
  }

  Widget barcodeView(BarcodeModel data) {
    return SizedBox(
      width: 17 * PdfPageFormat.mm,
      height: 10 * PdfPageFormat.mm,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Wt: ",
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
                    text: data.price,
                    style: TextStyle(
                      font: valuesFont,
                      fontSize: valuesFontSize,
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    text: data.itemCode,
                    style: TextStyle(
                      font: valuesFont,
                      fontSize: valuesFontSize,
                    ),
                  ),
                ),
              ],
            ),
            if (data.itemName != null && data.itemName!.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RichText(
                    text: TextSpan(
                      text: data.itemName,
                      style: TextStyle(
                        font: valuesFont,
                        fontSize: valuesFontSize,
                      ),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: data.goldPurity,
                      style: TextStyle(
                        font: valuesFont,
                        fontSize: valuesFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            SizedBox(height: 2),
            BarcodeWidget(
              data: data.barCode,
              width: double.infinity,
              height: 4 * PdfPageFormat.mm, // Reduced barcode height
              drawText: data.showNumber,
              barcode: Barcode.ean13(),
            )
          ],
        ),
      ),
    );
  }
}
