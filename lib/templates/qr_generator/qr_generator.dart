import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';

import '../../models/qr_model.dart';

class QRGenerator {
  static Future<pw.Document> getPdf(QRDataModel data) async {
    final pdf = pw.Document();
    final qr = await _QRBuilder._build(data);
    List<pw.Widget> childrenWidgets = [];
    childrenWidgets = [qr];
    pdf.addPage(
      pw.MultiPage(
        pageFormat: data.settings!.orientation == 'Portrait'
            ? PdfPageFormat.a4
            : PdfPageFormat.a4.copyWith(
                width: PdfPageFormat.a4.height, height: PdfPageFormat.a4.width),
        footer: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.bottomRight,
              child: pw.Text(
                  '${context.pageNumber} of ${context.pagesCount} Page',
                  style: const pw.TextStyle(fontSize: 6)));
        },
        margin: pw.EdgeInsets.only(
            left: data.settings!.marginLeft,
            right: data.settings!.marginRight,
            top: data.settings!.marginTop,
            bottom: data.settings!.marginBottom),
        build: (pw.Context context) {
          return childrenWidgets; // Center
        },
      ),
    );

    return pdf;
  }
}

const borderWidth = 0.6;
const borderWidth2 = 1.0;

extension _QRBuilder on QRGenerator {
  static Future<pw.Widget> _build(QRDataModel data) async {
    return pw.Container(
        child:
            pw.GridView(childAspectRatio: 0.75, crossAxisCount: 3, children: [
      ...data.qrList!.map((e) => pw.Container(
            decoration: pw.BoxDecoration(
              border: Border.all(
                width: 1,
              ),
            ),
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  SvgImage(
                    fit: pw.BoxFit.fitWidth,
                    svg: Barcode.qrCode().toSvg(e.link ?? ""),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(e.title ?? '',
                      maxLines: 3, style: const pw.TextStyle(fontSize: 8)),
                ]),
          ))
    ]));
  }
}
