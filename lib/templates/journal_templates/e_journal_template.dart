import 'package:invoice_generator/invoice_generator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// Mark: E-Journal Template
// ================================
class EJournalTemplate {
  static Future<pw.Document> getPdf(JournalModel data) async {
    final pdf = pw.Document();
    for (var i = 0; i < data.slicedItems.length; i++) {
      final header = await _HeaderBuilder._build(data);
      final itemsBlock = await _ItemListBuilder._build(
          i, data, data.slicedItems[i], (i == data.slicedItems.length - 1));
      final footer = await _FooterBuilder._build("");
      List<pw.Widget> childrenWidgets = [
        i == 0 ? header : pw.Container(),
        i == 0 ? pw.SizedBox(height: 25) : pw.Container(),
        itemsBlock,
      ];
      // if (i < data.slicedItems.length - 1) {
      //   childrenWidgets = [
      //     header,
      //     pw.SizedBox(height: 20),
      //     addressBlock,
      //     pw.SizedBox(height: 25),
      //     itemsBlock,
      //   ];
      // } else {
      //   childrenWidgets = [
      //     header,
      //     pw.SizedBox(height: 20),
      //     addressBlock,
      //     pw.SizedBox(height: 25),
      //     itemsBlock,
      //   ];
      // }
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                ...childrenWidgets,
                pw.Spacer(),
                if (i == data.slicedItems.length - 1) footer,
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text("Page No. ${++i} of ${data.slicedItems.length}"),
                  ],
                ),
              ],
            ); // Center
          },
        ),
      );
    }
    return pdf;
  }
}
pw.RichText customLabelValue(
    {required String label,
    required String? value,
    required pw.Font labelFont,
    required pw.Font valuesFont}) {
  return pw.RichText(
    text: pw.TextSpan(
      text: label,
      style: pw.TextStyle(
        font: labelFont,
        fontSize: 9,
      ),
      children: [
        pw.TextSpan(
          text: value ?? 'N/A',
          style: pw.TextStyle(
            font: valuesFont,
            fontSize: 9,
          ),
        ),
      ],
    ),
  );
}
// Mark: Header Builder Extension
// ================================
extension _HeaderBuilder on EJournalTemplate {
  static Future<pw.Widget> _build(JournalModel data) async {
    final logo =
        (data.logoBytes != null) ? (pw.MemoryImage(data.logoBytes!)) : null;
    final titleFont = await PdfGoogleFonts.openSansBold();
    final invoiceNumberFont = await PdfGoogleFonts.openSansBold();
    final invoiceDateFont = await PdfGoogleFonts.openSansRegular();
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildTopHeader(logo, titleFont),
        _buildSubHeader(
            data.id,
            data.date,
            data.gstin,
            data.narration,
            data.autoReversingDate,
            invoiceNumberFont,
            invoiceDateFont,
            data.gstin),
      ],
    );
  }
  static pw.Row _buildTopHeader(pw.ImageProvider? logo, pw.Font titleFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: (logo != null)
              ? pw.Container(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Image(
                    logo,
                    fit: pw.BoxFit.scaleDown,
                    height: 20,
                  ),
                )
              : pw.Container(),
        ),
        pw.Expanded(
          child: pw.Container(
            height: 30,
            child: pw.Text(
              "Journal",
              style: pw.TextStyle(
                font: titleFont,
                fontSize: 14,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Container(),
        ),
      ],
    );
  }
  static pw.Widget _buildSubHeader(
      String journalNumber,
      String date,
      String gst,
      String narration,
      String autoReversingDate,
      pw.Font invoiceNumberFont,
      pw.Font invoiceDateFont,
      String companyGstin) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 20),
            customLabelValue(
              labelFont: invoiceNumberFont,
              label: "Journal No.: ",
              value: journalNumber,
              valuesFont: invoiceDateFont,
            ),
            pw.SizedBox(height: 5),
            customLabelValue(
              labelFont: invoiceNumberFont,
              label: "Order Date: ",
              value: date,
              valuesFont: invoiceDateFont,
            ),
          ],
        ),
        pw.Spacer(),
        pw.Container(
          width: 180,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),
              pw.RichText(
                text: pw.TextSpan(
                  text: "Company GSTIN: ",
                  children: [
                    pw.TextSpan(
                      text: companyGstin,
                      style: pw.TextStyle(
                        font: invoiceDateFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    )
                  ],
                  style: pw.TextStyle(
                    font: invoiceNumberFont,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.RichText(
                text: pw.TextSpan(
                  text: "Narration: ",
                  children: [
                    pw.TextSpan(
                      text: narration,
                      style: pw.TextStyle(
                        font: invoiceDateFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    )
                  ],
                  style: pw.TextStyle(
                    font: invoiceNumberFont,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.RichText(
                text: pw.TextSpan(
                  text: "Auto Reversing Date: ",
                  children: [
                    pw.TextSpan(
                      text: autoReversingDate,
                      style: pw.TextStyle(
                        font: invoiceDateFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.normal,
                      ),
                    )
                  ],
                  style: pw.TextStyle(
                    font: invoiceNumberFont,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
// Mark: Item List Builder Functions Extension
// =============================================
extension _ItemListBuilder on EJournalTemplate {
  static Future<pw.Widget> _build(int currentIndex, JournalModel data,
      List<JournalItemModel> items, bool isLastIndex) async {
    final titleFont = await PdfGoogleFonts.openSansSemiBold();
    final symbolFont = await PdfGoogleFonts.openSansBold();
    return pw.Column(children: [
      currentIndex != 0
          ? pw.Container()
          : _buildTile(
              titleFont,
              symbolFont,
              null,
              isHeader: true,
            ),
      ...List.generate(items.length + (isLastIndex ? 1 : 0), (i) {
        final colorIndex = (items.length + 1 % 2 == 0) ? i : i + 1;
        if (i < items.length) {
          // return pw.Container();
          return _buildTile(
            titleFont,
            symbolFont,
            (colorIndex % 2 == 0) ? PdfColors.white : PdfColors.grey100,
            isHeader: false,
            index: currentIndex + i + 1,
            model: items.elementAt(i),
          );
        } else {
          return _buildFooterTile(
            symbolFont,
            (colorIndex % 2 == 0) ? PdfColors.white : PdfColors.grey100,
            data,
          );
        }
      }),
    ]);
  }
  static pw.Container _buildTile(
    pw.Font titleFont,
    pw.Font fallbackFont,
    PdfColor? backgroundColor, {
    required bool isHeader,
    int? index,
    JournalItemModel? model,
  }) {
    return pw.Container(
      height: isHeader ? 24 : 30,
      decoration: pw.BoxDecoration(
        color: isHeader ? PdfColors.blue : backgroundColor,
        border: const pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey100,
            width: 1,
          ),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              isHeader ? "#" : model!.index.toString(),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                font: titleFont,
                fontFallback: [fallbackFont],
                color: isHeader ? PdfColors.white : PdfColors.black,
                fontSize: 8,
              ),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              isHeader ? "Description" : model?.description ?? "",
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                font: titleFont,
                fontFallback: [fallbackFont],
                color: isHeader ? PdfColors.white : PdfColors.black,
                fontSize: 8,
              ),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              isHeader ? "Account" : model?.account ?? "",
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                font: titleFont,
                fontFallback: [fallbackFont],
                color: isHeader ? PdfColors.white : PdfColors.black,
                fontSize: 8,
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              isHeader ? "Debit INR" : model?.debitAmount ?? "",
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: titleFont,
                fontFallback: [fallbackFont],
                color: isHeader ? PdfColors.white : PdfColors.black,
                fontSize: 8,
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              isHeader ? "Credit INR" : model?.creditAmount ?? "",
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: titleFont,
                fontFallback: [fallbackFont],
                color: isHeader ? PdfColors.white : PdfColors.black,
                fontSize: 8,
              ),
            ),
          ),
          pw.SizedBox(width: 15),
        ],
      ),
    );
  }
  static pw.Container _buildFooterTile(
    pw.Font titleFont,
    PdfColor backgroundColor,
    JournalModel model,
  ) {
    return pw.Container(
      height: 40,
      decoration: pw.BoxDecoration(
        color: backgroundColor,
        border: const pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey100,
            width: 1,
          ),
        ),
      ),
      child: pw.Row(
        children: [
          pw.Expanded(flex: 1, child: pw.Text("")),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              "Total",
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                font: titleFont,
                color: PdfColors.black,
                fontSize: 8,
              ),
            ),
          ),
          pw.Expanded(flex: 3, child: pw.Text("")),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              model.totalDebitAmount,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: titleFont,
                color: PdfColors.black,
                fontSize: 8,
              ),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              model.totalCreditAmount,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: titleFont,
                color: PdfColors.black,
                fontSize: 8,
              ),
            ),
          ),
          pw.SizedBox(width: 15),
        ],
      ),
    );
  }
}
// Mark: Footer Builder Functions Extension
// =============================================
extension _FooterBuilder on EJournalTemplate {
  static Future<pw.Widget> _build(String termsLink) async {
    final titleFont = await PdfGoogleFonts.openSansBold();
    final termsFont = await PdfGoogleFonts.openSansRegular();
    final termsBoldFont = await PdfGoogleFonts.openSansBold();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Container(
          height: 30,
          child: pw.Text(
            "Authorized Signatory",
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              font: titleFont,
              color: PdfColors.black,
              fontSize: 12,
            ),
          ),
        ),
        pw.Row(
          children: [
            pw.Container(
              height: 30,
              child: pw.Text(
                "Terms & Conditions *",
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: titleFont,
                  color: PdfColors.blue300,
                  fontSize: 8,
                ),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Container(
              height: 30,
              child: pw.RichText(
                text: pw.TextSpan(
                  text: termsLink,
                  annotation: pw.AnnotationLink(termsLink),
                  style: pw.TextStyle(
                    font: titleFont,
                    color: PdfColors.black,
                    fontSize: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
