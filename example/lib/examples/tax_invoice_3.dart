import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:invoice_generator/invoice_generator.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../dummy_data/e_invoice_data.dart';

class TaxInvoiceExample3 extends StatefulWidget {
  static const String routeName = "/tax/3";
  const TaxInvoiceExample3({super.key});

  @override
  State<TaxInvoiceExample3> createState() => _TaxInvoiceExample3State();
}

class _TaxInvoiceExample3State extends State<TaxInvoiceExample3> {
  var isThermalViewType = false;

  @override
  void initState() {
    // eInvoiceModel.settings.fieldSettings.bankDetails = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Invoice 3 PDF'),
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
      body: FutureBuilder<Uint8List>(
        future: PrintGenerator.instance.generateETax3(eInvoiceModel),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PdfPreview(
              build: (format) => snapshot.data!,
              pageFormats: const <String, PdfPageFormat>{
                'A4': PdfPageFormat.a4,
              },
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),

      /// =============================
      /// For Development Purpose Only
      //
    );
  }
}
