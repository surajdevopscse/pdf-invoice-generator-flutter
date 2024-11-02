import 'package:invoice_generator/invoice_generator.dart';
import 'package:invoice_generator/models/pdf_settings.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class HalfPrintNonGst {
  ///FONT STYLE
  static late pw.Font titleFont;
  static late pw.Font subTitleFont;
  static late pw.Font invoiceNumberFont;
  static late pw.Font invoiceDateFont;
  static late pw.Font valuesFont;
  static late pw.Font labelFont;
  static late pw.Font extraBoldFont;

  ///FONT SIZE
  static late double titleFontSize;
  static late double valuesFontSize;
  static late double labelFontSize;
  static late double extraBoldFontSize;

  static setFontFamily(String fontFamily) async {
    if (fontFamily == 'Poppins') {
      titleFont = await PdfGoogleFonts.poppinsBold();
      subTitleFont = await PdfGoogleFonts.poppinsSemiBold();
      invoiceNumberFont = await PdfGoogleFonts.poppinsBold();
      invoiceDateFont = await PdfGoogleFonts.poppinsRegular();
      valuesFont = await PdfGoogleFonts.poppinsRegular();
      labelFont = await PdfGoogleFonts.poppinsSemiBold();
      extraBoldFont = await PdfGoogleFonts.poppinsExtraBold();
    } else {
      titleFont = await PdfGoogleFonts.mulishBold();
      invoiceNumberFont = await PdfGoogleFonts.mulishBold();
      subTitleFont = await PdfGoogleFonts.mulishSemiBold();
      invoiceDateFont = await PdfGoogleFonts.mulishRegular();
      valuesFont = await PdfGoogleFonts.mulishRegular();
      labelFont = await PdfGoogleFonts.mulishSemiBold();
      extraBoldFont = await PdfGoogleFonts.mulishExtraBold();
    }
  }

  static setFontSize(double size) {
    valuesFontSize = size - 4;
    labelFontSize = size - 3;
    titleFontSize = size;
    extraBoldFontSize = size - 2;
  }

  static Future<pw.Document> getPdf(InvoiceModel data) async {
    final pdf = pw.Document();
    await setFontFamily(data.settings.fontFamily);
    final moduleType = data.moduleType;
    String invoiceNumber = data.id;

    String label = '';
    switch (moduleType) {
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
      case 'POR':
        label = 'PO';
        break;
    }
    setFontSize(data.settings.fontSize.toDouble());
    final header = await _HeaderBuilder._build(data);
    final bottom = await _BottomBuilder._build(data);
    final addressBlock =
        await _AddressBlockBuilder._build(data, label, invoiceNumber);

    final subTotalGstBlock = await _SubtotalGstBlockBuilder._build(data);
    final itemsBlock = await _ItemListBuilder._build(data, data.items);
    List<pw.Widget> childrenWidgets = [];
    final authSignatory = (data.settings.authorizedSignatory == null)
        ? null
        : data.settings.authorizedSignatory!.isEmpty
            ? null
            : pw.MemoryImage(data.settings.authorizedSignatory!);

    childrenWidgets = [
      pw.Container(
        width: double.maxFinite,
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: borderWidth),
        ),
        child: pw.Column(
          children: [
            header,
            addressBlock,
          ],
        ),
      ),
      itemsBlock,
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: borderWidth),
        ),
        child: pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
                flex: 12,
                child: pw.Column(children: [
                  pw.Table(
                    // border: const pw.TableBorder(
                    //     right: pw.BorderSide(width: borderWidth)),
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Expanded(
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              child: customLabelValue(
                                label: 'Total Items : ',
                                value: data.items.length.toString(),
                              ),
                            ),
                          ),
                          pw.Expanded(
                            child: pw.Container(
                              padding: const pw.EdgeInsets.all(5),
                              child: customLabelValue(
                                label: 'Total Amount (in Words) : ',
                                value: '${data.totalAmountInWords} Only',
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ])),
            pw.Expanded(flex: 8, child: subTotalGstBlock),
          ],
        ),
      ),
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: borderWidth),
        ),
        child: pw.Table(
          border: pw.TableBorder.all(width: borderWidth),
          children: [
            pw.TableRow(
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(children: [
                    if (data.settings.fieldSettings.bankDetails &&
                        data.buyer.bankAccount?.bankName != null)
                      pw.Table(
                          border: pw.TableBorder.all(width: borderWidth),
                          children: [
                            pw.TableRow(children: [
                              pw.Column(children: [
                                pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      pw.MainAxisAlignment.spaceBetween,
                                  children: [
                                    pw.Container(
                                      padding: const pw.EdgeInsets.all(4),
                                      child: customLabelValue(
                                        label: 'Bank : ',
                                        value:
                                            data.buyer.bankAccount?.bankName ??
                                                '',
                                      ),
                                    ),
                                    pw.Row(children: [
                                      pw.Container(
                                        padding: const pw.EdgeInsets.all(4),
                                        child: customLabelValue(
                                          label: 'A/C No : ',
                                          value: data.buyer.bankAccount
                                                  ?.accountNumber ??
                                              '',
                                        ),
                                      ),
                                      pw.Container(
                                        padding: const pw.EdgeInsets.all(3),
                                        child: customLabelValue(
                                          label: 'IFSC : ',
                                          value: data.buyer.bankAccount?.ifsc ??
                                              '',
                                        ),
                                      ),
                                    ]),
                                  ],
                                ),
                              ])
                            ])
                          ]),
                    if (data.settings.fieldSettings.notes &&
                        data.notes != null &&
                        data.notes!.isNotEmpty)
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: customLabelValue(
                          label: 'Notes : ',
                          value: data.notes ?? '',
                        ),
                      ),
                  ]),
                ),
                if (data.settings.isAuthSign)
                  pw.Expanded(
                    flex: 1,
                    child: pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Column(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: pw.CrossAxisAlignment.end,
                            children: [
                              pw.Text(
                                'For ${data.companyName}          ',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  color: PdfColor.fromHex('#828282'),
                                  fontSize: 8,
                                ),
                              ),
                              (data.settings.authorizedSignatory == null)
                                  ? pw.SizedBox(height: 30)
                                  : pw.Container(
                                      height: 30,
                                      child: pw.Image(
                                        authSignatory as pw.ImageProvider,
                                        fit: pw.BoxFit.scaleDown,
                                      ),
                                    ),
                              pw.Text(
                                "Authorized Signatory",
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  font: HalfPrintNonGst.extraBoldFont,
                                  color: PdfColors.black,
                                  fontSize: HalfPrintNonGst.extraBoldFontSize,
                                ),
                              ),
                            ])),
                  ),
              ],
            ),
          ],
        ),
      ),
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: data.settings.orientation == 'Portrait'
            ? PdfPageFormat.a4
            : PdfPageFormat.a4.copyWith(
                width: PdfPageFormat.a4.height, height: PdfPageFormat.a4.width),
        footer: (pw.Context context) {
          return pw.Container(
              height: (data.settings.orientation == 'Portrait'
                      ? PdfPageFormat.a4.height
                      : PdfPageFormat.a4.width) /
                  1.8,
              alignment: pw.Alignment.bottomRight,
              child: pw.Text(
                  '${context.pageNumber} of ${context.pagesCount} Page',
                  style: const pw.TextStyle(fontSize: 6)));
        },
        margin: pw.EdgeInsets.only(
            left: data.settings.marginLeft,
            right: data.settings.marginRight,
            top: data.settings.marginTop,
            bottom: data.settings.marginBottom),
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

extension _HeaderBuilder on HalfPrintNonGst {
  static Future<pw.Widget> _build(InvoiceModel data) async {
    String date = data.date;
    final moduleType = data.moduleType;
    String invoiceNumber = data.id;

    String label = '';
    switch (moduleType) {
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
      case 'POR':
        label = 'PO';
        break;
    }

    String docNumber = '$label No: $invoiceNumber';
    String docDate = '$label Date: $date';

    int numberLength = docNumber.length;
    int dateLength = docDate.length;

    int diff = numberLength - dateLength;

    if (diff != 0) {
      if (diff.isNegative) {
        invoiceNumber = invoiceNumber.padRight(diff);
      } else {
        date = date.padRight(diff);
      }
    }
    return pw.Container(
        color: PdfColor.fromInt(data.settings.backgroundColor.value),
        child: pw.Row(children: [
          pw.Spacer(flex: 1),
          pw.Expanded(
              flex: 1,
              child: pw.Center(
                  child: pw.Text(
                data.title,
                style: pw.TextStyle(
                    fontSize: HalfPrintNonGst.titleFontSize,
                    fontWeight: pw.FontWeight.normal,
                    color: PdfColor.fromInt(data.settings.textColor.value)),
              ))),
          pw.Expanded(
              flex: 1,
              child: pw.Container(
                  alignment: pw.Alignment.centerRight,
                  padding: const pw.EdgeInsets.only(right: 16),
                  child: pw.Text(
                    data.printCopyTitle,
                    style: pw.TextStyle(
                        fontSize: HalfPrintNonGst.valuesFontSize,
                        fontWeight: pw.FontWeight.normal,
                        color: PdfColor.fromInt(data.settings.textColor.value)),
                  ))),
        ]));
  }
}

extension _BottomBuilder on HalfPrintNonGst {
  static Future<pw.Widget> _build(InvoiceModel data) async {
    final logo =
        (data.logoBytes != null) ? pw.MemoryImage(data.logoBytes!) : null;
    final qr = (data.settings.fieldSettings.qrCode)
        ? (data.paymentQrBytes != null)
            ? pw.Container(
                child: pw.SvgImage(
                svg: pw.Barcode.qrCode().toSvg(data.paymentQrBytes ?? ""),
              ))
            : null
        : null;

    String date = data.date;
    final moduleType = data.moduleType;
    String invoiceNumber = data.id;

    String label = '';
    switch (moduleType) {
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
      case 'POR':
        label = 'PO';
        break;
    }

    String docNumber = '$label No: $invoiceNumber';
    String docDate = '$label Date: $date';

    int numberLength = docNumber.length;
    int dateLength = docDate.length;

    int diff = numberLength - dateLength;

    if (diff != 0) {
      if (diff.isNegative) {
        invoiceNumber = invoiceNumber.padRight(diff);
      } else {
        date = date.padRight(diff);
      }
    }

    List<pw.Widget> children = [
      pw.Text(
        'Bank Details:',
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.normal,
        ),
      ),
      qr != null ? pw.SizedBox(width: 83) : pw.Container(),
      pw.Spacer(),
      pw.Text(
        'For ${data.companyName}',
        style: pw.TextStyle(
          color: PdfColor.fromHex('#828282'),
          fontSize: 8,
        ),
      ),
    ];

    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Table(
            border: pw.TableBorder.all(width: borderWidth),
            children: [
              pw.TableRow(
                children: [
                  pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          if (moduleType != 'POR')
                            if (data.settings.fieldSettings.bankDetails)
                              pw.Container(
                                padding: const pw.EdgeInsets.all(5),
                                child: pw.Column(
                                  mainAxisAlignment: pw.MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Container(
                                      child: pw.Text(
                                        'Bank Details:',
                                        style: pw.TextStyle(
                                          font: HalfPrintNonGst.titleFont,
                                          fontSize:
                                              HalfPrintNonGst.titleFontSize,
                                        ),
                                      ),
                                    ),
                                    customLabelValue(
                                      label: "Bank:     ",
                                      value:
                                          "${data.buyer.bankAccount?.bankName}",
                                    ),
                                    customLabelValue(
                                      label: "A/c No:  ",
                                      value:
                                          "${data.buyer.bankAccount?.accountNumber}",
                                    ),
                                    customLabelValue(
                                      label: "IFSC:      ",
                                      value: "${data.buyer.bankAccount?.ifsc}",
                                    ),
                                    customLabelValue(
                                      label: "Branch:  ",
                                      value:
                                          "${data.buyer.bankAccount?.branchName}",
                                    ),
                                  ],
                                ),
                              ),
                          (qr != null)
                              ? pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                    top: 5,
                                    bottom: 5,
                                  ),
                                  child: qr)
                              : pw.Container(),
                        ],
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.all(5),
                    child: pw.SizedBox(height: 10),
                  ),
                ],
              ),
            ],
          ),
          if (data.settings.fieldSettings.notes)
            pw.Table(
              border: pw.TableBorder.all(width: borderWidth),
              children: [
                pw.TableRow(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Note: ${data.notes}',
                            style: pw.TextStyle(
                                fontSize: 8, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 5),
                          pw.Text(
                            data.notes ?? 'N/A',
                            style: pw.TextStyle(
                                fontSize: 8, fontWeight: pw.FontWeight.normal),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

extension _AddressBlockBuilder on HalfPrintNonGst {
  static Future<pw.Column> _build(
      InvoiceModel data, String label, String id) async {
    final titleFont = await PdfGoogleFonts.mulishBold();
    final labelFont = await PdfGoogleFonts.mulishSemiBold();
    final valuesFont = await PdfGoogleFonts.mulishRegular();

    return pw.Column(
      children: [
        pw.Table(
          border: pw.TableBorder.all(width: borderWidth),
          children: [
            pw.TableRow(
              children: [
                pw.Expanded(
                  child: pw.Padding(
                    padding:
                        const pw.EdgeInsets.only(left: 8, right: 8, bottom: 2),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          data.companyName,
                          style: pw.TextStyle(
                            font: titleFont,
                            fontSize: HalfPrintNonGst.titleFontSize - 2,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        if (data.companyAddress != null)
                          pw.Text(
                            data.companyAddress ?? 'N/A',
                            style: pw.TextStyle(
                              font: valuesFont,
                              fontSize: HalfPrintNonGst.valuesFontSize,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                        if (data.settings.fieldSettings.pan)
                          customLabelValue(
                            label: 'PAN : ',
                            value: data.companyPan,
                          ),
                      ],
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Padding(
                    padding:
                        const pw.EdgeInsets.only(left: 8, right: 8, bottom: 2),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "${data.moduleType == 'POR' || data.moduleType == 'PBL' || data.moduleType == 'PDN' || data.moduleType == 'PCN' || data.moduleType == 'EXP' ? "Vendor's" : "Buyer's"} Details",
                          style: pw.TextStyle(
                            font: titleFont,
                            fontSize: HalfPrintNonGst.titleFontSize - 2,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          data.buyer.name,
                          style: pw.TextStyle(
                            font: valuesFont,
                            fontSize: HalfPrintNonGst.valuesFontSize,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                        if (data.buyer.billingAddress?.address != null)
                          pw.Text(
                            data.buyer.billingAddress?.address?.toString() ??
                                'N/A',
                            style: pw.TextStyle(
                              font: valuesFont,
                              fontSize: HalfPrintNonGst.valuesFontSize,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                        customLabelValue(
                          label:
                              'Pincode ${(data.buyer.billingAddress != null) ? '-' : ''}',
                          value:
                              data.buyer.billingAddress?.pincode?.toString() ??
                                  'N/A',
                        ),
                        customLabelValue(
                          label: 'Mobile: ',
                          value: data.buyer.phone ?? 'N/A',
                        ),
                      ],
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(
                        left: 8, right: 8, bottom: 2, top: 2),
                    child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '$label No : $id',
                          style: pw.TextStyle(
                            font: valuesFont,
                            fontSize: HalfPrintNonGst.valuesFontSize,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                        pw.Text(
                          '$label Date : ${data.date}',
                          style: pw.TextStyle(
                            font: valuesFont,
                            fontSize: HalfPrintNonGst.valuesFontSize,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                        if (data.settings.fieldSettings.placeOfSupply)
                          pw.Text(
                            'Place of supply : ${data.placeOfSupply}',
                            style: pw.TextStyle(
                              font: valuesFont,
                              fontSize: HalfPrintNonGst.valuesFontSize,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (data.moduleType == 'POR')
              pw.TableRow(
                children: [
                  if (data.settings.fieldSettings.validTill)
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: customLabelValue(
                        label: "Valid Till : ",
                        value: data.validTillDate ?? 'N/A',
                      ),
                    ),
                  if (data.settings.fieldSettings.deliveryDate)
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: customLabelValue(
                        label: 'Delivery Date : ',
                        value: data.deliveryDate ?? 'N/A',
                      ),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

extension _AdditionalBlockBuilder on HalfPrintNonGst {
  static Future<pw.Padding> _build(InvoiceModel data) async {
    final titleFont = await PdfGoogleFonts.mulishBold();
    final labelFont = await PdfGoogleFonts.mulishSemiBold();
    final valuesFont = await PdfGoogleFonts.mulishRegular();
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          ...data.additionalFields.map((e) => pw.Expanded(
                  child: pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 4),
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            e.name,
                            style: pw.TextStyle(
                              font: titleFont,
                              fontSize: HalfPrintNonGst.valuesFontSize + 2,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            e.value,
                            style: pw.TextStyle(
                              font: labelFont,
                              fontSize: HalfPrintNonGst.valuesFontSize,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          )
                        ],
                      )))) ??
              [],
        ],
      ),
    );
  }
}

pw.RichText customLabelValue({String? label, required String? value}) {
  return pw.RichText(
    text: pw.TextSpan(
      text: label ?? '',
      style: pw.TextStyle(
        font: HalfPrintNonGst.labelFont,
        fontSize: HalfPrintNonGst.labelFontSize,
      ),
      children: [
        pw.TextSpan(
          text: (value == 'null') ? 'N/A' : value ?? 'N/A',
          style: pw.TextStyle(
            font: HalfPrintNonGst.valuesFont,
            fontSize: HalfPrintNonGst.valuesFontSize,
          ),
        ),
      ],
    ),
  );
}

extension _ItemListBuilder on HalfPrintNonGst {
  static Future<pw.Widget> _build(
      InvoiceModel data, List<InvoiceItemModel> items) async {
    final symbolFont = await PdfGoogleFonts.poppinsBold();

    return pw.Column(children: [
      _buildTile(
        symbolFont,
        PdfColor.fromInt(data.settings.backgroundColor.value),
        textColor: PdfColor.fromInt(data.settings.textColor.value),
        showHsn: data.settings.fieldSettings.hsn,
        showItemCode: data.settings.fieldSettings.itemCode,
        showItemUnit: data.settings.fieldSettings.uom,
        showItemDiscount: data.settings.fieldSettings.unitDiscount,
        showItemQty: data.settings.fieldSettings.qty,
        showItemDelivery: data.settings.fieldSettings.unitDelivery,
        showItemFreight: data.settings.fieldSettings.unitFreight,
        isHeader: true,
        showItemDescription: data.settings.fieldSettings.description,
      ),
      ...List.generate(items.length + 1, (i) {
        // final colorIndex = (items.length + 1 % 2 == 0) ? i : i + 1;
        if (i < items.length) {
          // return pw.Container();
          return _buildTile(
            symbolFont,
            PdfColors.white,
            isHeader: false,
            showHsn: data.settings.fieldSettings.hsn,
            showItemCode: data.settings.fieldSettings.itemCode,
            showItemUnit: data.settings.fieldSettings.uom,
            showItemDiscount: data.settings.fieldSettings.unitDiscount,
            showItemQty: data.settings.fieldSettings.qty,
            showItemDelivery: data.settings.fieldSettings.unitDelivery,
            showItemFreight: data.settings.fieldSettings.unitFreight,
            index: i,
            model: items.elementAt(i),
            showItemDescription: data.settings.fieldSettings.description,
          );
        } else {
          return _buildFooterTile(
            titleFont: symbolFont,
            backgroundColor: PdfColors.white,
            model: data,
          );
        }
      }),
    ]);
  }

  static pw.Table _buildTile(pw.Font fallbackFont, PdfColor backgroundColor,
      {required bool isHeader,
      required bool showHsn,
      required bool showItemCode,
      required bool showItemUnit,
      required bool showItemQty,
      required bool showItemDiscount,
      required bool showItemDelivery,
      required bool showItemFreight,
      required bool showItemDescription,
      int? index,
      InvoiceItemModel? model,
      PdfColor? textColor}) {
    String itemName = '${model?.name}';

    if (showItemCode) {
      itemName += '\nCode : ${model?.code}';
    }
    if (showItemDescription) {
      itemName += '\n${model?.description}';
    }
    return pw.Table(
      border: pw.TableBorder(
        left: const pw.BorderSide(width: borderWidth),
        right: const pw.BorderSide(width: borderWidth),
        top: isHeader
            ? const pw.BorderSide(width: borderWidth)
            : pw.BorderSide.none,
        bottom: const pw.BorderSide(width: borderWidth),
        horizontalInside: const pw.BorderSide(width: borderWidth),
      ),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: backgroundColor,
          ),
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8, top: 4, bottom: 4),
                child: pw.Text(
                  isHeader ? "S.N" : model!.index.toString(),
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    font: HalfPrintNonGst.subTitleFont,
                    fontFallback: [fallbackFont],
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: HalfPrintNonGst.valuesFontSize,
                  ),
                ),
              ),
            ),
            pw.Expanded(
              flex: 4,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(
                    left: 8, top: 4, bottom: 4, right: 8),
                child: pw.Text(
                  isHeader ? "Item Name" : itemName,
                  textAlign: pw.TextAlign.left,
                  overflow: pw.TextOverflow.clip,
                  style: pw.TextStyle(
                    font: HalfPrintNonGst.subTitleFont,
                    fontFallback: [fallbackFont],
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: HalfPrintNonGst.valuesFontSize,
                  ),
                ),
              ),
            ),
//showHsn
            if (showHsn)
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8, top: 4, bottom: 4),
                  child: pw.Text(
                    isHeader ? "HSN/SAC" : model?.hsn ?? "N/A",
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      font: HalfPrintNonGst.subTitleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: HalfPrintNonGst.valuesFontSize,
                    ),
                  ),
                ),
              ),
            //showItemQty
            if (showItemQty)
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding:
                      const pw.EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  child: pw.Text(
                    isHeader ? "Qty" : model?.quantity ?? "",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      font: HalfPrintNonGst.subTitleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: HalfPrintNonGst.valuesFontSize,
                    ),
                  ),
                ),
              ),
            //showItemUnit
            if (showItemUnit)
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(
                      left: 8, top: 4, bottom: 4, right: 8),
                  child: pw.Text(
                    isHeader ? "Unit" : model?.unit ?? "",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      font: HalfPrintNonGst.subTitleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: HalfPrintNonGst.valuesFontSize,
                    ),
                  ),
                ),
              ),
            pw.Expanded(
              flex: 2,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(right: 8, top: 4, bottom: 4),
                child: pw.Text(
                  isHeader ? "Price/Unit" : model?.price ?? "",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: HalfPrintNonGst.subTitleFont,
                    fontFallback: [fallbackFont],
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: HalfPrintNonGst.valuesFontSize,
                  ),
                ),
              ),
            ),
            // after unit price list
            //showItemDelivery
            if (showItemDelivery)
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding:
                      const pw.EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  child: pw.Text(
                    isHeader ? "Delivery/Unit" : model?.delivery ?? "",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      font: HalfPrintNonGst.subTitleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: HalfPrintNonGst.valuesFontSize,
                    ),
                  ),
                ),
              ),
            if (showItemFreight)
              //showItemFreight
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding:
                      const pw.EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  child: pw.Text(
                    isHeader ? "Freight/Unit" : model?.freight ?? "",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      font: HalfPrintNonGst.subTitleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: HalfPrintNonGst.valuesFontSize,
                    ),
                  ),
                ),
              ),
            if (showItemDiscount)
              //showItemDiscount
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding:
                      const pw.EdgeInsets.only(right: 8, top: 4, bottom: 4),
                  child: pw.Text(
                    isHeader ? "Disc." : model?.discount ?? "",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      font: HalfPrintNonGst.subTitleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: HalfPrintNonGst.valuesFontSize,
                    ),
                  ),
                ),
              ),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(right: 8, top: 4, bottom: 4),
                child: pw.Text(
                  isHeader ? "Amt.(INR)" : model?.amount ?? "",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: HalfPrintNonGst.subTitleFont,
                    fontFallback: [fallbackFont],
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: HalfPrintNonGst.valuesFontSize,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildFooterTile({
    required pw.Font titleFont,
    required PdfColor backgroundColor,
    required InvoiceModel model,
  }) {
    return pw.Table(
      border: const pw.TableBorder(
        left: pw.BorderSide(width: borderWidth),
        right: pw.BorderSide(width: borderWidth),
        // bottom: pw.BorderSide(width: borderWidth),
        // horizontalInside: pw.BorderSide(width: borderWidth),
      ),
      children: [
        pw.TableRow(
          children: [
            pw.Expanded(
              flex: 1,
              child: pw.SizedBox(),
            ),
            pw.Expanded(
                flex: 4,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(
                      left: 8, top: 4, bottom: 4, right: 8),
                  child: pw.Text(
                    "Total",
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      font: titleFont,
                      color: PdfColors.black,
                      fontSize: HalfPrintNonGst.valuesFontSize,
                    ),
                  ),
                )),
            if (model.settings.fieldSettings.hsn)
              pw.Expanded(
                flex: 2,
                child: pw.SizedBox(),
              ),
            if (model.settings.fieldSettings.qty)
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(
                      left: 8, top: 4, bottom: 4, right: 8),
                  child: pw.Text(
                    model.totalQuantities,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      font: titleFont,
                      color: PdfColors.black,
                      fontSize: HalfPrintNonGst.valuesFontSize,
                    ),
                  ),
                ),
              ),
            if (model.settings.fieldSettings.uom)
              pw.Expanded(
                flex: 2,
                child: pw.SizedBox(),
              ),
            pw.Expanded(
              flex: 2,
              child: pw.SizedBox(),
            ),
            if (model.settings.fieldSettings.unitDelivery)
              pw.Expanded(
                flex: 2,
                child: pw.SizedBox(),
              ),
            if (model.settings.fieldSettings.unitFreight)
              pw.Expanded(
                flex: 2,
                child: pw.SizedBox(),
              ),
            if (model.settings.fieldSettings.unitDiscount)
              pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.only(
                        left: 8, top: 4, bottom: 4, right: 8),
                    child: pw.Text(
                      model.totalDiscount,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        font: titleFont,
                        color: PdfColors.black,
                        fontSize: HalfPrintNonGst.valuesFontSize,
                      ),
                    ),
                  )),
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(
                    left: 8, top: 4, bottom: 4, right: 8),
                child: pw.Text(
                  model.footerTotalAmount,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: titleFont,
                    color: PdfColors.black,
                    fontSize: HalfPrintNonGst.valuesFontSize,
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

extension _SubtotalGstBlockBuilder on HalfPrintNonGst {
  static Future<pw.Widget> _build(InvoiceModel data) async {
    final titles = [
      "Total Item Amount",
      "Discount",
      "Total",
      'Received:',
      'Due:',
    ];
    final values = [
      data.totalTaxable,
      data.txnLevelDiscount,
      data.totalAmount,
      data.receivedAmount,
      data.due,
    ];
    return pw.Container(
        decoration: const pw.BoxDecoration(
          border: pw.Border(left: pw.BorderSide(width: borderWidth)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: titles
                        .asMap()
                        .map((i, e) => MapEntry(
                            i, _buildItem("", titles.elementAt(i) == "Total")))
                        .values
                        .toList(),
                  ),
                ),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: titles
                      .asMap()
                      .map((i, e) => MapEntry(
                          i, _buildItem(e, titles.elementAt(i) == "Total")))
                      .values
                      .toList(),
                ),
                pw.Column(
                  mainAxisAlignment: pw.MainAxisAlignment.start,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: values
                      .asMap()
                      .map((i, e) => MapEntry(
                          i, _buildItem(e, titles.elementAt(i) == "Total")))
                      .values
                      .toList(),
                ),
              ],
            ),
          ],
        ));
  }

  static pw.Widget _buildItem(String text, bool isTotalField) {
    return text.isEmpty
        ? pw.Container()
        : pw.Container(
            height: isTotalField ? 20 : 10,
            constraints: const pw.BoxConstraints(minWidth: 100),
            padding: const pw.EdgeInsets.symmetric(horizontal: 15),
            // color: isTotalField ? PdfColors.grey100 : null,
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              text,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: HalfPrintNonGst.titleFont,
                color: PdfColors.black,
                fontSize: isTotalField
                    ? HalfPrintNonGst.extraBoldFontSize
                    : HalfPrintNonGst.valuesFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          );
  }
}

extension _FooterBuilder on HalfPrintNonGst {
  static Future<pw.Widget> _build(String? notes, String? termsAndConditionsLink,
      PdfSettings settings, String companyName) async {
    final preparedBySign = (settings.preparedBySignature == null)
        ? null
        : settings.preparedBySignature!.isEmpty
            ? null
            : pw.MemoryImage(settings.preparedBySignature!);
    final checkedBySign = (settings.checkedBySignature == null)
        ? null
        : settings.checkedBySignature!.isEmpty
            ? null
            : pw.MemoryImage(settings.checkedBySignature!);
    final authSignatory = (settings.authorizedSignatory == null)
        ? null
        : settings.authorizedSignatory!.isEmpty
            ? null
            : pw.MemoryImage(settings.authorizedSignatory!);

    return pw.Table(
      border: (preparedBySign != null ||
              checkedBySign != null ||
              authSignatory != null)
          ? pw.TableBorder.all(width: borderWidth)
          : null,
      children: [
        if (!settings.isPreparedBy &&
            !settings.isCheckedBy &&
            !settings.isAuthSign)
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Center(
                    child: pw.Text(
                  "This is a computer-generated document. No signature is required.",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: HalfPrintNonGst.extraBoldFont,
                    color: PdfColors.black,
                    fontSize: HalfPrintNonGst.extraBoldFontSize,
                  ),
                )),
              )
            ],
          ),
        pw.TableRow(
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    mainAxisAlignment:
                        settings.isPreparedBy || settings.isCheckedBy
                            ? pw.MainAxisAlignment.spaceBetween
                            : pw.MainAxisAlignment.end,
                    children: [
                      if (settings.isPreparedBy)
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Center(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                (preparedBySign == null)
                                    ? pw.SizedBox(height: 80)
                                    : pw.Container(
                                        height: 80,
                                        child: pw.Image(
                                          preparedBySign,
                                          fit: pw.BoxFit.scaleDown,
                                        ),
                                      ),
                                pw.Container(
                                  height: 30,
                                  child: pw.Text(
                                    "Prepared By",
                                    textAlign: pw.TextAlign.right,
                                    style: pw.TextStyle(
                                      font: HalfPrintNonGst.extraBoldFont,
                                      color: PdfColors.black,
                                      fontSize:
                                          HalfPrintNonGst.extraBoldFontSize,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (settings.isCheckedBy)
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Center(
                            child: pw.Column(children: [
                              (checkedBySign == null)
                                  ? pw.SizedBox(height: 80)
                                  : pw.Container(
                                      height: 80,
                                      child: pw.Image(
                                        checkedBySign,
                                        fit: pw.BoxFit.scaleDown,
                                      ),
                                    ),
                              pw.Container(
                                height: 30,
                                child: pw.Text(
                                  "Checked By",
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    font: HalfPrintNonGst.extraBoldFont,
                                    color: PdfColors.black,
                                    fontSize: HalfPrintNonGst.extraBoldFontSize,
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      if (settings.isAuthSign)
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Center(
                            child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Container(
                                    padding: const pw.EdgeInsets.only(top: 5),
                                    child: pw.Text(
                                      'For $companyName',
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        color: PdfColor.fromHex('#828282'),
                                        fontSize: 8,
                                      ),
                                    ),
                                  ),
                                  (authSignatory == null)
                                      ? pw.SizedBox(height: 80)
                                      : pw.Container(
                                          height: 80,
                                          child: pw.Image(
                                            authSignatory,
                                            fit: pw.BoxFit.scaleDown,
                                          ),
                                        ),
                                  pw.Container(
                                    height: 30,
                                    child: pw.Text(
                                      "Authorized Signatory",
                                      textAlign: pw.TextAlign.right,
                                      style: pw.TextStyle(
                                        font: HalfPrintNonGst.extraBoldFont,
                                        color: PdfColors.black,
                                        fontSize:
                                            HalfPrintNonGst.extraBoldFontSize,
                                      ),
                                    ),
                                  ),
                                ]),
                          ),
                        )
                    ]),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
