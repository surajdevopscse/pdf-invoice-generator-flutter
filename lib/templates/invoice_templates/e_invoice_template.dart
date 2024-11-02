import 'package:invoice_generator/invoice_generator.dart';
import 'package:invoice_generator/models/pdf_settings.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Mark: E-Invoice Template
// ================================
class EInvoiceTemplate {
  ///FONT STYLE
  static late pw.Font titleFont;
  static late pw.Font subTitleFont;
  static late pw.Font invoiceNumberFont;
  static late pw.Font invoiceDateFont;
  static late pw.Font valuesFont;
  static late pw.Font labelFont;
  static late pw.Font extraBoldFont;
  static late pw.Font fallbackFont;

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

    fallbackFont = await PdfGoogleFonts.lateefRegular();
  }

  static setFontSize(double size) {
    valuesFontSize = size;
    labelFontSize = size + 1;
    titleFontSize = 14;
    extraBoldFontSize = size + 2;
  }

  static Future<pw.Document> getPdf(InvoiceModel data) async {
    final pdf = pw.Document();

    await setFontFamily(data.settings.fontFamily);

    setFontSize(data.settings.fontSize.toDouble());

    final header = await _HeaderBuilder._build(data);
    final addressBlock = await _AddressBlockBuilder._build(data);
    final totalAmountInWords = _ItemListBuilder._buildAmountInWords(
        data.totalAmountInWords, data.moduleType);
    final subTotalGstBlock = await _SubtotalGstBlockBuilder._build(data);
    final footerBlock = await _FooterBuilder._build(
        data.notes, data.termsAndConditionsLink, data.settings);
    final itemsBlock = await _ItemListBuilder._build(data, data.items);
    List<pw.Widget> childrenWidgets = [];

    childrenWidgets = [
      pw.Container(
          child: pw.Column(children: [
        header,
        pw.SizedBox(height: 20),
        addressBlock,
        pw.SizedBox(height: 25)
      ])),
      pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Container(
            margin: const pw.EdgeInsets.only(right: 2),
            child: pw.Text(
              "Currency: ${data.currencyCode}",
              textAlign: pw.TextAlign.right,
              style: const pw.TextStyle(
                fontSize: 8,
              ),
            ),
          )),
      pw.SizedBox(height: 2),
      itemsBlock,
      pw.SizedBox(height: 25),
      pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Expanded(flex: 7, child: totalAmountInWords),
            pw.SizedBox(width: 32),
            pw.Expanded(flex: 8, child: subTotalGstBlock),
          ]),
      pw.SizedBox(height: 70),
      footerBlock,
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: data.settings.orientation == 'Portrait'
            ? PdfPageFormat.a4
            : PdfPageFormat.a4.copyWith(
                width: PdfPageFormat.a4.height, height: PdfPageFormat.a4.width),
        footer: (pw.Context context) {
          return pw.Container(
              alignment: pw.Alignment.centerRight,
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

// Mark: Header Builder Extension
// ================================
extension _HeaderBuilder on EInvoiceTemplate {
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
      pw.Expanded(
        flex: 1,
        child: await _buildLogoWithInvoiceNumber(
            logo,
            data.id,
            data.date,
            EInvoiceTemplate.invoiceNumberFont,
            EInvoiceTemplate.invoiceDateFont,
            EInvoiceTemplate.labelFont,
            data.moduleType,
            data),
      ),
      pw.Expanded(
        child: pw.Column(
            crossAxisAlignment: data.settings.logoAlign.toLowerCase() == 'right'
                ? pw.CrossAxisAlignment.start
                : pw.CrossAxisAlignment.end,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              customLabelValue(
                label: '$label No: ',
                value: invoiceNumber,
              ),
              pw.SizedBox(height: 5),
              customLabelValue(
                label: '$label Date: ',
                value: date,
              ),
              qr != null ? pw.SizedBox(height: 4) : pw.Container(),
              (qr != null) ? qr : pw.Container(),
            ]),
      ),
    ];

    if (logo != null) {
      pw.Alignment logoAlignment =
          (data.settings.logoAlign.toLowerCase() == 'left')
              ? pw.Alignment.centerLeft
              : (data.settings.logoAlign.toLowerCase() == 'right')
                  ? pw.Alignment.centerRight
                  : pw.Alignment.center;

      pw.Widget logoWidget = pw.Expanded(
          child: pw.Align(
              alignment: logoAlignment,
              child: pw.Image(
                logo,
                fit: pw.BoxFit.fill,
                height: data.settings.logoSize,
                width: data.settings.logoSize,
              )));

      if (data.settings.logoAlign.toLowerCase() == 'left') {
        children.insert(0, logoWidget);
      } else if (data.settings.logoAlign.toLowerCase() == 'right') {
        children.add(logoWidget);
      } else {
        children.insert(1, logoWidget);
      }
    }

    return pw.Column(children: [
      pw.Row(children: [
        pw.Spacer(),
        pw.Expanded(
          child: pw.Text(
            data.title,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              fontFallback: [EInvoiceTemplate.fallbackFont],
              font: EInvoiceTemplate.titleFont,
              fontSize: EInvoiceTemplate.titleFontSize,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            data.printCopyTitle,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontFallback: [EInvoiceTemplate.fallbackFont],
              font: EInvoiceTemplate.labelFont,
              fontSize: EInvoiceTemplate.labelFontSize,
            ),
          ),
        ),
      ]),
      pw.SizedBox(height: 32),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children,
      )
    ]);
  }

  static Future<pw.Column> _buildLogoWithInvoiceNumber(
      pw.ImageProvider? logo,
      String invoiceNumber,
      String date,
      pw.Font invoiceNumberFont,
      pw.Font invoiceDateFont,
      pw.Font labelFont,
      String moduleType,
      InvoiceModel data) async {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(data.companyName,
            style: pw.TextStyle(
                fontFallback: [EInvoiceTemplate.fallbackFont],
                font: EInvoiceTemplate.extraBoldFont,
                fontSize: EInvoiceTemplate.extraBoldFontSize)),
        if (data.companyGST.isNotEmpty && data.settings.fieldSettings.gstin)
          customLabelValue(
            label: '${data.taxLabel} : ',
            value: data.companyGST,
          ),
        if (data.companyPan.isNotEmpty &&
            data.settings.fieldSettings.pan &&
            data.isIndia)
          customLabelValue(
            label: 'PAN : ',
            value: data.companyPan,
          ),
        data.companyAddress == null
            ? pw.Container()
            : customLabelValue(
                label: 'Address: ',
                value: data.companyAddress ?? '',
              ),
        data.companyPINCode == null
            ? pw.Container()
            : customLabelValue(
                label: 'Pin Code: ',
                value: data.companyPINCode ?? "",
              ),
      ],
    );
  }
}

// Mark: Address Block Builder Functions Extension
// =================================================
extension _AddressBlockBuilder on EInvoiceTemplate {
  static Future<pw.Row> _build(InvoiceModel data) async {
    final titleFont = await PdfGoogleFonts.mulishBold();
    final labelFont = await PdfGoogleFonts.mulishSemiBold();
    final valuesFont = await PdfGoogleFonts.mulishRegular();

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildAddress(
            "${data.moduleType == 'POR' || data.moduleType == 'PBL' || data.moduleType == 'PDN' || data.moduleType == 'PCN' || data.moduleType == 'EXP' ? "Vendor's" : "Buyer's"} Details",
            titleFont,
            data.buyer.billingAddress,
            null,
            valuesFont,
            labelFont),
        pw.SizedBox(width: 5),
        if (data.settings.fieldSettings.shippingAddress) ...[
          _buildAddress(
              (data.moduleType == 'POR' ||
                      data.moduleType == 'PBL' ||
                      data.moduleType == 'PDN' ||
                      data.moduleType == 'PCN' ||
                      data.moduleType == 'EXP')
                  ? "Delivery Address"
                  : "Shipping Address",
              titleFont,
              data.buyer.shippingAddress,
              (data.settings.fieldSettings.placeOfSupply && data.isIndia)
                  ? data.placeOfSupply
                  : null,
              valuesFont,
              labelFont),
          pw.SizedBox(width: 5),
        ],
        if (data.settings.fieldSettings.bankDetails)
          _buildPayTo(titleFont, data, valuesFont, labelFont),
        if (data.moduleType == 'POR') _buildPODetails(data),
      ],
    );
  }

  static pw.Widget _buildPODetails(InvoiceModel data) {
    if (!data.settings.fieldSettings.validTill &&
        !data.settings.fieldSettings.deliveryDate) {
      return pw.SizedBox();
    }

    return pw.Expanded(
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
          if (data.settings.fieldSettings.validTill)
            customLabelValue(
              label: "Valid Till: ",
              value: data.validTillDate ?? 'N/A',
            ),
          pw.SizedBox(height: 2.5),
          if (data.settings.fieldSettings.deliveryDate)
            customLabelValue(
              label: 'Delivery Date:',
              value: data.deliveryDate ?? 'N/A',
            ),
        ]));
  }

  static pw.Expanded _buildAddress(
      String title,
      pw.Font titleFont,
      InvoiceAddressModel? data,
      String? placeOfSupply,
      pw.Font valuesFont,
      pw.Font labelFont) {
    return pw.Expanded(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontFallback: [EInvoiceTemplate.fallbackFont],
              font: titleFont,
              fontSize: EInvoiceTemplate.titleFontSize - 2,
            ),
          ),
          data?.name == null
              ? pw.Container()
              : pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                      pw.Text(
                        'Name: ',
                        style: pw.TextStyle(
                          fontFallback: [EInvoiceTemplate.fallbackFont],
                          font: labelFont,
                          fontSize: EInvoiceTemplate.labelFontSize,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '${data?.name}',
                          style: pw.TextStyle(
                            fontFallback: [EInvoiceTemplate.fallbackFont],
                            font: valuesFont,
                            fontSize: EInvoiceTemplate.valuesFontSize,
                          ),
                        ),
                      ),
                    ]),
          data?.gstLabel == null
              ? pw.Container()
              : pw.Row(children: [
                  pw.Text(
                    '${data?.gstLabel}: ',
                    style: pw.TextStyle(
                      fontFallback: [EInvoiceTemplate.fallbackFont],
                      font: labelFont,
                      fontSize: EInvoiceTemplate.labelFontSize,
                    ),
                  ),
                  pw.SizedBox(width: 2.5),
                  pw.Text(
                    data?.gstOrPanValue ?? 'N/A',
                    style: pw.TextStyle(
                      fontFallback: [EInvoiceTemplate.fallbackFont],
                      font: valuesFont,
                      fontSize: EInvoiceTemplate.valuesFontSize,
                    ),
                  ),
                ]),
          customLabelValue(
            label: "Address: ",
            value: data?.address == null
                ? null
                : data?.address.toString() ?? 'N/A',
          ),
          pw.SizedBox(height: 2.5),
          customLabelValue(
            label: 'Pin Code: ',
            value: data?.pincode == null
                ? null
                : data?.pincode.toString() ?? 'N/A',
          ),
          placeOfSupply == null
              ? pw.Container()
              : customLabelValue(
                  label: 'Place Of Supply: ',
                  value: placeOfSupply,
                ),
        ],
      ),
    );
  }

  static pw.Expanded _buildPayTo(pw.Font titleFont, InvoiceModel data,
      pw.Font valuesFont, pw.Font labelFont) {
    return pw.Expanded(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "Pay To",
            style: pw.TextStyle(
              fontFallback: [EInvoiceTemplate.fallbackFont],
              font: titleFont,
              fontSize: 12,
            ),
          ),
          //pw.SizedBox(height: 2.5),
          customLabelValue(
            label: "Account Holder’s Name: ",
            value: "${data.buyer.bankAccount?.holderName}",
          ),
          pw.SizedBox(height: 2.5),
          customLabelValue(
            label: 'Bank Account:',
            value: " ${data.buyer.bankAccount?.accountNumber}",
          ),
          pw.SizedBox(height: 2.5),
          customLabelValue(
            label: 'Bank IFSC Code: ',
            value: "${data.buyer.bankAccount?.ifsc}",
          ),
          pw.SizedBox(height: 2.5),
        ],
      ),
    );
  }
}

pw.RichText customLabelValue({required String label, required String? value}) {
  return pw.RichText(
    text: pw.TextSpan(
      text: label,
      style: pw.TextStyle(
        fontFallback: [EInvoiceTemplate.fallbackFont],
        font: EInvoiceTemplate.labelFont,
        fontSize: EInvoiceTemplate.labelFontSize,
      ),
      children: [
        pw.TextSpan(
          text: value ?? 'N/A',
          style: pw.TextStyle(
            fontFallback: [EInvoiceTemplate.fallbackFont],
            font: EInvoiceTemplate.valuesFont,
            fontSize: EInvoiceTemplate.valuesFontSize,
          ),
        ),
      ],
    ),
  );
}

// Mark: Item List Builder Functions Extension
// =============================================
extension _ItemListBuilder on EInvoiceTemplate {
  static Future<pw.Widget> _build(
      InvoiceModel data, List<InvoiceItemModel> items) async {
    final symbolFont = await PdfGoogleFonts.poppinsBold();

    return pw.Column(children: [
      _buildTile(
        symbolFont,
        PdfColor.fromInt(data.settings.backgroundColor.value),
        textColor: PdfColor.fromInt(data.settings.textColor.value),
        showHsn: data.settings.fieldSettings.hsn,
        taxRateLabel: data.taxRateLabel,
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
        final colorIndex = (items.length + 1 % 2 == 0) ? i : i + 1;
        if (i < items.length) {
          // return pw.Container();
          return _buildTile(
            symbolFont,
            (colorIndex % 2 == 0) ? PdfColors.white : PdfColors.grey100,
            isHeader: false,
            showHsn: data.settings.fieldSettings.hsn,
            showItemCode: data.settings.fieldSettings.itemCode,
            showItemUnit: data.settings.fieldSettings.uom,
            showItemDiscount: data.settings.fieldSettings.unitDiscount,
            showItemQty: data.settings.fieldSettings.qty,
            showItemDelivery: data.settings.fieldSettings.unitDelivery,
            showItemFreight: data.settings.fieldSettings.unitFreight,
            index: i,
            taxRateLabel: data.taxRateLabel,
            model: items.elementAt(i),
            showItemDescription: data.settings.fieldSettings.description,
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

  static pw.Container _buildTile(pw.Font fallbackFont, PdfColor backgroundColor,
      {required bool isHeader,
      required bool showHsn,
      required bool showItemCode,
      required bool showItemUnit,
      required bool showItemQty,
      required bool showItemDiscount,
      required bool showItemDelivery,
      required bool showItemFreight,
      required bool showItemDescription,
      required String taxRateLabel,
      int? index,
      InvoiceItemModel? model,
      PdfColor? textColor}) {
    String itemName = '${model?.name}';

    if (showItemCode) {
      itemName += '\nCode : ${model?.code}';
    }

    if (showHsn) {
      itemName += '\n${model?.hsnOrsacLabel}: ${model?.hsn ?? ""}';
    }

    return pw.Container(
      color: backgroundColor,
      padding: const pw.EdgeInsets.symmetric(vertical: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.Text(
              isHeader ? "#" : model!.index.toString(),
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontFallback: [EInvoiceTemplate.fallbackFont],
                font: EInvoiceTemplate.subTitleFont,
                color:
                    isHeader ? textColor ?? PdfColors.white : PdfColors.black,
                fontSize: EInvoiceTemplate.valuesFontSize,
              ),
            ),
          ),
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Text(
                  isHeader ? "Item Name" : itemName,
                  textAlign: pw.TextAlign.left,
                  overflow: pw.TextOverflow.clip,
                  style: pw.TextStyle(
                    fontFallback: [EInvoiceTemplate.fallbackFont],
                    font: EInvoiceTemplate.subTitleFont,
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: EInvoiceTemplate.valuesFontSize,
                  ),
                ),
              )),
          if (showItemDescription)
            pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(
                    isHeader ? "Description" : model?.description ?? "N/A",
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      fontFallback: [EInvoiceTemplate.fallbackFont],
                      font: EInvoiceTemplate.subTitleFont,
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: EInvoiceTemplate.valuesFontSize,
                    ),
                  ),
                )),
          if (showItemQty)
            pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(
                    isHeader ? "QTY" : model?.quantity ?? "",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontFallback: [EInvoiceTemplate.fallbackFont],
                      font: EInvoiceTemplate.subTitleFont,
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: EInvoiceTemplate.valuesFontSize,
                    ),
                  ),
                )),
          if (showItemUnit)
            pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(
                    isHeader ? "Unit" : model?.unit ?? "",
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontFallback: [EInvoiceTemplate.fallbackFont],
                      font: EInvoiceTemplate.subTitleFont,
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: EInvoiceTemplate.valuesFontSize,
                    ),
                  ),
                )),
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Text(
                  isHeader ? "Price/Unit" : model?.price ?? "",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontFallback: [EInvoiceTemplate.fallbackFont],
                    font: EInvoiceTemplate.subTitleFont,
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: EInvoiceTemplate.valuesFontSize,
                  ),
                ),
              )),
          if (showItemDelivery)
            pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(
                    isHeader ? "Delivery/Unit" : model?.delivery ?? "",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontFallback: [EInvoiceTemplate.fallbackFont],
                      font: EInvoiceTemplate.subTitleFont,
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: EInvoiceTemplate.valuesFontSize,
                    ),
                  ),
                )),
          if (showItemFreight)
            pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(
                    isHeader ? "Freight/Unit" : model?.freight ?? "",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontFallback: [EInvoiceTemplate.fallbackFont],
                      font: EInvoiceTemplate.subTitleFont,
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: EInvoiceTemplate.valuesFontSize,
                    ),
                  ),
                )),
          if (showItemDiscount)
            pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(
                    isHeader ? "DISC" : model?.discount ?? "",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontFallback: [EInvoiceTemplate.fallbackFont],
                      font: EInvoiceTemplate.subTitleFont,
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: EInvoiceTemplate.valuesFontSize,
                    ),
                  ),
                )),
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Text(
                  isHeader ? "Taxable" : model?.taxable ?? "",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontFallback: [EInvoiceTemplate.fallbackFont],
                    font: EInvoiceTemplate.subTitleFont,
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: EInvoiceTemplate.valuesFontSize,
                  ),
                ),
              )),
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Text(
                  isHeader ? taxRateLabel : model?.gst ?? "",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontFallback: [EInvoiceTemplate.fallbackFont],
                    font: EInvoiceTemplate.subTitleFont,
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: EInvoiceTemplate.valuesFontSize,
                  ),
                ),
              )),
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Text(
                  isHeader ? "AMT" : model?.amount ?? "",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontFallback: [EInvoiceTemplate.fallbackFont],
                    font: EInvoiceTemplate.subTitleFont,
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: EInvoiceTemplate.valuesFontSize,
                  ),
                ),
              )),
          pw.SizedBox(width: 15),
        ],
      ),
    );
  }

  static pw.Container _buildFooterTile(
      pw.Font titleFont, PdfColor backgroundColor, InvoiceModel model) {
    return pw.Container(
      color: backgroundColor,
      height: 40,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Spacer(flex: 1),
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Text(
                  "Total",
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontFallback: [EInvoiceTemplate.fallbackFont],
                    font: titleFont,
                    color: PdfColors.black,
                    fontSize: EInvoiceTemplate.valuesFontSize,
                  ),
                ),
              )),
          if (model.settings.fieldSettings.description) pw.Spacer(flex: 3),
          if (model.settings.fieldSettings.qty)
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                model.totalQuantities,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontFallback: [EInvoiceTemplate.fallbackFont],
                  font: titleFont,
                  color: PdfColors.black,
                  fontSize: EInvoiceTemplate.valuesFontSize,
                ),
              ),
            ),
          if (model.settings.fieldSettings.uom) pw.Spacer(flex: 2),
          pw.Spacer(flex: 3),
          if (model.settings.fieldSettings.unitDelivery)
            pw.Spacer(
              flex: 3,
            ),
          if (model.settings.fieldSettings.unitFreight)
            pw.Spacer(
              flex: 3,
            ),
          if (model.settings.fieldSettings.unitDiscount)
            pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(
                    model.totalDiscount,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontFallback: [EInvoiceTemplate.fallbackFont],
                      font: titleFont,
                      color: PdfColors.black,
                      fontSize: EInvoiceTemplate.valuesFontSize,
                    ),
                  ),
                )),
          pw.Expanded(
            flex: 3,
            child: pw.Container(
              padding: const pw.EdgeInsets.only(left: 8),
              child: pw.Text(
                model.totalTaxable,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontFallback: [EInvoiceTemplate.fallbackFont],
                  font: titleFont,
                  color: PdfColors.black,
                  fontSize: EInvoiceTemplate.valuesFontSize,
                ),
              ),
            ),
          ),
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Text(
                  model.totalGst,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontFallback: [EInvoiceTemplate.fallbackFont],
                    font: titleFont,
                    color: PdfColors.black,
                    fontSize: EInvoiceTemplate.valuesFontSize,
                  ),
                ),
              )),
          pw.Expanded(
            flex: 3,
            child: pw.Container(
              padding: const pw.EdgeInsets.only(left: 8),
              child: pw.Text(
                model.footerTotalAmount,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  fontFallback: [EInvoiceTemplate.fallbackFont],
                  font: titleFont,
                  color: PdfColors.black,
                  fontSize: EInvoiceTemplate.valuesFontSize,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 15),
        ],
      ),
    );
  }

  static pw.Widget _buildAmountInWords(String amount, String moduleType) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 10),
        pw.Text(
          "${moduleType == 'INV' ? "Invoice " : ""}Amount in Words: ",
          style: pw.TextStyle(
            fontFallback: [EInvoiceTemplate.fallbackFont],
            color: PdfColors.grey700,
            fontSize: EInvoiceTemplate.extraBoldFontSize,
          ),
        ),
        pw.Container(
          child: pw.Text(
            amount,
            maxLines: 2,
            style: pw.TextStyle(
              fontFallback: [EInvoiceTemplate.fallbackFont],
              color: PdfColors.black,
              fontSize: EInvoiceTemplate.extraBoldFontSize,
              font: EInvoiceTemplate.extraBoldFont,
            ),
          ),
        ),
      ],
    );
  }
}

// Mark: Subtotal Gst Block Builder Functions Extension
// =============================================
extension _SubtotalGstBlockBuilder on EInvoiceTemplate {
  static Future<pw.Widget> _build(InvoiceModel data) async {
    final titles = [
      "Taxable Amt.",
      data.cgstLabel,
      data.sgstLabel,
      if (data.isIndia) data.cessLabel,
      "Txn. Level Disc.",
      "Round Off Amt.",
      "Total",
      if (data.moduleType != 'POR') "Received",
      if (data.moduleType != 'POR') "Due",
      if (data.moduleType != "SCN" && data.moduleType != 'POR') "You Saved",
    ];
    final values = [
      data.totalTaxable,
      data.cgstValue,
      data.sgstValue,
      if (data.isIndia) data.cessValue,
      data.txnLevelDiscount,
      data.roundOff,
      data.totalAmount,
      if (data.moduleType != 'POR') data.receivedAmount,
      if (data.moduleType != 'POR') data.due,
      if (data.moduleType != "SCN" && data.moduleType != 'POR')
        data.savedAmount,
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
                    .map((i, e) => MapEntry(
                        i, _buildItem("", titles.elementAt(i) == "Total")))
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
                      i, _buildItem(e, titles.elementAt(i) == "Total")))
                  .values
                  .toList(),
            ),
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
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
    );
  }

  static pw.Widget _buildItem(String text, bool isTotalField) {
    return text.isEmpty
        ? pw.Container()
        : pw.Container(
            height: isTotalField ? 40 : 20,
            constraints: const pw.BoxConstraints(minWidth: 100),
            padding: const pw.EdgeInsets.symmetric(horizontal: 15),
            color: isTotalField ? PdfColors.grey100 : null,
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              text,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontFallback: [EInvoiceTemplate.fallbackFont],
                font: EInvoiceTemplate.titleFont,
                color: PdfColors.black,
                fontSize: isTotalField
                    ? EInvoiceTemplate.extraBoldFontSize
                    : EInvoiceTemplate.valuesFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          );
  }
}

// Mark: Footer Builder Functions Extension
// =============================================
extension _FooterBuilder on EInvoiceTemplate {
  static Future<pw.Widget> _build(String? notes, String? termsAndConditionsLink,
      PdfSettings settings) async {
    final preparedBySign =
        (settings.isPreparedBy && settings.preparedBySignature != null)
            ? pw.MemoryImage(settings.preparedBySignature!)
            : null;
    final checkedBySign =
        (settings.isCheckedBy && settings.checkedBySignature != null)
            ? pw.MemoryImage(settings.checkedBySignature!)
            : null;
    final authSignatory =
        (settings.isAuthSign && settings.authorizedSignatory != null)
            ? pw.MemoryImage(settings.authorizedSignatory!)
            : null;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(children: [
          if (settings.isPreparedBy)
            pw.Expanded(
                child: pw.Column(children: [
              if (preparedBySign != null)
                pw.Container(
                  height: 80,
                  child: pw.Image(
                    preparedBySign!,
                    fit: pw.BoxFit.scaleDown,
                  ),
                ),
              pw.Container(
                height: 30,
                child: pw.Text(
                  "Prepared By",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontFallback: [EInvoiceTemplate.fallbackFont],
                    font: EInvoiceTemplate.extraBoldFont,
                    color: PdfColors.black,
                    fontSize: EInvoiceTemplate.extraBoldFontSize,
                  ),
                ),
              ),
            ])),
          if (settings.isCheckedBy)
            pw.Expanded(
                child: pw.Column(children: [
              if (checkedBySign != null)
                pw.Container(
                  height: 80,
                  child: pw.Image(
                    checkedBySign!,
                    fit: pw.BoxFit.scaleDown,
                  ),
                ),
              pw.Container(
                height: 30,
                child: pw.Text(
                  "Checked By",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontFallback: [EInvoiceTemplate.fallbackFont],
                    font: EInvoiceTemplate.extraBoldFont,
                    color: PdfColors.black,
                    fontSize: EInvoiceTemplate.extraBoldFontSize,
                  ),
                ),
              ),
            ])),
          if (settings.isAuthSign)
            pw.Expanded(
                child: pw.Column(children: [
              if (authSignatory != null)
                pw.Container(
                  height: 80,
                  child: pw.Image(
                    authSignatory!,
                    fit: pw.BoxFit.scaleDown,
                  ),
                ),
              pw.Container(
                height: 30,
                child: pw.Text(
                  "Authorized Signatory",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontFallback: [EInvoiceTemplate.fallbackFont],
                    font: EInvoiceTemplate.extraBoldFont,
                    color: PdfColors.black,
                    fontSize: EInvoiceTemplate.extraBoldFontSize,
                  ),
                ),
              ),
            ])),
        ]),
        pw.Row(
          children: [
            if (settings.fieldSettings.termAndCondition) ...[
              pw.Container(
                height: 30,
                child: pw.RichText(
                  text: pw.TextSpan(
                    text: "Terms & Conditions *",
                    annotation: pw.AnnotationLink(termsAndConditionsLink ?? ""),
                    style: pw.TextStyle(
                        fontFallback: [EInvoiceTemplate.fallbackFont],
                        font: EInvoiceTemplate.titleFont,
                        color: PdfColors.blue300,
                        fontSize: EInvoiceTemplate.valuesFontSize),
                  ),
                ),
              ),
              pw.SizedBox(width: 10),
            ],
            if (settings.fieldSettings.notes)
              pw.Expanded(
                child: pw.Text(
                  notes ?? "",
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                      fontFallback: [EInvoiceTemplate.fallbackFont],
                      font: EInvoiceTemplate.titleFont,
                      color: PdfColors.black,
                      fontSize: EInvoiceTemplate.valuesFontSize),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
