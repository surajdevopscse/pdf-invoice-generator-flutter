import 'package:invoice_generator/invoice_generator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Mark: E-Receipt Template
// ================================
class EReceiptTemplate {
  static Future<pw.Document> getPdf(ReceiptModel data) async {
    final pdf = pw.Document();
    for (var i = 0; i < data.slicedItems.length; i++) {
      final header = await _HeaderBuilder._build(data);
      final addressBlock = await _AddressBlockBuilder._build(data);
      final totalAmountBlock = await _TotalAmountBlockBuilder._build(data);
      final itemsBlock = await _ItemListBuilder._build(
          data, data.slicedItems[i], (i == data.slicedItems.length - 1));
      final bankBlock = await _BankBuilder._build(data);
      final bankTransactionDetailsBlock =
          await _BankTransactionDetailsBuilder._build(data);
      final footerBlock =
          await _FooterBuilder._build(data.termsAndConditionsLink);
      List<pw.Widget> childrenWidgets = [];
      if (i < data.slicedItems.length - 1) {
        childrenWidgets = [
          header,
          pw.SizedBox(height: 20),
          addressBlock,
          pw.SizedBox(height: 25),
          itemsBlock,
        ];
      } else {
        childrenWidgets = [
          header,
          pw.SizedBox(height: 20),
          addressBlock,
          pw.SizedBox(height: 25),
          itemsBlock,
          totalAmountBlock,
          pw.SizedBox(height: 30),
          bankBlock,
          bankTransactionDetailsBlock,
          pw.SizedBox(height: 70),
        ];
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                ...childrenWidgets,
                pw.Spacer(),
                if (i == data.slicedItems.length - 1) footerBlock,
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

// Mark: Header Builder Extension
// ================================
extension _HeaderBuilder on EReceiptTemplate {
  static Future<pw.Widget> _build(ReceiptModel data) async {
    final logo =
        (data.logoBytes != null) ? (pw.MemoryImage(data.logoBytes!)) : null;
    final titleFont = await PdfGoogleFonts.poppinsBold();

    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildTopHeader(data.title, logo, titleFont),
      ],
    );
  }


  static pw.Row _buildTopHeader(
    String title,
    pw.ImageProvider? logo,
    pw.Font titleFont,
  ) {
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
              title,
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
}

// Mark: Address Block Builder Functions Extension
// =================================================
extension _AddressBlockBuilder on EReceiptTemplate {
  static Future<pw.Row> _build(ReceiptModel data) async {
    final titleFont = await PdfGoogleFonts.openSansBold();
    final valuesFont = await PdfGoogleFonts.openSansRegular();

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildAddress(
          "Billing Address",
          titleFont,
          data.buyer.billingAddress,
          valuesFont,
        ),
        pw.SizedBox(width: 5),
        _buildAddress(
          "Customer Address",
          titleFont,
          data.buyer.customerAddress,
          valuesFont,
        ),
        pw.SizedBox(width: 5),
        _buildReceiptDetails(
          data.id,
          data.date,
          titleFont,
          valuesFont,
        ),
      ],
    );
  }

  static pw.Expanded _buildAddress(
    String title,
    pw.Font titleFont,
    ReceiptAddressModel? data,
    pw.Font valuesFont,
  ) {
    return pw.Expanded(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              font: titleFont,
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 2.5),
          pw.Text(
            data?.address ?? "",
            style: pw.TextStyle(
              font: valuesFont,
              fontSize: 9,
            ),
          ),
          pw.SizedBox(height: 2.5),
          pw.Text(
            "Pincode: ${data?.pincode ?? "N/A"}",
            style: pw.TextStyle(
              font: valuesFont,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Expanded _buildReceiptDetails(
    String id,
    String date,
    pw.Font titleFont,
    pw.Font valuesFont,
  ) {
    return pw.Expanded(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Receipt No. : $id",
            style: pw.TextStyle(
              font: titleFont,
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 2.5),
          pw.Text(
            "Dated: $date",
            style: pw.TextStyle(
              font: valuesFont,
              fontSize: 9,
            ),
          ),
          pw.SizedBox(height: 2.5),
        ],
      ),
    );
  }
}

// Mark: Item List Builder Functions Extension
// =============================================
extension _ItemListBuilder on EReceiptTemplate {
  static Future<pw.Widget> _build(
      ReceiptModel data, List<ReceiptItemModel> items, bool isLastIndex) async {
    final titleFont = await PdfGoogleFonts.openSansSemiBold();
    final symbolFont = await PdfGoogleFonts.poppinsBold();

    return pw.Column(children: [
      _buildTile(titleFont, symbolFont, null,
          isHeader: true, modelSubType: data.modelSubType),
      ...List.generate(items.length, (i) {
        return _buildTile(titleFont, symbolFont, PdfColors.white,
            isHeader: false,
            index: i,
            model: items.elementAt(i),
            modelSubType: data.modelSubType);
      }),
    ]);
  }

  static pw.Container _buildTile(
      pw.Font titleFont, pw.Font fallbackFont, PdfColor? backgroundColor,
      {required bool isHeader,
      int? index,
      ReceiptItemModel? model,
      String? modelSubType}) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: isHeader ? PdfColors.blue : backgroundColor,
        border: const pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.grey200,
            width: 1,
          ),
        ),
      ),
      height: isHeader ? 24 : 30,
      child: pw.Row(
        children: [
          pw.Expanded(flex: 1, child: pw.Container()),
          pw.Expanded(
            flex: 4,
            child: pw.Text(
              isHeader
                  ? (modelSubType == 'RAC' ||
                          modelSubType == 'RAD' ||
                          modelSubType == 'PAC' ||
                          modelSubType == 'PAD')
                      ? "Particulars"
                      : modelSubType == 'RAB'
                          ? "Invoice No."
                          : 'Bill No.'
                  : model?.name ?? "",
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                font: titleFont,
                fontFallback: [fallbackFont],
                color: isHeader ? PdfColors.white : PdfColors.black,
                fontSize: 8,
              ),
            ),
          ),
          modelSubType == 'RAB' || modelSubType == 'PAB'
              ? pw.Expanded(
                  flex: 4,
                  child: pw.Text(
                    isHeader ? "Date" : model?.date ?? "",
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      font: titleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader ? PdfColors.white : PdfColors.black,
                      fontSize: 8,
                    ),
                  ),
                )
              : pw.Container(),
          (modelSubType == 'RAD') || (modelSubType == 'PAD')
              ? pw.Expanded(
                  flex: 3,
                  child: pw.Text(
                    isHeader ? "GST" : model?.gst ?? "",
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      font: titleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader ? PdfColors.white : PdfColors.black,
                      fontSize: 8,
                    ),
                  ),
                )
              : pw.Container(),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              isHeader ? "Amount" : model?.amount ?? "",
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
}

// Mark: Total Amount Block Builder Functions Extension
// =============================================
extension _TotalAmountBlockBuilder on EReceiptTemplate {
  static Future<pw.Widget> _build(ReceiptModel data) async {
    final font = await PdfGoogleFonts.poppinsBold();

    final titles = [
      "",
      if (data.sgstLabel.isNotEmpty) data.sgstLabel,
      data.cgstLabel.isNotEmpty ? data.cgstLabel : "",
      data.isReversedCharge != null ? "Reversed Charge" : "",
      data.unadjustedAmount.isEmpty ? "" : "Unadjusted Amount",
      "",
      "Total",
    ];
    final values = [
      "",
      if (data.sgstValue.isNotEmpty) data.sgstValue,
      data.cgstValue.isNotEmpty ? data.cgstValue : "",
      data.isReversedCharge != null
          ? ((data.isReversedCharge!) ? "Yes" : "No")
          : "",
      data.unadjustedAmount.isNotEmpty ? data.unadjustedAmount : "",
      "",
      data.totalAmount.isNotEmpty ? data.totalAmount : "",
    ];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisSize: pw.MainAxisSize.max,
          children: [
            pw.Expanded(
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: titles
                    .asMap()
                    .map((i, e) => MapEntry(i,
                        _buildItem("", font, titles.elementAt(i) == "Total")))
                    .values
                    .toList(),
              ),
            ),
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: titles
                  .asMap()
                  .map((i, e) => MapEntry(
                      i, _buildItem(e, font, titles.elementAt(i) == "Total")))
                  .values
                  .toList(),
            ),
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: values
                  .asMap()
                  .map((i, e) => MapEntry(
                      i, _buildItem(e, font, titles.elementAt(i) == "Total")))
                  .values
                  .toList(),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        _buildAmountInWords(data.totalAmountInWords),
      ],
    );
  }

  static pw.Widget _buildItem(String text, pw.Font font, bool isTotalField) {
    return pw.Container(
      height: isTotalField ? 40 : 20,
      constraints: const pw.BoxConstraints(minWidth: 120),
      padding: const pw.EdgeInsets.symmetric(horizontal: 15),
      color: isTotalField ? PdfColors.grey100 : null,
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.right,
        style: pw.TextStyle(
          font: font,
          color: PdfColors.black,
          fontSize: isTotalField ? 10 : 8,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildAmountInWords(String amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.SizedBox(width: 20),
        pw.Text(
          "Amount in Words: ",
          style: const pw.TextStyle(
            color: PdfColors.grey700,
            fontSize: 10,
          ),
        ),
        pw.Spacer(),
        pw.Text(
          amount,
          style: pw.TextStyle(
            color: PdfColors.black,
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(width: 20),
      ],
    );
  }
}

// Mark: Bank Transaction Builder Functions Extension
// =============================================
extension _BankBuilder on EReceiptTemplate {
  static Future<pw.Widget> _build(ReceiptModel data) async {
    final titleFont = await PdfGoogleFonts.openSansBold();

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey200, width: 1),
          bottom: pw.BorderSide(color: PdfColors.grey200, width: 1),
        ),
      ),
      child: pw.Column(children: [
        pw.Row(
          children: [
            pw.Spacer(),
            pw.Expanded(
              child: pw.Container(
                height: 20,
                constraints: const pw.BoxConstraints(minWidth: 120),
                padding: const pw.EdgeInsets.symmetric(horizontal: 15),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Through",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: titleFont,
                    color: PdfColors.grey400,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                height: 20,
                constraints: const pw.BoxConstraints(minWidth: 120),
                padding: const pw.EdgeInsets.symmetric(horizontal: 15),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  data.buyer.bankAccount?.bankName ?? "",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: titleFont,
                    color: PdfColors.black,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        pw.Row(
          children: [
            pw.Spacer(),
            pw.Expanded(
              child: pw.Container(
                height: 20,
                constraints: const pw.BoxConstraints(minWidth: 120),
                padding: const pw.EdgeInsets.symmetric(horizontal: 15),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  "Received As",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: titleFont,
                    color: PdfColors.grey400,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                height: 20,
                constraints: const pw.BoxConstraints(minWidth: 120),
                padding: const pw.EdgeInsets.symmetric(horizontal: 15),
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  data.transaction.receivedAs,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: titleFont,
                    color: PdfColors.black,
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

// Mark: Bank Transaction Block Builder Functions Extension
// =================================================
extension _BankTransactionDetailsBuilder on EReceiptTemplate {
  static Future<pw.Row> _build(ReceiptModel data) async {
    final titleFont = await PdfGoogleFonts.openSansBold();
    final valuesFont = await PdfGoogleFonts.openSansRegular();
    final amountFont = await PdfGoogleFonts.poppinsBold();

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      mainAxisSize: pw.MainAxisSize.max,
      children: [
        _buildAddress("Bank Transaction Details", titleFont, data, valuesFont,
            data.totalAmount, amountFont),
        pw.SizedBox(width: 20),
      ],
    );
  }

  static pw.Expanded _buildAddress(
      String title,
      pw.Font titleFont,
      ReceiptModel? data,
      pw.Font valuesFont,
      String amount,
      pw.Font amountFont) {
    return pw.Expanded(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.SizedBox(height: 20),
          pw.Text(
            title,
            style: pw.TextStyle(
              font: titleFont,
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            data?.transaction.transferType ?? "",
            style: pw.TextStyle(
              font: valuesFont,
              fontSize: 9,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            "IFSC Code: ${data?.transaction.ifsc ?? "N/A"}",
            style: pw.TextStyle(
              font: valuesFont,
              fontSize: 9,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            "Date: ${data?.transaction.date ?? "N/A"}",
            style: pw.TextStyle(
              font: valuesFont,
              fontSize: 9,
            ),
          ),
          pw.SizedBox(height: 5),
          (data!.modelSubType == 'RAC' || data.modelSubType == 'PAC')
              ? pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                      pw.Divider(color: PdfColor.fromHex('#E9E9E9')),
                      pw.SizedBox(height: 5),
                      pw.SizedBox(
                        width: 163,
                        child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.end,
                            mainAxisSize: pw.MainAxisSize.min,
                            children: [
                              pw.Text(
                                "Amount",
                                style: pw.TextStyle(
                                    color: PdfColors.grey400,
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 8),
                              ),
                              pw.Spacer(),
                              pw.Text(
                                amount,
                                style: pw.TextStyle(
                                  font: amountFont,
                                  color: PdfColor.fromHex('#263238'),
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 8,
                                ),
                              ),
                            ]),
                      ),
                    ])
              : pw.Container(),
          pw.SizedBox(height: 20),
        ],
      ),
    );
  }
}

// Mark: Footer Builder Functions Extension
// =============================================
extension _FooterBuilder on EReceiptTemplate {
  static Future<pw.Widget> _build(String termsLink) async {
    final titleFont = await PdfGoogleFonts.openSansBold();
    final termsFont = await PdfGoogleFonts.poppinsRegular();
    final termsBoldFont = await PdfGoogleFonts.poppinsBold();

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
                  color: PdfColors.black,
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
