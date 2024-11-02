import 'package:collection/collection.dart';
import 'package:invoice_generator/invoice_generator.dart';
import 'package:invoice_generator/models/pdf_settings.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Mark: E-Invoice Template
// ================================
class TaxTemplate3 {
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
    final bottom = await _BottomBuilder._build(data);
    final addressBlock = await _AddressBlockBuilder._build(data);
    final additionalFieldBlock =
        await _AdditionalFieldBlockBuilder._build(data);
    final totalAmountInWords = _ItemListBuilder._buildAmountInWords(
        data.totalAmountInWords, data.moduleType, data.items.length, data);
    final subTotalGstBlock = await _SubtotalGstBlockBuilder._build(data);
    final footerBlock = await _FooterBuilder._build(data.notes,
        data.termsAndConditionsLink, data.settings, data.companyName);
    final itemsBlock = await _ItemListBuilder._build(data, data.items);
    List<pw.Widget> childrenWidgets = [];

    childrenWidgets = [
      pw.Container(
          child: pw.Column(children: [
        header,
        pw.SizedBox(height: 20),
        addressBlock,
        pw.SizedBox(height: 20),
        additionalFieldBlock,
        pw.SizedBox(height: 20),
      ])),
      pw.SizedBox(height: 5),
      itemsBlock,
      pw.SizedBox(height: 25),
      pw.Row(
          mainAxisSize: pw.MainAxisSize.min,
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            pw.Expanded(flex: 8, child: subTotalGstBlock),
          ]),
      pw.SizedBox(height: 5),
      totalAmountInWords,
      pw.SizedBox(height: 20),
      bottom,
      footerBlock
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
                  'Page ${context.pageNumber}/${context.pagesCount} ${(data.moduleType != 'POR' || data.moduleType != 'SOR' || data.moduleType != 'SQU') ? data.printCopyTitle : ''}',
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
extension _HeaderBuilder on TaxTemplate3 {
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
            TaxTemplate3.invoiceNumberFont,
            TaxTemplate3.invoiceDateFont,
            TaxTemplate3.labelFont,
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
          ),
        ),
      );

      // if (data.settings.logoAlign.toLowerCase() == 'left') {
      //   children.insert(0, logoWidget);
      // } else if (data.settings.logoAlign.toLowerCase() == 'right') {
      //   children.add(logoWidget);
      // } else {
      //   children.insert(1, logoWidget);
      // }
    }
    return pw.Column(
      children: [
        pw.Align(
          alignment: data.settings.logoAlign.toLowerCase() == 'right'
              ? pw.Alignment.topLeft
              : pw.Alignment.topRight,
          child: pw.Text(
            data.title,
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(
              font: TaxTemplate3.titleFont,
              fontSize: TaxTemplate3.titleFontSize,
              color: PdfColor.fromHex('#007CA4'),
            ),
          ),
        ),
        if (moduleType != 'POR' || moduleType != 'SOR' || moduleType != 'SQU')
          pw.Align(
            alignment: data.settings.logoAlign.toLowerCase() == 'right'
                ? pw.Alignment.topLeft
                : pw.Alignment.topRight,
            child: pw.Text(
              data.printCopyTitle,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: TaxTemplate3.labelFont,
                fontSize: TaxTemplate3.labelFontSize,
              ),
            ),
          ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          children: [
            if (logo != null)
              if (data.settings.logoAlign.toLowerCase() == 'left')
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Image(
                    logo,
                    fit: pw.BoxFit.fill,
                    height: data.settings.logoSize,
                    width: data.settings.logoSize,
                  ),
                ),
            if (logo != null)
              if (data.settings.logoAlign.toLowerCase() == 'left')
                pw.SizedBox(width: 15),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  data.companyName,
                  style: pw.TextStyle(
                    font: TaxTemplate3.extraBoldFont,
                    fontSize: TaxTemplate3.extraBoldFontSize,
                  ),
                ),
                if (data.companyGST.isNotEmpty &&
                    data.settings.fieldSettings.gstin)
                  customLabelValue(
                    label: 'GSTIN : ',
                    value: data.companyGST,
                  ),
                if (data.companyPan.isNotEmpty &&
                    data.settings.fieldSettings.pan)
                  customLabelValue(
                    label: 'PAN : ',
                    value: data.companyPan,
                  ),
                pw.Row(
                  children: [
                    data.companyAddress == null
                        ? pw.Container()
                        : customLabelValue(
                            label: '',
                            value: (data.companyAddress ?? '') +
                                ((data.companyPINCode?.isNotEmpty == true)
                                    ? ' - ${data.companyPINCode ?? ""}'
                                    : ''),
                            maxWidth: 300,
                          ),
                    // data.companyPINCode == null
                    //     ? pw.Container()
                    //     : customLabelValue(
                    //         label: ' - ',
                    //         value: data.companyPINCode ?? "",
                    //       ),
                  ],
                ),
                // pw.Row(
                //   children: [
                //     data.companyAddress == null
                //         ? pw.Container()
                //         : customLabelValue(
                //             label: '',
                //             value: data.companyAddress ?? '',
                //             maxWidth: 400,
                //           ),
                //     data.companyPINCode == null
                //         ? pw.Container()
                //         : customLabelValue(
                //             label: ' - ',
                //             value: data.companyPINCode ?? "",
                //           ),
                //   ],
                // ),
                data.seller.phone == null
                    ? pw.Container()
                    : customLabelValue(
                        label: 'Mobile ',
                        value: data.seller.phone ?? "",
                      ),
              ],
            ),
            if (data.settings.logoAlign.toLowerCase() == 'middle' ||
                data.settings.logoAlign.toLowerCase() == 'right')
              pw.Spacer(),
            if (logo != null)
              if (data.settings.logoAlign.toLowerCase() == 'right' ||
                  data.settings.logoAlign.toLowerCase() == 'middle')
                pw.Align(
                  alignment: data.settings.logoAlign.toLowerCase() == 'right'
                      ? pw.Alignment.centerRight
                      : pw.Alignment.center,
                  child: pw.Image(
                    logo,
                    fit: pw.BoxFit.fill,
                    height: data.settings.logoSize,
                    width: data.settings.logoSize,
                  ),
                ),
            if (data.settings.logoAlign.toLowerCase() == 'middle')
              pw.Spacer(flex: 2)
          ],
        ),
        pw.SizedBox(
          height: 10,
        ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            customLabelValue(
              label: '$label No: ',
              value: invoiceNumber,
            ),
            customLabelValue(
              label: '$label Date: ',
              value: date,
            ),
            customLabelValue(
              label: 'Place of Supply: ',
              value: data.placeOfSupply,
            ),
          ],
        ),
      ],
    );
    // return pw.Column(children: [

    //   pw.Row(children: [
    //     pw.Spacer(),
    //     pw.Expanded(
    //       child: pw.Text(
    //         data.title,
    //         textAlign: pw.TextAlign.center,
    //         style: pw.TextStyle(
    //           font: TaxTemplate3.titleFont,
    //           fontSize: TaxTemplate3.titleFontSize,
    //         ),
    //       ),
    //     ),
    //     pw.Expanded(
    //       child: pw.Text(
    //         data.printCopyTitle,
    //         textAlign: pw.TextAlign.right,
    //         style: pw.TextStyle(
    //           font: TaxTemplate3.labelFont,
    //           fontSize: TaxTemplate3.labelFontSize,
    //         ),
    //       ),
    //     ),
    //   ]),
    //   pw.SizedBox(height: 32),
    //   pw.Row(
    //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    //     crossAxisAlignment: pw.CrossAxisAlignment.start,
    //     children: children,
    //   )
    // ]);
  }

  static Future<pw.Widget> _buildLogoWithInvoiceNumber(
      pw.ImageProvider? logo,
      String invoiceNumber,
      String date,
      pw.Font invoiceNumberFont,
      pw.Font invoiceDateFont,
      pw.Font labelFont,
      String moduleType,
      InvoiceModel data) async {
    return pw.ConstrainedBox(
      constraints: const pw.BoxConstraints(
        maxWidth: 200,
      ),
      child: pw.Column(
        children: [
          pw.Text(data.companyName,
              style: pw.TextStyle(
                  font: TaxTemplate3.extraBoldFont,
                  fontSize: TaxTemplate3.extraBoldFontSize)),
          if (data.companyGST.isNotEmpty && data.settings.fieldSettings.gstin)
            customLabelValue(
              label: 'GSTIN : ',
              value: data.companyGST,
            ),
          if (data.companyPan.isNotEmpty && data.settings.fieldSettings.pan)
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
      ),
    );
  }
}

// Mark Bottom Builder Extension
// ===============================
extension _BottomBuilder on TaxTemplate3 {
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
      // qr != null
      //     ? pw.Text(
      //         'Pay using UPI',
      //         style: const pw.TextStyle(
      //           fontSize: 10,
      //         ),
      //       )
      //     : pw.Container(),
      // qr != null ? pw.Expanded(child: pw.SizedBox()) : pw.SizedBox(),
      qr != null ? pw.SizedBox(width: 240) : pw.Container(),

      if (data.settings.fieldSettings.bankDetails)
        pw.Text(
          'Bank Details:',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.normal,
          ),
        ),
      pw.Spacer(),
      pw.Text(
        '',
        style: pw.TextStyle(
          color: PdfColor.fromHex('#828282'),
          fontSize: 8,
        ),
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

      // if (data.settings.logoAlign.toLowerCase() == 'left') {
      //   children.insert(0, logoWidget);
      // } else if (data.settings.logoAlign.toLowerCase() == 'right') {
      //   children.add(logoWidget);
      // } else {
      //   children.insert(1, logoWidget);
      // }
    }
    return pw.Container(
      margin: const pw.EdgeInsets.only(
        left: 15,
        right: 15,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            // mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            // crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: children,
          ),
          pw.SizedBox(height: 5),
          pw.Row(
            // mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              (qr != null) ? qr : pw.Container(),
              qr != null ? pw.SizedBox(width: 40) : pw.Container(),
              if (data.settings.fieldSettings.bankDetails)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    customLabelValue(
                      label: "Bank:     ",
                      value: "${data.buyer.bankAccount?.bankName}",
                    ),
                    customLabelValue(
                      label: "A/c No:  ",
                      value: "${data.buyer.bankAccount?.accountNumber}",
                    ),
                    customLabelValue(
                      label: "IFSC:      ",
                      value: "${data.buyer.bankAccount?.ifsc}",
                    ),
                    customLabelValue(
                      label: "Branch:  ",
                      value: "${data.buyer.bankAccount?.branchName}",
                    ),
                  ],
                ),
            ],
          ),
          pw.SizedBox(height: 16),
          if (data.settings.fieldSettings.notes)
            pw.Text(
              'Note:',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
          if (data.settings.fieldSettings.notes) pw.SizedBox(height: 5),
          if (data.settings.fieldSettings.notes)
            pw.Text(
              data.notes ?? 'N/A',
              style:
                  pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.normal),
            ),
        ],
      ),
    );
  }
}

// Mark: Address Block Builder Functions Extension
// =================================================
extension _AddressBlockBuilder on TaxTemplate3 {
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
            data.buyer.phone,
            true,
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
              null,
              false,
              (data.settings.fieldSettings.placeOfSupply)
                  ? data.placeOfSupply
                  : null,
              valuesFont,
              labelFont),
          pw.SizedBox(width: 5),
        ],
        // if (data.settings.fieldSettings.bankDetails)
        //   _buildPayTo(titleFont, data, valuesFont, labelFont),
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
      String? mobileNumber,
      bool showMobileNumber,
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
              font: titleFont,
              fontSize: TaxTemplate3.titleFontSize - 2,
            ),
          ),
          data?.name == null
              ? pw.Container()
              : pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                      pw.Text(
                        '',
                        style: pw.TextStyle(
                          font: labelFont,
                          fontSize: TaxTemplate3.labelFontSize,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '${data?.name}',
                          style: pw.TextStyle(
                            font: valuesFont,
                            fontSize: TaxTemplate3.valuesFontSize,
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
                      font: labelFont,
                      fontSize: TaxTemplate3.labelFontSize,
                    ),
                  ),
                  pw.SizedBox(width: 2.5),
                  pw.Text(
                    data?.gstOrPanValue ?? 'N/A',
                    style: pw.TextStyle(
                      font: valuesFont,
                      fontSize: TaxTemplate3.valuesFontSize,
                    ),
                  ),
                ]),
          customLabelValue(
            label: "",
            value: data?.address == null
                ? null
                : data?.address.toString() ?? 'N/A',
          ),
          pw.SizedBox(height: 2.5),
          customLabelValue(
            label: 'Pincode: ',
            value: data?.pincode == null
                ? null
                : data?.pincode.toString() ?? 'N/A',
          ),
          pw.SizedBox(height: 2.5),
          if (showMobileNumber)
            customLabelValue(
              label: 'Mobile: ',
              value: mobileNumber,
            ),
          // placeOfSupply == null
          //     ? pw.Container()
          //     : customLabelValue(
          //         label: 'Place Of Supply: ',
          //         value: placeOfSupply,
          //       ),
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

extension _AdditionalFieldBlockBuilder on TaxTemplate3 {
  static Future<pw.Row> _build(InvoiceModel data) async {
    final titleFont = await PdfGoogleFonts.mulishBold();
    final labelFont = await PdfGoogleFonts.mulishSemiBold();
    final valuesFont = await PdfGoogleFonts.mulishRegular();

    return pw.Row(
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
                            fontSize: TaxTemplate3.valuesFontSize + 2,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          e.value,
                          style: pw.TextStyle(
                            font: labelFont,
                            fontSize: TaxTemplate3.valuesFontSize,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        )
                      ],
                    )))) ??
            [],
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
      String? mobileNumber,
      bool showMobileNumber,
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
              font: titleFont,
              fontSize: TaxTemplate3.titleFontSize - 2,
            ),
          ),
          data?.name == null
              ? pw.Container()
              : pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                      pw.Text(
                        '',
                        style: pw.TextStyle(
                          font: labelFont,
                          fontSize: TaxTemplate3.labelFontSize,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '${data?.name}',
                          style: pw.TextStyle(
                            font: valuesFont,
                            fontSize: TaxTemplate3.valuesFontSize,
                          ),
                        ),
                      ),
                    ]),
          data?.gstLabel == null
              ? pw.Container()
              : customLabelValue(
                  label: '${data?.gstLabel}: ',
                  value: data?.gstOrPanValue ?? 'N/A',
                ),
          customLabelValue(
            label: "",
            value: data?.address == null
                ? null
                : data?.address.toString() ?? 'N/A',
          ),
          pw.SizedBox(height: 2.5),
          customLabelValue(
            label: 'Pincode: ',
            value: data?.pincode == null
                ? null
                : data?.pincode.toString() ?? 'N/A',
          ),
          pw.SizedBox(height: 2.5),
          if (showMobileNumber)
            customLabelValue(
              label: 'Mobile: ',
              value: mobileNumber,
            ),
          // placeOfSupply == null
          //     ? pw.Container()
          //     : customLabelValue(
          //         label: 'Place Of Supply: ',
          //         value: placeOfSupply,
          //       ),
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

pw.Widget customLabelValue(
    {required String label, required String? value, double? maxWidth}) {
  return pw.ConstrainedBox(
    constraints: pw.BoxConstraints(
      maxWidth: maxWidth ?? double.infinity,
    ),
    child: pw.RichText(
      text: pw.TextSpan(
        text: label,
        style: pw.TextStyle(
          font: TaxTemplate3.labelFont,
          fontSize: TaxTemplate3.labelFontSize,
        ),
        children: [
          pw.TextSpan(
            text: (value == 'null') ? 'N/A' : value ?? 'N/A',
            style: pw.TextStyle(
              font: TaxTemplate3.valuesFont,
              fontSize: TaxTemplate3.valuesFontSize,
            ),
          ),
        ],
      ),
    ),
  );
}

// Mark: Item List Builder Functions Extension
// =============================================
extension _ItemListBuilder on TaxTemplate3 {
  static Future<pw.Widget> _build(
      InvoiceModel data, List<InvoiceItemModel> items) async {
    final symbolFont = await PdfGoogleFonts.poppinsBold();

    List<String> afterUnitPriceFieldsTitle = [];
    List<String> afterDiscountPriceFieldsTitle = [];
    List<String> afterTaxableFieldsTitle = [];
    List<String> afterUnitAndDiscountFieldsTitle = [];
    List<String> nonNumericFieldsTitle = [];
    for (int i = 0; i < items.length; i++) {
      items[i]
          .afterUnitPriceFields
          .map((e) => afterUnitPriceFieldsTitle.add(e.name))
          .toList();

      items[i]
          .afterTaxableFields
          .map((e) => afterTaxableFieldsTitle.add(e.name))
          .toList();

      items[i]
          .afterUnitAndDiscountFields
          .map((e) => afterUnitAndDiscountFieldsTitle.add(e.name))
          .toList();
      items[i]
          .afterDiscountPriceFields
          .map((e) => afterDiscountPriceFieldsTitle.add(e.name))
          .toList();
      items[i]
          .nonNumericFields
          .map((e) => nonNumericFieldsTitle.add(e.name))
          .toList();
    }
    afterUnitPriceFieldsTitle = afterUnitPriceFieldsTitle.toSet().toList();
    afterDiscountPriceFieldsTitle =
        afterDiscountPriceFieldsTitle.toSet().toList();
    afterTaxableFieldsTitle = afterTaxableFieldsTitle.toSet().toList();
    afterUnitAndDiscountFieldsTitle =
        afterUnitAndDiscountFieldsTitle.toSet().toList();
    nonNumericFieldsTitle = nonNumericFieldsTitle.toSet().toList();

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
        afterUnitPriceFieldsTitle: afterUnitPriceFieldsTitle,
        afterDiscountPriceFieldsTitle: afterDiscountPriceFieldsTitle,
        afterTaxableFieldsTitle: afterTaxableFieldsTitle,
        afterUnitAndDiscountFieldsTitle: afterUnitAndDiscountFieldsTitle,
        nonNumericFieldsTitle: nonNumericFieldsTitle,
        showItemDescription: data.settings.fieldSettings.description,
        showBorder: true,
      ),
      ...List.generate(items.length + 1, (i) {
        // final colorIndex = (items.length + 1 % 2 == 0) ? i : i + 1;
        if (i < items.length) {
          // return pw.Container();
          return pw.Column(
            children: [
              _buildTile(
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
                afterUnitPriceFieldsTitle: afterUnitPriceFieldsTitle,
                afterDiscountPriceFieldsTitle: afterDiscountPriceFieldsTitle,
                afterTaxableFieldsTitle: afterTaxableFieldsTitle,
                afterUnitAndDiscountFieldsTitle:
                    afterUnitAndDiscountFieldsTitle,
                nonNumericFieldsTitle: nonNumericFieldsTitle,
                model: items.elementAt(i),
                showItemDescription: data.settings.fieldSettings.description,
                showBorder: false,
              ),
              pw.Divider(height: 1, color: PdfColors.grey),
            ],
          );
        } else {
          return _buildFooterTile(
            titleFont: symbolFont,
            backgroundColor: PdfColors.white,
            afterUnitPriceFieldsTitle: afterUnitPriceFieldsTitle,
            afterDiscountPriceFieldsTitle: afterDiscountPriceFieldsTitle,
            afterTaxableFieldsTitle: afterTaxableFieldsTitle,
            afterUnitAndDiscountFieldsTitle: afterUnitAndDiscountFieldsTitle,
            nonNumericFieldsTitle: nonNumericFieldsTitle,
            model: data,
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
      required bool showBorder,
      List<String> afterUnitPriceFieldsTitle = const [],
      List<String> afterDiscountPriceFieldsTitle = const [],
      List<String> afterTaxableFieldsTitle = const [],
      List<String> afterUnitAndDiscountFieldsTitle = const [],
      List<String> nonNumericFieldsTitle = const [],
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

    // if (showHsn) {
    //   itemName += '\n${model?.hsnOrsacLabel}: ${model?.hsn ?? ""}';
    // }

    return pw.Container(
      decoration: pw.BoxDecoration(
        color: backgroundColor,
        border: showBorder
            ? const pw.Border(
                top: pw.BorderSide(),
                bottom: pw.BorderSide(),
              )
            : null,
      ),
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
                font: TaxTemplate3.subTitleFont,
                fontFallback: [fallbackFont],
                color:
                    isHeader ? textColor ?? PdfColors.white : PdfColors.black,
                fontSize: TaxTemplate3.valuesFontSize,
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
                    font: TaxTemplate3.subTitleFont,
                    fontFallback: [fallbackFont],
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: TaxTemplate3.valuesFontSize,
                  ),
                ),
              )),
          if (showHsn)
            pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(
                    isHeader ? "HSN/SAC" : model?.hsn ?? "N/A",
                    textAlign: pw.TextAlign.left,
                    style: pw.TextStyle(
                      font: TaxTemplate3.subTitleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: TaxTemplate3.valuesFontSize,
                    ),
                  ),
                )),
          if (showItemQty)
            pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(
                    isHeader ? "Qty" : model?.quantity ?? "",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      font: TaxTemplate3.subTitleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: TaxTemplate3.valuesFontSize,
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
                      font: TaxTemplate3.subTitleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: TaxTemplate3.valuesFontSize,
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
                    font: TaxTemplate3.subTitleFont,
                    fontFallback: [fallbackFont],
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: TaxTemplate3.valuesFontSize,
                  ),
                ),
              )),
          if (isHeader)
            ...afterUnitPriceFieldsTitle.map(
                  (e) => pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      child: pw.Expanded(
                        flex: 3,
                        child: pw.Container(
                          child: pw.Text(
                            e,
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              font: TaxTemplate3.subTitleFont,
                              fontFallback: [fallbackFont],
                              color: isHeader
                                  ? textColor ?? PdfColors.white
                                  : PdfColors.black,
                              fontSize: TaxTemplate3.valuesFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ) ??
                [],
          if (!isHeader)
            ...afterUnitPriceFieldsTitle.map(
                  (e) {
                    String value = model?.afterUnitPriceFields
                            .firstWhereOrNull((element) => element.name == e)
                            ?.totalValue ??
                        '';
                    return pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        child: pw.Text(
                          value,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            font: TaxTemplate3.subTitleFont,
                            fontFallback: [fallbackFont],
                            color: isHeader
                                ? textColor ?? PdfColors.white
                                : PdfColors.black,
                            fontSize: TaxTemplate3.valuesFontSize,
                          ),
                        ),
                      ),
                    );
                  },
                ) ??
                [],
          if (showItemDelivery)
            pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(
                    isHeader ? "Delivery/Unit" : model?.delivery ?? "",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      font: TaxTemplate3.subTitleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: TaxTemplate3.valuesFontSize,
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
                      font: TaxTemplate3.subTitleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: TaxTemplate3.valuesFontSize,
                    ),
                  ),
                )),
          if (showItemDiscount)
            pw.Expanded(
                flex: 3,
                child: pw.Container(
                  padding: const pw.EdgeInsets.only(left: 8),
                  child: pw.Text(
                    isHeader ? "Disc." : model?.discount ?? "",
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      font: TaxTemplate3.subTitleFont,
                      fontFallback: [fallbackFont],
                      color: isHeader
                          ? textColor ?? PdfColors.white
                          : PdfColors.black,
                      fontSize: TaxTemplate3.valuesFontSize,
                    ),
                  ),
                )),
          if (isHeader)
            ...afterDiscountPriceFieldsTitle.map(
                  (e) => pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      child: pw.Expanded(
                        flex: 3,
                        child: pw.Container(
                          child: pw.Text(
                            e,
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              font: TaxTemplate3.subTitleFont,
                              fontFallback: [fallbackFont],
                              color: isHeader
                                  ? textColor ?? PdfColors.white
                                  : PdfColors.black,
                              fontSize: TaxTemplate3.valuesFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ) ??
                [],
          if (!isHeader)
            ...afterDiscountPriceFieldsTitle.map(
                  (e) {
                    String value = model?.afterDiscountPriceFields
                            .firstWhereOrNull((element) => element.name == e)
                            ?.totalValue ??
                        '';
                    return pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        child: pw.Text(
                          value,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            font: TaxTemplate3.subTitleFont,
                            fontFallback: [fallbackFont],
                            color: isHeader
                                ? textColor ?? PdfColors.white
                                : PdfColors.black,
                            fontSize: TaxTemplate3.valuesFontSize,
                          ),
                        ),
                      ),
                    );
                  },
                ) ??
                [],
          if (isHeader)
            ...afterUnitAndDiscountFieldsTitle.map(
                  (e) => pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      child: pw.Expanded(
                        flex: 3,
                        child: pw.Container(
                          child: pw.Text(
                            e,
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              font: TaxTemplate3.subTitleFont,
                              fontFallback: [fallbackFont],
                              color: isHeader
                                  ? textColor ?? PdfColors.white
                                  : PdfColors.black,
                              fontSize: TaxTemplate3.valuesFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ) ??
                [],
          if (!isHeader)
            ...afterUnitAndDiscountFieldsTitle.map(
                  (e) {
                    String value = model?.afterUnitAndDiscountFields
                            .firstWhereOrNull((element) => element.name == e)
                            ?.totalValue ??
                        '';
                    return pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        child: pw.Text(
                          value,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            font: TaxTemplate3.subTitleFont,
                            fontFallback: [fallbackFont],
                            color: isHeader
                                ? textColor ?? PdfColors.white
                                : PdfColors.black,
                            fontSize: TaxTemplate3.valuesFontSize,
                          ),
                        ),
                      ),
                    );
                  },
                ) ??
                [],
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Text(
                  isHeader ? "Taxable" : model?.taxable ?? "",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: TaxTemplate3.subTitleFont,
                    fontFallback: [fallbackFont],
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: TaxTemplate3.valuesFontSize,
                  ),
                ),
              )),
          if (isHeader)
            ...afterTaxableFieldsTitle.map(
                  (e) => pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      child: pw.Expanded(
                        flex: 3,
                        child: pw.Container(
                          child: pw.Text(
                            e,
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              font: TaxTemplate3.subTitleFont,
                              fontFallback: [fallbackFont],
                              color: isHeader
                                  ? textColor ?? PdfColors.white
                                  : PdfColors.black,
                              fontSize: TaxTemplate3.valuesFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ) ??
                [],
          if (!isHeader)
            ...afterTaxableFieldsTitle.map(
                  (e) {
                    String value = model?.afterTaxableFields
                            .firstWhereOrNull((element) => element.name == e)
                            ?.totalValue ??
                        '';
                    return pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        child: pw.Text(
                          value,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            font: TaxTemplate3.subTitleFont,
                            fontFallback: [fallbackFont],
                            color: isHeader
                                ? textColor ?? PdfColors.white
                                : PdfColors.black,
                            fontSize: TaxTemplate3.valuesFontSize,
                          ),
                        ),
                      ),
                    );
                  },
                ) ??
                [],
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Text(
                  isHeader ? "GST" : model?.gst ?? "",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: TaxTemplate3.subTitleFont,
                    fontFallback: [fallbackFont],
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: TaxTemplate3.valuesFontSize,
                  ),
                ),
              )),
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Text(
                  isHeader ? "Amt.(INR)" : model?.amount ?? "",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: TaxTemplate3.subTitleFont,
                    fontFallback: [fallbackFont],
                    color: isHeader
                        ? textColor ?? PdfColors.white
                        : PdfColors.black,
                    fontSize: TaxTemplate3.valuesFontSize,
                  ),
                ),
              )),
          if (isHeader)
            ...nonNumericFieldsTitle.map(
                  (e) => pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      child: pw.Expanded(
                        flex: 3,
                        child: pw.Container(
                          padding: const pw.EdgeInsets.only(
                            right: 8,
                          ),
                          child: pw.Text(
                            e,
                            textAlign: pw.TextAlign.right,
                            style: pw.TextStyle(
                              font: TaxTemplate3.subTitleFont,
                              fontFallback: [fallbackFont],
                              color: isHeader
                                  ? textColor ?? PdfColors.white
                                  : PdfColors.black,
                              fontSize: TaxTemplate3.valuesFontSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ) ??
                [],
          if (!isHeader)
            ...nonNumericFieldsTitle.map(
                  (e) {
                    String value = model?.nonNumericFields
                            .firstWhereOrNull((element) => element.name == e)
                            ?.totalValue ??
                        '';
                    return pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.only(
                          right: 8,
                        ),
                        child: pw.Text(
                          value,
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            font: TaxTemplate3.subTitleFont,
                            fontFallback: [fallbackFont],
                            color: isHeader
                                ? textColor ?? PdfColors.white
                                : PdfColors.black,
                            fontSize: TaxTemplate3.valuesFontSize,
                          ),
                        ),
                      ),
                    );
                  },
                ) ??
                [],
        ],
      ),
    );
  }

  static pw.Container _buildFooterTile({
    required pw.Font titleFont,
    required PdfColor backgroundColor,
    required InvoiceModel model,
    List<String> afterUnitPriceFieldsTitle = const [],
    List<String> afterDiscountPriceFieldsTitle = const [],
    List<String> afterTaxableFieldsTitle = const [],
    List<String> afterUnitAndDiscountFieldsTitle = const [],
    List<String> nonNumericFieldsTitle = const [],
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8, bottom: 8),
      decoration: pw.BoxDecoration(
          color: backgroundColor,
          border: const pw.Border(
            top: pw.BorderSide(
              color: PdfColors.grey500,
            ),
            bottom: pw.BorderSide(
              color: PdfColors.grey500,
            ),
          )),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 1,
            child: pw.SizedBox(),
          ),
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Text(
                  "Total",
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    font: titleFont,
                    color: PdfColors.black,
                    fontSize: TaxTemplate3.valuesFontSize,
                  ),
                ),
              )),
          if (model.settings.fieldSettings.hsn)
            pw.Expanded(
              flex: 3,
              child: pw.SizedBox(),
            ),
          if (model.settings.fieldSettings.qty)
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                model.totalQuantities,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: titleFont,
                  color: PdfColors.black,
                  fontSize: TaxTemplate3.valuesFontSize,
                ),
              ),
            ),
          if (model.settings.fieldSettings.uom)
            pw.Expanded(
              flex: 2,
              child: pw.SizedBox(),
            ),
          pw.Expanded(
            flex: 3,
            child: pw.SizedBox(),
          ),
          if (model.settings.fieldSettings.unitDelivery)
            pw.Expanded(
              flex: 3,
              child: pw.SizedBox(),
            ),
          ...afterUnitPriceFieldsTitle.map((e) => pw.Expanded(
                    flex: 3,
                    child: pw.SizedBox(),
                  )) ??
              [],
          if (model.settings.fieldSettings.unitFreight)
            pw.Expanded(
              flex: 3,
              child: pw.SizedBox(),
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
                      font: titleFont,
                      color: PdfColors.black,
                      fontSize: TaxTemplate3.valuesFontSize,
                    ),
                  ),
                )),
          ...afterDiscountPriceFieldsTitle.map((e) => pw.Expanded(
                    flex: 3,
                    child: pw.SizedBox(),
                  )) ??
              [],
          ...afterUnitAndDiscountFieldsTitle.map((e) => pw.Expanded(
                    flex: 3,
                    child: pw.SizedBox(),
                  )) ??
              [],
          pw.Expanded(
            flex: 3,
            child: pw.Container(
              padding: const pw.EdgeInsets.only(left: 8),
              child: pw.Text(
                model.totalTaxable,
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                  font: titleFont,
                  color: PdfColors.black,
                  fontSize: TaxTemplate3.valuesFontSize,
                ),
              ),
            ),
          ),
          ...afterTaxableFieldsTitle.map((e) => pw.Expanded(
                    flex: 3,
                    child: pw.SizedBox(),
                  )) ??
              [],
          pw.Expanded(
              flex: 3,
              child: pw.Container(
                padding: const pw.EdgeInsets.only(left: 8),
                child: pw.Text(
                  model.totalGst,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: titleFont,
                    color: PdfColors.black,
                    fontSize: TaxTemplate3.valuesFontSize,
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
                  font: titleFont,
                  color: PdfColors.black,
                  fontSize: TaxTemplate3.valuesFontSize,
                ),
              ),
            ),
          ),
          ...nonNumericFieldsTitle.map((e) => pw.Expanded(
                    flex: 3,
                    child: pw.SizedBox(),
                  )) ??
              [],
        ],
      ),
    );
  }

  static pw.Widget _buildAmountInWords(
      String amount, String moduleType, int itemCount, InvoiceModel data) {
    Set<String> newKeys = data.items
        .where((element) => element.hsn.isNotEmpty)
        .map((e) => '${e.hsn}#${e.gstRate}')
        .toSet();

    for (var i = 0; i < newKeys.length; i++) {
      String keyValue = newKeys.elementAt(i);
      List key = keyValue.split('#');
      String hsnvalue = key[0];
      String gstRate = key[1];

      for (var j = 0; j < data.items.length; j++) {}
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(left: 15, right: 15),
      child: pw.Column(
        children: [
          pw.Row(
            // crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Total Items: $itemCount',
                style: const pw.TextStyle(
                  color: PdfColors.grey700,
                  fontSize: 8,
                ),
              ),
              pw.Row(
                children: [
                  pw.Text(
                    "Total Amount (in Words): ",
                    style: const pw.TextStyle(
                      color: PdfColors.grey700,
                      fontSize: 8,
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Container(
                    child: pw.Text(
                      '$amount Only',
                      maxLines: 2,
                      style: const pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Column(
            children: [
              if (data.hsnItems.isNotEmpty)
                pw.Table(
                    defaultColumnWidth: const pw.FlexColumnWidth(),
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColor.fromInt(
                              data.settings.backgroundColor.value),
                          border: const pw.Border(
                            top: pw.BorderSide(),
                            bottom: pw.BorderSide(),
                          ),
                        ),
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'HSN/SAC',
                              textAlign: pw.TextAlign.left,
                              style: pw.TextStyle(
                                font: TaxTemplate3.labelFont,
                                fontSize: TaxTemplate3.labelFontSize,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(
                                    data.settings.textColor.value),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Taxable Value',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                font: TaxTemplate3.labelFont,
                                fontSize: TaxTemplate3.labelFontSize,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(
                                    data.settings.textColor.value),
                              ),
                            ),
                          ),
                          if (data.isIgst) ...[
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'IGST Rate',
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  font: TaxTemplate3.labelFont,
                                  fontSize: TaxTemplate3.labelFontSize,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromInt(
                                      data.settings.textColor.value),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'IGST Amount',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  font: TaxTemplate3.labelFont,
                                  fontSize: TaxTemplate3.labelFontSize,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromInt(
                                      data.settings.textColor.value),
                                ),
                              ),
                            ),
                          ] else ...[
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'CGST Rate',
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  font: TaxTemplate3.labelFont,
                                  fontSize: TaxTemplate3.labelFontSize,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromInt(
                                      data.settings.textColor.value),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'CGST Amount',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  font: TaxTemplate3.labelFont,
                                  fontSize: TaxTemplate3.labelFontSize,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromInt(
                                      data.settings.textColor.value),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'SGST Rate',
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  font: TaxTemplate3.labelFont,
                                  fontSize: TaxTemplate3.labelFontSize,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromInt(
                                      data.settings.textColor.value),
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                'SGST Amount',
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  font: TaxTemplate3.labelFont,
                                  fontSize: TaxTemplate3.labelFontSize,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColor.fromInt(
                                      data.settings.textColor.value),
                                ),
                              ),
                            ),
                          ],
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Cess Amount',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                font: TaxTemplate3.labelFont,
                                fontSize: TaxTemplate3.labelFontSize,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(
                                    data.settings.textColor.value),
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Total Tax Amount',
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                font: TaxTemplate3.labelFont,
                                fontSize: TaxTemplate3.labelFontSize,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromInt(
                                    data.settings.textColor.value),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ]),
              if (data.hsnItems.isNotEmpty)
                pw.Table(
                  // border: pw.TableBorder.all(),
                  defaultColumnWidth: const pw.FlexColumnWidth(),
                  children: List.generate(
                    data.hsnItems.length,
                    (index) {
                      {
                        InvoiceHsnModel hsnData = data.hsnItems[index];
                        double halfGstRate = (double.tryParse(
                                  hsnData.gstRate.replaceAll('%', ''),
                                ) ??
                                0) /
                            2;
                        double halfGstAmount = (double.tryParse(
                                  hsnData.gstAmount
                                      .replaceAll('₹', '')
                                      .replaceAll('Rs', ''),
                                ) ??
                                0) /
                            2;
                        return pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(5),
                              child: pw.Text(
                                hsnData.hsnCode,
                                textAlign: pw.TextAlign.left,
                                style: pw.TextStyle(
                                  font: hsnData.hsnCode == 'Total'
                                      ? TaxTemplate3.labelFont
                                      : TaxTemplate3.valuesFont,
                                  fontSize: hsnData.hsnCode == 'Total'
                                      ? TaxTemplate3.labelFontSize
                                      : TaxTemplate3.valuesFontSize,
                                  fontWeight: hsnData.hsnCode == 'Total'
                                      ? pw.FontWeight.bold
                                      : pw.FontWeight.normal,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                hsnData.taxableValue,
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  font: hsnData.hsnCode == 'Total'
                                      ? TaxTemplate3.labelFont
                                      : TaxTemplate3.valuesFont,
                                  fontSize: hsnData.hsnCode == 'Total'
                                      ? TaxTemplate3.labelFontSize
                                      : TaxTemplate3.valuesFontSize,
                                  fontWeight: hsnData.hsnCode == 'Total'
                                      ? pw.FontWeight.bold
                                      : pw.FontWeight.normal,
                                ),
                              ),
                            ),
                            if (data.isIgst) ...[
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  hsnData.gstRate.isEmpty
                                      ? ''
                                      : hsnData.gstRate,
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    font: hsnData.hsnCode == 'Total'
                                        ? TaxTemplate3.labelFont
                                        : TaxTemplate3.valuesFont,
                                    fontSize: hsnData.hsnCode == 'Total'
                                        ? TaxTemplate3.labelFontSize
                                        : TaxTemplate3.valuesFontSize,
                                    fontWeight: hsnData.hsnCode == 'Total'
                                        ? pw.FontWeight.bold
                                        : pw.FontWeight.normal,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  hsnData.gstAmount,
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    font: hsnData.hsnCode == 'Total'
                                        ? TaxTemplate3.labelFont
                                        : TaxTemplate3.valuesFont,
                                    fontSize: hsnData.hsnCode == 'Total'
                                        ? TaxTemplate3.labelFontSize
                                        : TaxTemplate3.valuesFontSize,
                                    fontWeight: hsnData.hsnCode == 'Total'
                                        ? pw.FontWeight.bold
                                        : pw.FontWeight.normal,
                                  ),
                                ),
                              ),
                            ] else ...[
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  hsnData.gstRate.isEmpty
                                      ? ''
                                      : '$halfGstRate %',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    font: hsnData.hsnCode == 'Total'
                                        ? TaxTemplate3.labelFont
                                        : TaxTemplate3.valuesFont,
                                    fontSize: hsnData.hsnCode == 'Total'
                                        ? TaxTemplate3.labelFontSize
                                        : TaxTemplate3.valuesFontSize,
                                    fontWeight: hsnData.hsnCode == 'Total'
                                        ? pw.FontWeight.bold
                                        : pw.FontWeight.normal,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '$halfGstAmount',
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    font: hsnData.hsnCode == 'Total'
                                        ? TaxTemplate3.labelFont
                                        : TaxTemplate3.valuesFont,
                                    fontSize: hsnData.hsnCode == 'Total'
                                        ? TaxTemplate3.labelFontSize
                                        : TaxTemplate3.valuesFontSize,
                                    fontWeight: hsnData.hsnCode == 'Total'
                                        ? pw.FontWeight.bold
                                        : pw.FontWeight.normal,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  hsnData.gstRate.isEmpty
                                      ? ''
                                      : '$halfGstRate %',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    font: hsnData.hsnCode == 'Total'
                                        ? TaxTemplate3.labelFont
                                        : TaxTemplate3.valuesFont,
                                    fontSize: hsnData.hsnCode == 'Total'
                                        ? TaxTemplate3.labelFontSize
                                        : TaxTemplate3.valuesFontSize,
                                    fontWeight: hsnData.hsnCode == 'Total'
                                        ? pw.FontWeight.bold
                                        : pw.FontWeight.normal,
                                  ),
                                ),
                              ),
                              pw.Padding(
                                padding: const pw.EdgeInsets.all(8),
                                child: pw.Text(
                                  '$halfGstAmount',
                                  textAlign: pw.TextAlign.right,
                                  style: pw.TextStyle(
                                    font: hsnData.hsnCode == 'Total'
                                        ? TaxTemplate3.labelFont
                                        : TaxTemplate3.valuesFont,
                                    fontSize: hsnData.hsnCode == 'Total'
                                        ? TaxTemplate3.labelFontSize
                                        : TaxTemplate3.valuesFontSize,
                                    fontWeight: hsnData.hsnCode == 'Total'
                                        ? pw.FontWeight.bold
                                        : pw.FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                hsnData.cessAmount,
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  font: hsnData.hsnCode == 'Total'
                                      ? TaxTemplate3.labelFont
                                      : TaxTemplate3.valuesFont,
                                  fontSize: hsnData.hsnCode == 'Total'
                                      ? TaxTemplate3.labelFontSize
                                      : TaxTemplate3.valuesFontSize,
                                  fontWeight: hsnData.hsnCode == 'Total'
                                      ? pw.FontWeight.bold
                                      : pw.FontWeight.normal,
                                ),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(8),
                              child: pw.Text(
                                hsnData.totalTaxAmount,
                                textAlign: pw.TextAlign.right,
                                style: pw.TextStyle(
                                  font: hsnData.hsnCode == 'Total'
                                      ? TaxTemplate3.labelFont
                                      : TaxTemplate3.valuesFont,
                                  fontSize: hsnData.hsnCode == 'Total'
                                      ? TaxTemplate3.labelFontSize
                                      : TaxTemplate3.valuesFontSize,
                                  fontWeight: hsnData.hsnCode == 'Total'
                                      ? pw.FontWeight.bold
                                      : pw.FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Mark: Subtotal Gst Block Builder Functions Extension
// =============================================
extension _SubtotalGstBlockBuilder on TaxTemplate3 {
  static Future<pw.Widget> _build(InvoiceModel data) async {
    List titles = [];
    List values = [];
    if (data.isIgst) {
      titles = [
        'Total Taxable Amount:',
        '${data.sgstLabel}:',
        '${data.cessLabel}:',
        'Discount:',
        "Total:",
        'Received:',
        'Due:',
      ];
      values = [
        data.totalTaxable,
        // data.cgstValue,
        data.sgstValue,
        data.cessValue,
        data.discount,
        data.totalAmount,
        data.receivedAmount,
        data.due,
      ];
    } else {
      titles = [
        'Total Taxable Amount:',
        '${data.cgstLabel}:',
        '${data.sgstLabel}:',
        '${data.cessLabel}:',
        'Discount:',
        "Total:",
        'Received:',
        'Due:',
      ];
      values = [
        data.totalTaxable,
        data.cgstValue,
        data.sgstValue,
        data.cessValue,
        data.discount,
        data.totalAmount,
        data.receivedAmount,
        data.due,
      ];
    }
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
                        i, _buildItem("", titles.elementAt(i) == "Total:")))
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
                      i, _buildItem(e, titles.elementAt(i) == "Total:")))
                  .values
                  .toList(),
            ),
            pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: values
                  .asMap()
                  .map((i, e) => MapEntry(
                      i, _buildItem(e, titles.elementAt(i) == "Total:")))
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
            height: 20,
            constraints: const pw.BoxConstraints(minWidth: 100),
            padding: const pw.EdgeInsets.symmetric(horizontal: 15),
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              text,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                font: TaxTemplate3.titleFont,
                color: PdfColors.black,
                fontSize: isTotalField
                    ? TaxTemplate3.extraBoldFontSize
                    : TaxTemplate3.valuesFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          );
  }
}

// Mark: Footer Builder Functions Extension
// =============================================
extension _FooterBuilder on TaxTemplate3 {
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

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        if (!settings.isPreparedBy &&
            !settings.isCheckedBy &&
            !settings.isAuthSign)
          pw.Row(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4),
                child: pw.Center(
                    child: pw.Text(
                  "This is a computer-generated document. No signature is required.",
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    font: TaxTemplate3.extraBoldFont,
                    color: PdfColors.black,
                    fontSize: TaxTemplate3.extraBoldFontSize,
                  ),
                )),
              )
            ],
          ),
        pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            mainAxisAlignment: settings.isPreparedBy || settings.isCheckedBy
                ? pw.MainAxisAlignment.spaceBetween
                : pw.MainAxisAlignment.end,
            children: [
              if (settings.isPreparedBy)
                pw.Padding(
                  padding: const pw.EdgeInsets.all(5),
                  child: pw.Center(
                    child: pw.Column(
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
                              font: TaxTemplate3.extraBoldFont,
                              color: PdfColors.black,
                              fontSize: TaxTemplate3.extraBoldFontSize,
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
                            font: TaxTemplate3.extraBoldFont,
                            color: PdfColors.black,
                            fontSize: TaxTemplate3.extraBoldFontSize,
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
                                font: TaxTemplate3.extraBoldFont,
                                color: PdfColors.black,
                                fontSize: TaxTemplate3.extraBoldFontSize,
                              ),
                            ),
                          ),
                        ]),
                  ),
                )
            ]),
        // pw.Row(
        //   children: [
        //     if (settings.fieldSettings.termAndCondition) ...[
        //       pw.Container(
        //         height: 30,
        //         child: pw.RichText(
        //           text: pw.TextSpan(
        //             text: "Terms & Conditions *",
        //             annotation: pw.AnnotationLink(termsAndConditionsLink ?? ""),
        //             style: pw.TextStyle(
        //                 font: TaxTemplate3.titleFont,
        //                 color: PdfColors.blue300,
        //                 fontSize: TaxTemplate3.valuesFontSize),
        //           ),
        //         ),
        //       ),
        //       pw.SizedBox(width: 10),
        //     ],
        //     if (settings.fieldSettings.notes)
        //       pw.Expanded(
        //         child: pw.Text(
        //           notes ?? "",
        //           textAlign: pw.TextAlign.left,
        //           style: pw.TextStyle(
        //               font: TaxTemplate3.titleFont,
        //               color: PdfColors.black,
        //               fontSize: TaxTemplate3.valuesFontSize),
        //         ),
        //       ),
        //   ],
        // ),
      ],
    );
  }
}
