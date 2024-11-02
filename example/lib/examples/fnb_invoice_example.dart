import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:invoice_generator/invoice_generator.dart';
import 'package:invoice_generator_example/dummy_data/fbn_invoice_data.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class FnbInvoiceExample extends StatefulWidget {
  static const String routeName = "/fbn_invoice/";
  const FnbInvoiceExample({super.key});

  @override
  State<FnbInvoiceExample> createState() => _FnbInvoiceExampleState();
}

class _FnbInvoiceExampleState extends State<FnbInvoiceExample> {
  var isThermalViewType = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fnb Invoice example'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isThermalViewType = !isThermalViewType;
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      //
      /// Actual Implementation
      /// =======================
      // body: Center(
      //   child: OutlinedButton(
      //     onPressed: () async {
      //       /// Generate E-Invoice
      //       final pdf =
      //           await InvoiceGenerator.instance.generateEInvoice(model);
      //       print(pdf.length);
      //     },
      //     child: const Text(
      //       'Generate E-Invoice',
      //       style: TextStyle(fontSize: 18),
      //     ),
      //   ),
      // ),
      /// =======================
      /// Actual Implementation
      //

      //
      /// For Development Purpose Only
      /// =============================
      // body: FutureBuilder<Uint8List>(
      //   future: PrintGenerator.instance.fnbInvoiceTemplate(
      //     orderNo: 'order no',
      //     itemList: [],
      //     customerPhone: '9999999999',
      //     waiterName: 'waiterName',
      //     customerName: 'Customer',
      //     companyName: 'Hahahaha',
      //     address: 'Addresss of the company',
      //     branchFssaiNo: 'branchFssaiNo of the company',
      //     companyGstin: 'Gstin of the company',
      //     companyPhoneNo: 'phone no. of the company', billNo: '', mergeTableList: '', paymentStatus: '',
      //   ),
      //   builder: (context, snapshot) {
      //     if (snapshot.hasData) {
      //       return PdfPreview(
      //         build: (format) => snapshot.data!,
      //         pageFormats: const <String, PdfPageFormat>{
      //           'A4': PdfPageFormat.a4,
      //         },
      //       );
      //     } else {
      //       return const SizedBox.shrink();
      //     }
      //   },
      // ),

      /// =============================
      /// For Development Purpose Only
      //
    );
  }
}
