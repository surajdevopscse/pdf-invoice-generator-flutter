import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invoice_generator/invoice_generator.dart';
import 'package:invoice_generator/models/barcode_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class BarcodeExampleSecond extends StatefulWidget {
  static const String routeName = "/barcodeSecond/";
  const BarcodeExampleSecond({super.key});

  @override
  State<BarcodeExampleSecond> createState() => _BarcodeExampleState();
}

class _BarcodeExampleState extends State<BarcodeExampleSecond> {
  var isThermalViewType = false;

  final BarcodeModel barcodeModel = BarcodeModel(
    barCode: '590123412345',
    itemName: "Gold Necklace", // Name of the item
    itemCode: "C16-24", // Unique item code
    goldPurity: "22K", // Purity of gold, e.g., "22K"
    weight: "15g",
    price: '20,989',
    phone: '',
    showNumber: true,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode PDF'),
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
        future: PrintGenerator.instance.generateEBarcodeSecond(barcodeModel),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PdfPreview(
              build: (format) => snapshot.data!,
              pageFormats: const <String, PdfPageFormat>{
                'Roll80': PdfPageFormat.roll80,
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
