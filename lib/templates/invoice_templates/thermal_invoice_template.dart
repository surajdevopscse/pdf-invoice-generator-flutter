import 'package:invoice_generator/invoice_generator.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Mark: Thermal Invoice Template
// ================================
class ThermalInvoiceTemplate {
  static late pw.Font fallbackFont;

  static Future<pw.Document> getPdf(InvoiceModel data) async {
    final pdf = pw.Document();

    final companylogo = await _CompanyLogoBuilder._build(data);
    final address = await _AddressBlockBuilder._build(data);
    final table = await _TableBuilder._build(data);
    final total = await _TotalBlockBuilder._build(data);
    final totalSavings = await _TotalSavingsBuilder._build(data.savedAmount);
    final footer = await _FooterBuilder._build(data);
    final semiboldfont = await PdfGoogleFonts.mulishSemiBold();
    final boldfont = await PdfGoogleFonts.mulishBold();
    final color = PdfColor.fromHex("#0F0F0F");
    final qr = (data.paymentQrBytes != null)
        ? pw.SvgImage(
            svg: pw.Barcode.qrCode().toSvg(data.paymentQrBytes ?? ""),
          )
        : null;
    final defaultFont = await PdfGoogleFonts.mulishRegular();

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(
              fontFallback: [fallbackFont], color: color, font: defaultFont),
        ),
        pageFormat: PdfPageFormat(data.is3mm ? 225 : 164, double.infinity)
            .applyMargin(left: 12, top: 0, right: 12, bottom: 0),
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            // crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 18),
              companylogo,
              pw.SizedBox(height: 10),
              pw.Text(
                data.companyName,
                style: pw.TextStyle(
                  fontFallback: [fallbackFont],
                  fontSize: 10,
                  font: semiboldfont,
                ),
              ),
              address,
              pw.SizedBox(height: 18),
              _divider(),
              pw.SizedBox(height: 5),
              _header(data, boldfont),
              pw.SizedBox(height: 5),
              _divider(),
              pw.SizedBox(height: 14),
              _invoiceDetails(data, semiboldfont, color),
              pw.SizedBox(height: 10),
              pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Container(
                    margin: const pw.EdgeInsets.only(right: 2),
                    child: pw.Text(
                      "Currency: ${data.currencyCode}",
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontFallback: [fallbackFont],
                        fontSize: 8,
                      ),
                    ),
                  )),
              pw.SizedBox(height: 2),
              pw.Container(padding: const pw.EdgeInsets.all(0.5), child: table),
              pw.SizedBox(height: 4),
              total,
              if (data.moduleType != "SCN") totalSavings,
              pw.SizedBox(height: 16),
              _paymentQr(qr),
              footer,
              pw.SizedBox(height: 31),
              pw.Text(
                "Thank you for shopping with us",
                style: pw.TextStyle(
                  fontFallback: [fallbackFont],
                  fontSize: 10,
                  font: boldfont,
                ),
              ),
              pw.SizedBox(height: 40),
            ],
          ); // Center
        },
      ),
    );

    return pdf;
  }

  static pw.Row _divider() {
    return pw.Row(
      children: List.generate(
        600 ~/ 10,
        (index) => pw.Expanded(
          child: pw.Container(
            color: index % 2 != 0
                ? PdfColor.fromHex('#FFFFFF')
                : PdfColor.fromHex("#0F0F0F"),
            height: 1,
          ),
        ),
      ),
    );
  }
}

// Mark: Header Builder Extension
// ================================
extension _CompanyLogoBuilder on ThermalInvoiceTemplate {
  static Future<pw.Widget> _build(InvoiceModel data) async {
    // final logo = await networkImage(data.logoLink);
    final logo =
        (data.logoBytes != null) ? pw.MemoryImage(data.logoBytes!) : null;
    // final semiboldfont = await PdfGoogleFonts.mulishSemiBold();

    return pw.Column(
      children: [
        pw.SizedBox(height: (logo != null) ? 9 : 0),
        (logo != null)
            ? pw.Image(
                logo,
                fit: pw.BoxFit.fill,
                height: 43,
              )
            : pw.Container(),
      ],
    );
  }
}

pw.Widget _header(InvoiceModel data, pw.Font semiboldfont) {
  return pw.Text(
    data.title,
    style: pw.TextStyle(
      fontFallback: [ThermalInvoiceTemplate.fallbackFont],
      font: semiboldfont,
      fontSize: 12,
      //  color: color,
    ),
  );
}

pw.Column _invoiceDetails(
    InvoiceModel data, pw.Font semiboldfont, PdfColor titleColor) {
  String label = '';
  switch (data.moduleType) {
    case 'INV':
      label = 'Invoice';
      break;
    case 'SQU':
      label = 'Quotation';
      break;
    case 'SOR':
      label = 'Order';
      break;
    case 'SDC':
      label = 'Challan';
      break;
    case 'SCN':
      label = 'CN';
      break;
    case 'SDN':
      label = 'DN';
      break;
  }
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(children: [
        pw.Text(
          "$label No: ",
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            font: semiboldfont,
            fontSize: 10,
            color: titleColor,
          ),
        ),
        pw.Text(
          data.id,
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            font: semiboldfont,
            fontSize: 10,
            color: titleColor,
          ),
        ),
      ]),
      pw.SizedBox(height: 5),
      pw.Text(
        "$label Date: ${data.date}",
        textAlign: pw.TextAlign.left,
        style: pw.TextStyle(
          fontFallback: [ThermalInvoiceTemplate.fallbackFont],
          font: semiboldfont,
          fontSize: 10,
          color: titleColor,
        ),
      ),
      pw.SizedBox(height: 5),
      pw.Text(
        "$label Time: ${data.time}",
        textAlign: pw.TextAlign.left,
        style: pw.TextStyle(
          fontFallback: [ThermalInvoiceTemplate.fallbackFont],
          font: semiboldfont,
          fontSize: 10,
          color: titleColor,
        ),
      ),
      pw.SizedBox(height: 5),
      pw.Text(
        "Party: ${data.buyer.name}",
        textAlign: pw.TextAlign.left,
        style: pw.TextStyle(
          fontFallback: [ThermalInvoiceTemplate.fallbackFont],
          font: semiboldfont,
          fontSize: 10,
          color: titleColor,
        ),
      ),
      pw.SizedBox(height: 5),
      pw.Text(
        "Mobile: ${data.buyer.phone ?? 'N/A'}",
        textAlign: pw.TextAlign.left,
        style: pw.TextStyle(
          fontFallback: [ThermalInvoiceTemplate.fallbackFont],
          font: semiboldfont,
          fontSize: 10,
          color: titleColor,
        ),
      ),
    ],
  );
}

// Mark: Address Block Builder Functions Extension
// =================================================
extension _AddressBlockBuilder on ThermalInvoiceTemplate {
  static Future<pw.Container> _build(InvoiceModel data) async {
    final semiboldfont = await PdfGoogleFonts.mulishSemiBold();

    return pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 13),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    textAlign: pw.TextAlign.center,
                    data.seller.address.address ?? "",
                    style: pw.TextStyle(
                      fontFallback: [ThermalInvoiceTemplate.fallbackFont],
                      font: semiboldfont,
                      fontSize: 10,
                    ),
                  ),
                  // pw.SizedBox(height: 2.5),
                  // pw.Text(
                  //   "Pincode: ${data.seller.address.pincode}",
                  //   style: pw.TextStyle(fontFallback: [fallbackFont],
                  //     font: font,
                  //     fontSize: 10,
                  //     color: color,
                  //   ),
                  // ),
                  data.seller.phone == null
                      ? pw.Container()
                      : pw.SizedBox(height: 6),
                  data.seller.phone == null || data.seller.phone!.isEmpty
                      ? pw.Container()
                      : pw.Text(
                          "Phone: ${data.seller.phone ?? "N/A"}",
                          style: pw.TextStyle(
                            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
                            font: semiboldfont,
                            fontSize: 10,
                          ),
                        ),
                  data.seller.email == null || data.seller.email!.isEmpty
                      ? pw.Container()
                      : pw.SizedBox(height: 2.5),
                  data.seller.email == null
                      ? pw.Container()
                      : pw.Text(
                          data.seller.email ?? "N/A",
                          style: pw.TextStyle(
                            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
                            font: semiboldfont,
                            fontSize: 10,
                          ),
                        ),
                  data.seller.gstLabel == null
                      ? pw.Container()
                      : pw.SizedBox(height: 2.5),
                  data.seller.gstLabel == null
                      ? pw.Container()
                      : pw.Text(
                          "${data.seller.gstLabel} ${data.seller.gstorPanNumber ?? "N/A"}",
                          style: pw.TextStyle(
                            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
                            font: semiboldfont,
                            fontSize: 10,
                          ),
                        ),
                ],
              ),
            ),
            //_paymentQr(qr, font, color),
          ],
        ));
  }
}

pw.Widget _paymentQr(pw.Widget? qr) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Container(
        height: qr != null ? 70 : 0,
        alignment: pw.Alignment.centerRight,
        child: (qr != null)
            ? pw.Column(children: [
                qr,
                pw.SizedBox(height: 40),
              ])
            : pw.SizedBox(),
      ),
    ],
  );
}

// Mark: Table Builder Functions Extension
// =========================================
extension _TableBuilder on ThermalInvoiceTemplate {
  static Future<pw.Widget> _build(InvoiceModel data) async {
    final semibold = await PdfGoogleFonts.mulishSemiBold();
    final bold = await PdfGoogleFonts.mulishBold();

    var tableList = [
      ["Item", "Qty", "Rate", "Disc", "Amt"]
    ];
    tableList.addAll(List.generate(data.items.length, (i) {
      final item = data.items.elementAt(i);
      return [
        //  item.hsn,
        item.name,
        item.quantity,
        // item.gst,
        item.price,
        item.discount,
        item.amount,
      ];
    }));

    pw.TextAlign getTextAlign(int index) {
      bool isProduct = index == 0;
      bool isAmt = index == tableList[0].length - 1;
      final align = (isProduct)
          ? pw.TextAlign.left
          : (isAmt)
              ? pw.TextAlign.right
              : pw.TextAlign.center;
      return align;
    }

    return pw.Table(
      //defaultColumnWidth: const pw.FlexColumnWidth([]),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(1.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(2),
      },

      border: pw.TableBorder.all(width: 1),

      children: List.generate(tableList.length, (index) {
        final isTitleIndex = index == 0;
        return pw.TableRow(
          verticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: List.generate(tableList[0].length, (i) {
            return pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 2.5),
              child: pw.Text(
                tableList[index][i],
                textAlign: getTextAlign(i),
                style: pw.TextStyle(
                  fontFallback: [ThermalInvoiceTemplate.fallbackFont],
                  font: isTitleIndex ? bold : semibold,
                  color: PdfColors.black,
                  fontSize: 9,
                ),
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  static pw.Widget _buildAmountInWords(String amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.SizedBox(width: 50),
        pw.Text(
          "Invoice Amount in Words: ",
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            color: PdfColors.grey700,
            fontSize: 10,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            amount,
            style: pw.TextStyle(
              fontFallback: [ThermalInvoiceTemplate.fallbackFont],
              color: PdfColors.black,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// Mark: Total Gst Block Builder Functions Extension
// =============================================
extension _TotalBlockBuilder on ThermalInvoiceTemplate {
  static Future<pw.Widget> _build(InvoiceModel data) async {
    final semiboldfont = await PdfGoogleFonts.mulishSemiBold();
    final regularFont = await PdfGoogleFonts.mulishRegular();
    return pw.Column(children: [
      _tableFooter(semiboldfont, "Total:",
          data.totalItemAmount.replaceAll('₹', ''), data.totalQuantities),
      pw.SizedBox(height: 4),
      _tableFooter(
          semiboldfont, "Round Off:", data.roundOff.replaceAll('₹', ''), null),
      pw.SizedBox(height: 4),
      //round off value
      _tableFooter(
        semiboldfont,
        "Txn. Disc",
        data.txnLevelDiscount,
        null,
      ),
      pw.SizedBox(height: 14),
      ThermalInvoiceTemplate._divider(),
      pw.SizedBox(height: 10),
      pw.Row(children: [
        pw.Text(
          "Net Payable",
          style: pw.TextStyle(
              fontFallback: [ThermalInvoiceTemplate.fallbackFont],
              fontSize: 10,
              font: semiboldfont),
        ),
        pw.Spacer(),
        pw.Text(
          data.totalAmount,
          style: pw.TextStyle(
              fontFallback: [ThermalInvoiceTemplate.fallbackFont],
              fontSize: 10,
              font: semiboldfont),
        ),
        pw.SizedBox(width: 2.5),
      ]),
      pw.SizedBox(height: 10),
      ThermalInvoiceTemplate._divider(),
      pw.SizedBox(height: 12),
      if (!data.advance)
        data.tenderDetails.isEmpty
            ? pw.Container()
            : _threeValueItem(
                "Tender", "Ref. No", "Amount", true, semiboldfont, true),
      data.tenderDetails.isEmpty ? pw.Container() : pw.SizedBox(height: 3),
      if (!data.advance)
        ...data.tenderDetails
            .map(
              (e) => _threeValueItem(e.tender, e.refNo, e.receivedAmount, false,
                  regularFont, true),
            )
            .toList(),
      if (data.advance && data.advanceAmount != null)
        _advanceAmount(data.advanceAmount ?? '', semiboldfont),
      if (data.advance && data.balanceAmount != null)
        _balanceAmount(data.balanceAmount ?? '', semiboldfont),

      pw.SizedBox(height: 12),
      pw.Container(
        decoration: pw.BoxDecoration(border: pw.Border.all(width: 1)),
        margin: const pw.EdgeInsets.all(0.5),
        padding: const pw.EdgeInsets.symmetric(horizontal: 4),
        child: pw.Column(
          children: [
            _threeValueItem(
              "Tax Desc",
              "",
              "Tax",
              true,
              semiboldfont,
              false,
            ),
            pw.SizedBox(height: 2),
            _threeValueItem(
              data.cgstLabel,
              '',
              data.cgstValue,
              false,
              regularFont,
              false,
            ),
            pw.SizedBox(height: 2),
            _threeValueItem(
              data.sgstLabel,
              '',
              data.sgstValue,
              false,
              regularFont,
              false,
            ),
            pw.SizedBox(height: 2),
            if (data.isIndia)
              _threeValueItem(
                data.cessLabel,
                '',
                data.cessValue,
                false,
                regularFont,
                false,
              ),
          ],
        ),
      ),
      pw.SizedBox(height: 13),
    ]);
  }
}

pw.Row _threeValueItem(String value1, String value2, String value3,
    bool isHeader, pw.Font font, bool isTender) {
  return pw.Row(children: [
    pw.Expanded(
      flex: isTender ? 1 : 2,
      child: pw.Text(
        value1,
        style: pw.TextStyle(
          fontFallback: [ThermalInvoiceTemplate.fallbackFont],
          fontSize: 10,
          font: font,
        ),
      ),
    ),
    value2.isEmpty
        ? pw.Container()
        : pw.Expanded(
            child: pw.Text(
              value2,
              style: pw.TextStyle(
                fontFallback: [ThermalInvoiceTemplate.fallbackFont],
                fontSize: 10,
                font: font,
              ),
            ),
          ),
    pw.Expanded(
        child: pw.Text(
      value3,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontFallback: [ThermalInvoiceTemplate.fallbackFont],
        fontSize: 10,
        font: font,
      ),
    )),
  ]);
}

pw.Row _advanceAmount(String advanceAmount, pw.Font font) {
  return pw.Row(children: [
    pw.Expanded(
      flex: 1,
      child: pw.Text(
        'Advance',
        textAlign: pw.TextAlign.left,
        style: pw.TextStyle(
          fontFallback: [ThermalInvoiceTemplate.fallbackFont],
          fontSize: 10,
          font: font,
        ),
      ),
    ),
    pw.Expanded(
        flex: 1,
        child: pw.Text(
          advanceAmount,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            fontSize: 10,
            font: font,
          ),
        )),
  ]);
}

pw.Row _balanceAmount(String balanceAmount, pw.Font font) {
  return pw.Row(children: [
    pw.Expanded(
      flex: 1,
      child: pw.Text(
        'Balance',
        textAlign: pw.TextAlign.left,
        style: pw.TextStyle(
          fontFallback: [ThermalInvoiceTemplate.fallbackFont],
          fontSize: 10,
          font: font,
        ),
      ),
    ),
    pw.Expanded(
        flex: 1,
        child: pw.Text(
          balanceAmount,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            fontSize: 10,
            font: font,
          ),
        )),
  ]);
}

pw.Row _tableFooter(
    pw.Font font, String label, String rightValue, String? middleValue) {
  return pw.Row(children: [
    pw.Expanded(
      flex: middleValue != null ? 4 : 6,
      child: pw.Text(
        label,
        style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            fontSize: 10,
            font: font),
      ),
    ),
    pw.Expanded(
      flex: 3,
      child: middleValue != null
          ? pw.Text(
              textAlign: pw.TextAlign.center,
              middleValue,
              style: pw.TextStyle(
                  fontFallback: [ThermalInvoiceTemplate.fallbackFont],
                  fontSize: 10,
                  font: font),
            )
          : pw.Container(),
    ),
    middleValue != null ? pw.Spacer(flex: 3) : pw.Container(),
    // middleValue != null ? pw.Spacer(flex: 3) : pw.Container(),
    pw.Expanded(
      flex: middleValue != null ? 7 : 10,
      child: pw.Text(
        textAlign: pw.TextAlign.right,
        rightValue,
        style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            fontSize: 10,
            font: font),
      ),
    ),
    pw.SizedBox(width: 2.5)
  ]);
}

// Mark: Amount In Words Builder Functions Extension
// ===================================================
extension _TotalSavingsBuilder on ThermalInvoiceTemplate {
  static Future<pw.Widget> _build(String totalSavings) async {
    final boldFont = await PdfGoogleFonts.mulishBold();

    return pw.Row(
      children: [
        pw.Text(
          'Total Savings: ',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            font: boldFont,
            color: PdfColors.black,
            fontSize: 12,
          ),
        ),
        pw.Text(
          totalSavings,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            font: boldFont,
            color: PdfColors.black,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildAmountInWords(String amount) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.SizedBox(width: 50),
        pw.Text(
          "Invoice Amount in Words: ",
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            color: PdfColors.grey700,
            fontSize: 10,
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            amount,
            style: pw.TextStyle(
              fontFallback: [ThermalInvoiceTemplate.fallbackFont],
              color: PdfColors.black,
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// Mark: Footer Builder Functions Extension
// =============================================
extension _FooterBuilder on ThermalInvoiceTemplate {
  static Future<pw.Widget> _build(InvoiceModel data) async {
    final font = await PdfGoogleFonts.mulishSemiBold();
    final boldfont = await PdfGoogleFonts.mulishBold();
    final regularfont = await PdfGoogleFonts.mulishRegular();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.SizedBox(height: 5),
        pw.Text(
          "Terms & Conditions",
          textAlign: pw.TextAlign.left,
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            font: boldfont,
            color: PdfColors.black,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          data.termsAndConditions,
          textAlign: pw.TextAlign.left,
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            font: regularfont,
            color: PdfColors.black,
            fontSize: 10,
          ),
        ),
        pw.SizedBox(height: 35),
        pw.Text(
          "You can also write to us at:",
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            font: regularfont,
            color: PdfColors.black,
            fontSize: 10,
          ),
        ),
        pw.SizedBox(height: 5),
        pw.Text(
          data.customerSupportEmail,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            font: font,
            color: PdfColors.black,
            fontSize: 10,
          ),
        ),
        pw.SizedBox(height: 20),
        pw.Text(
          "This is computer generated ${data.moduleType == 'INV' ? 'invoice' : 'document'} and should be treated as signed by an authorised signatory",
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontFallback: [ThermalInvoiceTemplate.fallbackFont],
            font: regularfont,
            color: PdfColors.black,
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}
