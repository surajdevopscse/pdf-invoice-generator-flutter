import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';
import 'package:spelling_number/spelling_number.dart';

import '../../invoice_generator.dart';
import '../../models/pdf_settings.dart';

class TaxTemplate {
  final InvoiceModel data;
  TaxTemplate({
    required this.data,
  });

  ///FONTS
  late Font titleFont;
  late Font subTitleFont;
  late Font invoiceNumberFont;
  late Font invoiceDateFont;
  late Font valuesFont;
  late Font labelFont;
  late Font extraBoldFont;

  ///FONT SIZE
  double titleFontSize = 16;
  double valuesFontSize = 10;
  double labelFontSize = 12;
  double extraBoldFontSize = 14;

  ///FONT COLOR
  PdfColor valueColor = PdfColors.grey100;
  PdfColor labelColor = PdfColors.grey500;

  setFontFamily(String fontFamily) async {
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

  String convertCurrencyToWords(String number) {
    final n = num.parse(number);
    return SpellingNumber(
            lang: "en",
            wholesUnit: "",
            fractionUnit: "",
            digitsLengthW2F: 3,
            decimalSeperator: "point")
        .convert(n);
  }

  setFontSize(double size) {
    valuesFontSize = size;
    labelFontSize = size + 1;
    titleFontSize = 14;
    extraBoldFontSize = size + 2;
  }

  final tableHeaders = [
    '#',
    'Items',
    'NSH/SAC',
    'Quantity',
    'Unit',
    'Price/Unit',
    'Discount',
    'GST',
    'Amount',
  ];

  final tableData = [
    [
      '1',
      'Article1',
      '3309876',
      '02',
      'Unit',
      '1000.00',
      '00.00',
      '18%',
      '2360.00'
    ],
  ];

  Future<Document> generateETax() async {
    final tax = Document();
    PdfSettings setting = data.settings;
    await setFontFamily(data.settings.fontFamily);

    setFontSize(data.settings.fontSize.toDouble());

    // final logoTax = await _HeaderBuilder_build(data);
    // String image = await rootBundle.loadString('assets/icons/hb_power.svg');

    tax.addPage(
      MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        build: (context) {
          return [
            header(),
          ]; // Center
        },
      ),
    );

    return tax;
  }

  Widget header() {
    return Column(children: [
      Container(
        width: double.maxFinite,
        decoration: BoxDecoration(border: Border.all(width: 1)),
        child: Column(children: [
          Center(
            child: Text(
              'Tax Invoice',
              style: TextStyle(
                  fontWeight: FontWeight.normal, color: PdfColors.blue),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
          ),
          Table(
            border: TableBorder.all(),
            children: [
              TableRow(children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data.companyName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              data.sgstValue,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            Text(
                              data.companyAddress ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ]),
                    ]),
                Table(border: TableBorder.all(), children: [
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Invoice#',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    data.id,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ]),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Invoice Date',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Text(
                                    data.date,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ]),
                          ]),
                    ),
                  ]),
                  TableRow(children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(children: [
                              Text(
                                'Place of Supply',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                data.placeOfSupply ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]),
                          ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(children: [
                              Text(
                                'Due Date',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              Text(
                                data.date,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]),
                          ]),
                    ),
                  ]),
                ]),
              ]),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Billing Address :',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          Text(
                            data.companyAddress ?? '',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shipping Address :',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        Text(
                          data.companyAddress ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 1, right: 1),
            child: Table.fromTextArray(
              headers: tableHeaders,
              data: tableData,
              border: null,
              headerStyle: TextStyle(fontWeight: FontWeight.bold),
              cellDecoration: (index, data, rowNum) => const BoxDecoration(
                border: Border(
                  left: BorderSide(),
                  right: BorderSide(),
                ),
              ),
              headerCellDecoration: BoxDecoration(
                border: Border.all(),
                color: PdfColors.grey300,
              ),
              cellHeight: 30.0,
              cellAlignments: {
                0: Alignment.centerLeft,
                1: Alignment.centerRight,
                2: Alignment.centerRight,
                3: Alignment.centerRight,
                4: Alignment.centerRight,
              },
            ),
          ),
          Divider(height: 1),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Amount Chargebles( in words:)INR  ${data.totalAmountInWords}',
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: PdfColors.black),
              ),
            ),
          ),
          Divider(height: 1),
          Container(
            alignment: Alignment.centerRight,
            child: Row(
              children: [
                Spacer(flex: 1),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Total Taxable Amount : ",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: data.totalTaxable,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ]),
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Total Tax : ",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: data.totalTaxable,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ]),
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Cess : ",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: data.cessValue,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ]),
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Discount : ",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: data.discount,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ]),
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Amount Payable : ",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: data.subTotalAmount,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ]),
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Received : ",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: data.receivedAmount,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ]),
                      ),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: "Due : ",
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          TextSpan(
                            text: data.due,
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ]),
                      ),
                      SizedBox(height: 2 * PdfPageFormat.mm),
                      Container(height: 1, color: PdfColors.grey400),
                      SizedBox(height: 0.5 * PdfPageFormat.mm),
                      Container(height: 1, color: PdfColors.grey400),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Table(
            border: TableBorder.all(),
            children: [
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'NSH/SAC',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Taxable Amount',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'IGST Rate',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'IGST Amount',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Cess Amount',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Tax Amount',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    data.sgstValue,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    data.cessValue,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    data.due,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    data.totalDiscount,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    data.cgstValue,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    data.totalGst,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    data.totalTaxable,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    data.sgstLabel,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    data.due,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    data.totalTaxable,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    data.id,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ]),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Tax Amount ( in words:)INR  ${convertCurrencyToWords(data.totalTaxable)} Only',
                style: TextStyle(
                    fontWeight: FontWeight.normal, color: PdfColors.black),
              ),
            ),
          ),
          Table(
            border: TableBorder.all(),
            children: [
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: "Bank Details : ",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColors.black),
                            ),
                          ]),
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: "Bank Details : ",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColors.black),
                            ),
                            TextSpan(
                              text: 'Yes Bank',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColors.black),
                            ),
                          ]),
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: "Account N/O : ",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColors.black),
                            ),
                            TextSpan(
                              text: 'YES5437Q',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColors.black),
                            ),
                          ]),
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: "IFSC : ",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColors.black),
                            ),
                            TextSpan(
                              text: 'YES5437Q',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColors.black),
                            ),
                          ]),
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: "Branch : ",
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColors.black),
                            ),
                            TextSpan(
                              text: 'GurGoan',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.normal,
                                  color: PdfColors.black),
                            ),
                          ]),
                        ),
                      ]),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('For Event Formula'),
                ),
              ]),
              TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Note : '),
                        Text('Thank you  for the Business')
                      ]),
                ),
                Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Terms and Conditions : '),
                          Text('1. Thank you for the Business'),
                        ])),
              ]),
            ],
          ),
        ]),
      ),
    ]);
  }
}
// extension _HeaderBuilder on TaxTemplate {
//   static get children => null;
//
//   static Future<Widget> _build(InvoiceModel data) async {
//     final logo =
//     (data.logoBytes != null) ? MemoryImage(data.logoBytes!) : null;
//     final qr = (data.settings.fieldSettings.qrCode)
//         ? (data.paymentQrBytes != null)
//         ? Container(
//         child: SvgImage(
//           svg: Barcode.qrCode().toSvg(data.paymentQrBytes ?? ""),
//         ))
//         : null
//         : null;
//
//     String date = data.date;
//     final moduleType = data.moduleType;
//     String invoiceNumber = data.id;
//
//     String label = '';
//     switch (moduleType) {
//       case 'INV':
//         label = 'Invoice';
//         break;
//       case 'SQU':
//         label = 'Quotation';
//         break;
//       case 'SOR':
//         label = 'Order';
//         break;
//       case 'SDC':
//         label = 'Challan';
//         break;
//       case 'SCN':
//         label = 'CN';
//         break;
//       case 'SDN':
//         label = 'DN';
//         break;
//       case 'POR':
//         label = 'PO';
//         break;
//     }
//
//     String docNumber = '$label No: $invoiceNumber';
//     String docDate = '$label Date: $date';
//
//     int numberLength = docNumber.length;
//     int dateLength = docDate.length;
//
//     int diff = numberLength - dateLength;
//
//     if (diff != 0) {
//       if (diff.isNegative) {
//         invoiceNumber = invoiceNumber.padRight(diff);
//       } else {
//         date = date.padRight(diff);
//       }
//     }
//
//
//     if (logo != null) {
//       Alignment logoAlignment =
//       (data.settings.logoAlign.toLowerCase() == 'left')
//           ? Alignment.centerLeft
//           : (data.settings.logoAlign.toLowerCase() == 'right')
//           ? Alignment.centerRight
//           : Alignment.center;
//
//       Widget logoWidget = Expanded(
//           child: Align(
//               alignment: logoAlignment,
//               child: Image(
//                 logo,
//                 fit: BoxFit.fill,
//                 height: data.settings.logoSize,
//                 width: data.settings.logoSize,
//               )));
//
//       if (data.settings.logoAlign.toLowerCase() == 'left') {
//         children.insert(0, logoWidget);
//       } else if (data.settings.logoAlign.toLowerCase() == 'right') {
//         children.add(logoWidget);
//       } else {
//         children.insert(1, logoWidget);
//       }
//     }
//
//     return Column(children: [
//       Row(children: [
//         Spacer(),
//         Expanded(
//           child: Text(
//             data.title,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               font: EInvoiceTemplate.titleFont,
//               fontSize: EInvoiceTemplate.titleFontSize,
//             ),
//           ),
//         ),
//         Expanded(
//           child: Text(
//             data.printCopyTitle,
//             textAlign: TextAlign.right,
//             style: TextStyle(
//               font: EInvoiceTemplate.labelFont,
//               fontSize: EInvoiceTemplate.labelFontSize,
//             ),
//           ),
//         ),
//       ]),
//       SizedBox(height: 32),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: children,
//       )
//     ]);
//   }
// }
