import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FnbInvoiceTemplate {
  ///
  static late DateTime currentDateTime;

  ///FONT SIZE
  static double titleFontSize = 14;
  static double valuesFontSize = 7;
  static double labelFontSize = 10;
  static double extraBoldFontSize = 10;

  /// Font
  // static late pw.Font fallbackFont;
  // static late pw.Font mediumFont;
  // static late pw.Font bold;
  // static late pw.Font boldItalic;
  // static late pw.Font semiBold;
  // static late pw.Font semiBoldItalic;

  /// Set Fonts
  // static setFonts() async {
  //   fallbackFont = await PdfGoogleFonts.sansitaRegular();
  //   mediumFont = await PdfGoogleFonts.sansitaSwashedMedium();
  //   bold = await PdfGoogleFonts.sansitaBold();
  //   boldItalic = await PdfGoogleFonts.sansitaBoldItalic();
  //   semiBold = await PdfGoogleFonts.sansitaSwashedSemiBold();
  //   // semiBoldItalic = await PdfGoogleFonts.sansitasem();
  // }

  static Future<pw.Document> getFbnInvoice(
      {required List itemList,
      required List gstBreakupList,
      required String orderNo,
      required String billNo,
      required String waiterName,
      required String customerName,
      required String customerPhone,
      required String customerAddress,
      required String customerGst,
      required String roundOffValue,
      required String companyName,
      required String address,
      required String companyPhoneNo,
      required String companyGstin,
      required String branchFssaiNo,
      required String mergeTableList,
      required String paymentStatus,
      required String qrcode,
      required String noOfPerson,
      required String totalOrderDiscount,
      required String showGstBreakup,
      required String dateTime,
      }) async {
    final pdf = pw.Document();
    currentDateTime = DateTime.now();

    final header = await _CompanyDetailBuilder._build(
        orderNo: orderNo,
        billNo: billNo,
        companyName: companyName,
        address: address,
        branchFssaiNo: branchFssaiNo,
        companyGstin: companyGstin,
        companyPhoneNo: companyPhoneNo,
        mergeTableList: mergeTableList);
    final billSection = await _BillSection._build(
      billNo: billNo,
      dateTime: dateTime,
    );
    final customerSection = await _CustomerSection._build(
      customerName: customerName,
      waiterName: waiterName,
      customerAddress: customerAddress,
      customerPhone: customerPhone,
      customerGst: customerGst,
      mergeTableList: mergeTableList,
      noOfPerson: noOfPerson,
    );
    final gstBrekupSection = await _GstBreakupSection._build(
      gstBreakupList: gstBreakupList,
    );
    final paymentModeSection = await _PaymentModeSection._build(
      waiterName: waiterName,
      totalAmount: itemList
          .fold(0.0, (pv, e) => pv + e['totalAmount'])
          .round()
          .toStringAsFixed(2),
    );
    final foodSection = await _FoodSection._build(
      kotItems: itemList,
      roundOffValue: roundOffValue,
      totalOrderDiscount: totalOrderDiscount
    );
    final bottomSection = await _BottomSection._build(
      qrcode: qrcode,
      paymentStatus: paymentStatus,
    );
    // final totalSavings = await _TotalSavingsBuilder._build(data.savedAmount);
    // final footer = await _FooterBuilder._build(data);
    // final semiboldfont = await PdfGoogleFonts.mulishSemiBold();
    // final boldfont = await PdfGoogleFonts.mulishBold();
    final color = PdfColor.fromHex("#0F0F0F");
    // final qr = (data.paymentQrBytes != null)
    //     ? pw.SvgImage(
    //         svg: pw.Barcode.qrCode().toSvg(data.paymentQrBytes ?? ""),
    //       )
    //     : null;

    // final defaultFont = await PdfGoogleFonts.mulishRegular();

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(
            // fontFallback: [fallbackFont],
            color: color,
            // font: defaultFont,
          ),
        ),
        pageFormat: const PdfPageFormat(192, double.infinity)
            .applyMargin(left: 0, top: 0, right: 0, bottom: 0),
        build: (pw.Context context) {
          return pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            // crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              header,
              _divider(),
              billSection,
              _divider(),
              customerSection,
              _divider(),
              foodSection,
              if(showGstBreakup=='1')
              gstBrekupSection,
              paymentModeSection,
              bottomSection,
              _verticalGap12(),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  static pw.SizedBox _verticalGap4() {
    return pw.SizedBox(height: 4);
  }

  static pw.SizedBox _verticalGap12() {
    return pw.SizedBox(height: 12);
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

extension _CompanyDetailBuilder on FnbInvoiceTemplate {
  static Future<pw.Widget> _build({
    required String orderNo,
    required String billNo,
    required String companyName,
    required String address,
    required String companyPhoneNo,
    required String companyGstin,
    required String branchFssaiNo,
    required String mergeTableList,
  }) async {
    return pw.Column(
      children: [
        // pw.Text(
        //   'Tax Invoice',
        //   textAlign: pw.TextAlign.center,
        //   style: pw.TextStyle(
        //     fontSize: FnbInvoiceTemplate.extraBoldFontSize,
        //     fontWeight: pw.FontWeight.bold,
        //   ),
        // ),
        pw.Text(
          companyName,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: FnbInvoiceTemplate.extraBoldFontSize,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          address,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: FnbInvoiceTemplate.valuesFontSize,
          ),
        ),
        pw.Text(
          'Contact : $companyPhoneNo',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: FnbInvoiceTemplate.valuesFontSize,
          ),
        ),
        pw.Text(
          'GSTIN : $companyGstin',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: FnbInvoiceTemplate.valuesFontSize,
          ),
        ),
        pw.Text(
          'FSSAI No : $branchFssaiNo',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: FnbInvoiceTemplate.valuesFontSize,
          ),
        ),
        // pw.Text(
        //   'DINE IN',
        //   textAlign: pw.TextAlign.center,
        //   style: pw.TextStyle(
        //     fontSize: FnbInvoiceTemplate.extraBoldFontSize,
        //     fontWeight: pw.FontWeight.bold,
        //   ),
        // ),

        // pw.Text(
        //   '${dateFormat.format(FnbInvoiceTemplate.currentDateTime)} ${timeFormat.format(FnbInvoiceTemplate.currentDateTime)}',
        //   textAlign: pw.TextAlign.center,
        //   style: pw.TextStyle(
        //     fontSize: FnbInvoiceTemplate.valuesFontSize,
        //   ),
        // ),
        // FnbInvoiceTemplate._verticalGap12(),
        // pw.Text(
        //   'Table No : $mergeTableList',
        //   textAlign: pw.TextAlign.center,
        //   style: pw.TextStyle(
        //     fontSize: FnbInvoiceTemplate.extraBoldFontSize,
        //     fontWeight: pw.FontWeight.bold,
        //   ),
        // ),
        // if(billNo.isNotEmpty)
        // pw.Text(
        //   'Bill No : $billNo',
        //   textAlign: pw.TextAlign.center,
        //   style: pw.TextStyle(
        //     fontSize: FnbInvoiceTemplate.extraBoldFontSize,
        //     fontWeight: pw.FontWeight.bold,
        //   ),
        // ),
        // pw.Text(
        //   'Order No : $orderNo',
        //   textAlign: pw.TextAlign.center,
        //   style: pw.TextStyle(
        //     fontSize: FnbInvoiceTemplate.extraBoldFontSize,
        //     fontWeight: pw.FontWeight.bold,
        //   ),
        // ),
        // FnbInvoiceTemplate._verticalGap12(),
      ],
    );
  }
}

extension _BillSection on FnbInvoiceTemplate {
  static Future<pw.Widget> _build({
    required String billNo,
    required String dateTime,
  }) async {
    DateFormat dateFormat = DateFormat('dd/MM/yyyy');
    DateFormat timeFormat = DateFormat('KK:mm a');
    return pw.Column(
      children: [
        FnbInvoiceTemplate._verticalGap4(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, right: 12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Bill : $billNo',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.valuesFontSize,
                ),
              ),
              pw.Text(
                dateTime,
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.valuesFontSize,
                ),
              ),
              // pw.Text(
              //   '${dateFormat.format(FnbInvoiceTemplate.currentDateTime)} ${timeFormat.format(FnbInvoiceTemplate.currentDateTime)}',
              //   textAlign: pw.TextAlign.left,
              //   style: pw.TextStyle(
              //     fontSize: FnbInvoiceTemplate.valuesFontSize,
              //   ),
              // ),
            ],
          ),
        ),
        // pw.Padding(
        //   padding: const pw.EdgeInsets.only(left: 12, right: 12),
        //   child: pw.Row(
        //     children: [
        //       pw.Text(
        //         'Date : ${dateFormat.format(FnbInvoiceTemplate.currentDateTime)} ${timeFormat.format(FnbInvoiceTemplate.currentDateTime)}',
        //         textAlign: pw.TextAlign.left,
        //         style: pw.TextStyle(
        //           fontSize: FnbInvoiceTemplate.valuesFontSize,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        FnbInvoiceTemplate._verticalGap4(),
      ],
    );
  }
}

extension _CustomerSection on FnbInvoiceTemplate {
  static Future<pw.Widget> _build({
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required String customerGst,
    required String waiterName,
    required String mergeTableList,
    required String noOfPerson,
  }) async {
    return pw.Column(
      children: [
        FnbInvoiceTemplate._verticalGap4(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
                'Customer : $customerName',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.valuesFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                'Contact : $customerPhone',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.valuesFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            // pw.Expanded(
            //   child: pw.Text(
            //     'Gstin : $customerGst',
            //     textAlign: pw.TextAlign.right,
            //     style: pw.TextStyle(
            //       fontSize: FnbInvoiceTemplate.valuesFontSize,
            //     ),
            //   ),
            // ),
          ],
        ),
        // pw.Padding(
        //   padding: const pw.EdgeInsets.only(left: 12, right: 12),
        //   child: pw.Row(
        //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        //     children: [
        //       pw.Expanded(
        //         child: pw.Text(
        //           'Contact : $customerPhone',
        //           textAlign: pw.TextAlign.left,
        //           style: pw.TextStyle(
        //             fontSize: FnbInvoiceTemplate.valuesFontSize,
        //             fontWeight: pw.FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //       pw.Expanded(
        //         child: pw.Text(
        //           'Waiter : $waiterName',
        //           textAlign: pw.TextAlign.right,
        //           style: pw.TextStyle(
        //             fontSize: FnbInvoiceTemplate.valuesFontSize,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // pw.Padding(
        //   padding: const pw.EdgeInsets.only(left: 12, right: 12),
        //   child: pw.Row(
        //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        //     children: [
        //       pw.Expanded(
        //         child: pw.Text(
        //           'Address : $customerAddress',
        //           textAlign: pw.TextAlign.left,
        //           style: pw.TextStyle(
        //             fontSize: FnbInvoiceTemplate.valuesFontSize,
        //             fontWeight: pw.FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Text(
               'Table : $mergeTableList',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.valuesFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
               'Person : $noOfPerson',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.valuesFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        FnbInvoiceTemplate._verticalGap4(),
      ],
    );
  }
}

extension _GstBreakupSection on FnbInvoiceTemplate {
  static Future<pw.Widget> _build({
    required List gstBreakupList,
  }) async {
    pw.Row commonRowWidget({
      bool isheader = false,
      String? taxRate,
      String? taxableAmount,
      String? sgst,
      String? cgst,
      String? total,
    }) {
      return pw.Row(children: [
        if (isheader) ...[
          pw.Expanded(
            child: pw.Text(
              'Gst',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'Taxable',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'SGST',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'CGST',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              'Total',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
        if (!isheader) ...[
          pw.Expanded(
            child: pw.Text(
              taxRate ?? '',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              taxableAmount ?? '',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              sgst ?? '',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              cgst ?? '',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              total ?? '',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ]
      ]);
    }

    return pw.Column(
      children: [
        FnbInvoiceTemplate._verticalGap4(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, right: 12),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'GST Breakup',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: FnbInvoiceTemplate.valuesFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
        FnbInvoiceTemplate._verticalGap4(),
        FnbInvoiceTemplate._divider(),
        commonRowWidget(isheader: true),
        FnbInvoiceTemplate._verticalGap4(),
        FnbInvoiceTemplate._divider(),
        FnbInvoiceTemplate._verticalGap4(),
        pw.ListView.builder(
          itemBuilder: (context, index) {
            // Map element = gstBreakupList[index];
            String gstRate = gstBreakupList[index]['tax_rate'].toStringAsFixed(2);
            String taxable = gstBreakupList[index]['taxable_amout'].toStringAsFixed(2);
            String sgst = gstBreakupList[index]['sgst'].toStringAsFixed(2);
            String cgst = gstBreakupList[index]['cgst'].toStringAsFixed(2);
            String total = gstBreakupList[index]['total'].toStringAsFixed(2);
            return commonRowWidget(
              taxRate: '$gstRate %',
              taxableAmount: taxable,
              sgst: sgst,
              cgst: cgst,
              total: total,
            );
          },
          itemCount: gstBreakupList.length,
        ),
        FnbInvoiceTemplate._verticalGap4(),
        FnbInvoiceTemplate._divider(),
        FnbInvoiceTemplate._verticalGap4(),
      ],
    );
  }
}

extension _PaymentModeSection on FnbInvoiceTemplate {
  static Future<pw.Widget> _build({
    required String totalAmount,
    required String waiterName,
  }) async {
    return pw.Column(
      children: [
        FnbInvoiceTemplate._verticalGap4(),
        // pw.Padding(
        //   padding: const pw.EdgeInsets.only(left: 12, right: 12),
        //   child: pw.Row(
        //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        //     children: [
        //       pw.Expanded(
        //         child: pw.Text(
        //           'Mode',
        //           textAlign: pw.TextAlign.left,
        //           style: pw.TextStyle(
        //             fontSize: FnbInvoiceTemplate.valuesFontSize,
        //             fontWeight: pw.FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //       pw.Expanded(
        //         child: pw.Text(
        //           'Amount',
        //           textAlign: pw.TextAlign.right,
        //           style: pw.TextStyle(
        //             fontSize: FnbInvoiceTemplate.valuesFontSize,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // FnbInvoiceTemplate._verticalGap4(),
        // FnbInvoiceTemplate._divider(),
        // pw.Padding(
        //   padding: const pw.EdgeInsets.only(left: 12, right: 12),
        //   child: pw.Row(
        //     mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        //     children: [
        //       pw.Expanded(
        //         child: pw.Text(
        //           'Cash',
        //           textAlign: pw.TextAlign.left,
        //           style: pw.TextStyle(
        //             fontSize: FnbInvoiceTemplate.valuesFontSize,
        //             fontWeight: pw.FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //       pw.Expanded(
        //         child: pw.Text(
        //           totalAmount,
        //           textAlign: pw.TextAlign.right,
        //           style: pw.TextStyle(
        //             fontSize: FnbInvoiceTemplate.valuesFontSize,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // FnbInvoiceTemplate._verticalGap12(),
        // FnbInvoiceTemplate._divider(),
        // FnbInvoiceTemplate._divider(),
        // FnbInvoiceTemplate._verticalGap4(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, right: 12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Cashier :',
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: FnbInvoiceTemplate.valuesFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  'E & OE',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: FnbInvoiceTemplate.valuesFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12, right: 12),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  waiterName,
                  textAlign: pw.TextAlign.left,
                  style: pw.TextStyle(
                    fontSize: FnbInvoiceTemplate.valuesFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.Expanded(
                child: pw.Text(
                  '',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: FnbInvoiceTemplate.valuesFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        FnbInvoiceTemplate._verticalGap4(),
      ],
    );
  }
}

extension _FoodSection on FnbInvoiceTemplate {
  static Future<pw.Widget> _build({
    required List kotItems,
    required String roundOffValue,
    required String totalOrderDiscount,
    // required String totalTaxabbleAmount,
  }) async {
    pw.Row commonRowWidget({
      required int index,
      String? itemName,
      String? variantName,
      String? itemQty,
      String? itemRate,
      String? itemTotal,
      bool isheader = false,
    }) {
      return pw.Row(
        children: [
          if (isheader) ...[
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                'Particular',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                'Qty',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                'Rate',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                'Amt',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.extraBoldFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
          if (!isheader) ...[
            pw.Text(
              '$index. ',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(
                fontSize: FnbInvoiceTemplate.valuesFontSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Expanded(
              flex: 3,
              child: pw.Text(
                '$itemName ($variantName)',
                // itemName ?? '',
                textAlign: pw.TextAlign.left,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.valuesFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                itemQty ?? '',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.valuesFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                itemRate ?? '',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.valuesFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                itemTotal ?? '',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontSize: FnbInvoiceTemplate.valuesFontSize,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ]
        ],
      );
    }

    return pw.Column(
      children: [
        commonRowWidget(isheader: true, index: 00),
        FnbInvoiceTemplate._verticalGap4(),
        FnbInvoiceTemplate._divider(),
        pw.Column(
          children: [
            pw.ListView.builder(
              itemBuilder: (context, index) {
                Map element = kotItems[index];
                double itemRate = element['itemPrice'];
                double itemTotal = element['taxableAmount'];
                return commonRowWidget(
                  index: (index + 1),
                  itemName: element['itemName'],
                  variantName: element['variantName'],
                  itemQty: element['itemQty'].toString(),
                  itemRate: itemRate.toStringAsFixed(2),
                  itemTotal: itemTotal.toStringAsFixed(2),
                );
              },
              itemCount: kotItems.length,
            ),
            FnbInvoiceTemplate._verticalGap4(),
            FnbInvoiceTemplate._divider(),
            FnbInvoiceTemplate._verticalGap4(),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, right: 8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Subtotal',
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontSize: FnbInvoiceTemplate.valuesFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      kotItems.fold(0.0, (pv, e) => pv + e['itemQty']).toString(),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: FnbInvoiceTemplate.valuesFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      (){
                        String total='';
                        double tm=0;
                        for (var i = 0; i < kotItems.length; i++) {
                          final e=kotItems[i];
                          tm=tm+ e['taxableAmount'];
                        } 
                        total = tm.toStringAsFixed(2);
                        return total;
                      }(),
                      // kotItems.fold(0.0, (pv, e) => pv + e['taxableAmount']).toStringAsFixed(2),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: FnbInvoiceTemplate.valuesFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, right: 8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'CGST : (${(kotItems[0]['cgstRate']).toStringAsFixed(2)} %)',
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontSize: FnbInvoiceTemplate.valuesFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      kotItems
                          .fold(0.0, (pv, e) => pv + e['cgstAmount'])
                          .toStringAsFixed(2),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: FnbInvoiceTemplate.valuesFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, right: 8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'SGST : (${(kotItems[0]['sgstRate']).toStringAsFixed(2)} %)',
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontSize: FnbInvoiceTemplate.valuesFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      kotItems
                          .fold(0.0, (pv, e) => pv + e['sgstAmount'])
                          .toStringAsFixed(2),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: FnbInvoiceTemplate.valuesFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, right: 8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Round Off',
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(
                        fontSize: FnbInvoiceTemplate.valuesFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      roundOffValue,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: FnbInvoiceTemplate.valuesFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if(totalOrderDiscount.isNotEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, right: 8),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Bill Discount : $totalOrderDiscount',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: FnbInvoiceTemplate.valuesFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FnbInvoiceTemplate._verticalGap4(),
            FnbInvoiceTemplate._divider(),
            FnbInvoiceTemplate._verticalGap4(),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, right: 8),
              child: pw.Row(
                children: [
                  // pw.Expanded(
                  //   child: pw.Text(
                  //     'TOTAL',
                  //     textAlign: pw.TextAlign.left,
                  //     style: pw.TextStyle(
                  //       fontSize: FnbInvoiceTemplate.valuesFontSize,
                  //       fontWeight: pw.FontWeight.bold,
                  //     ),
                  //   ),
                  // ),
                  pw.Expanded(
                    child: pw.Text(
                      'TOTAL : ${kotItems.fold(0.0, (pv, e) => pv + e['totalAmount']).round().toStringAsFixed(2)}',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: FnbInvoiceTemplate.valuesFontSize,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FnbInvoiceTemplate._verticalGap4(),
            FnbInvoiceTemplate._divider(),
            FnbInvoiceTemplate._divider(),
            FnbInvoiceTemplate._verticalGap4(),
          ],
        ),
      ],
    );
  }
}

extension _BottomSection on FnbInvoiceTemplate {
  static Future<pw.Widget> _build({
    required String paymentStatus,
    required String qrcode,
  }) async {
    return pw.Column(
      children: [
        FnbInvoiceTemplate._verticalGap4(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 8, right: 8),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Payment Status : $paymentStatus',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: FnbInvoiceTemplate.valuesFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // FnbInvoiceTemplate._verticalGap12(),
        FnbInvoiceTemplate._divider(),
        FnbInvoiceTemplate._verticalGap4(),
        // pw.Padding(
        //   padding: const pw.EdgeInsets.only(left: 8, right: 8),
        //   child: pw.Row(
        //     children: [
        //       pw.Expanded(
        //         child: pw.Text(
        //           '*** Online Order @ Outlet Price ***',
        //           textAlign: pw.TextAlign.center,
        //           style: pw.TextStyle(
        //             fontSize: FnbInvoiceTemplate.valuesFontSize,
        //             fontWeight: pw.FontWeight.bold,
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        if(qrcode.isNotEmpty)
        pw.Center(
          child: pw.Container(
              child: pw.SvgImage(
            svg: pw.Barcode.qrCode().toSvg(qrcode),
          )),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 8, right: 8),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'Thank you for your visit',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: FnbInvoiceTemplate.valuesFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 8, right: 8),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  '*** Have a Sweet day, Tahnk You ***',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: FnbInvoiceTemplate.valuesFontSize,
                  ),
                ),
              ),
            ],
          ),
        ),
        FnbInvoiceTemplate._verticalGap4(),
        FnbInvoiceTemplate._divider(),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 8, right: 8),
          child: pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                  'F&B 360 Powered by HostBooks',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: FnbInvoiceTemplate.valuesFontSize,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // pw.Padding(
        //   padding: const pw.EdgeInsets.only(right: 8),
        //   child: pw.Row(
        //     children: [
        //       pw.Expanded(
        //         child: pw.Text(
        //           'Scan & Pay through any UPI app',
        //           textAlign: pw.TextAlign.center,
        //           style: pw.TextStyle(
        //             fontSize: FnbInvoiceTemplate.valuesFontSize,
        //
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}
