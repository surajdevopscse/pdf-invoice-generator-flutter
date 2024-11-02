import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invoice_generator/invoice_generator.dart';
import 'package:invoice_generator/models/barcode_model.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class BarcodeExample extends StatefulWidget {
  static const String routeName = "/barcode/";
  const BarcodeExample({super.key});

  @override
  State<BarcodeExample> createState() => _BarcodeExampleState();
}

class _BarcodeExampleState extends State<BarcodeExample> {
  var isThermalViewType = false;

  final BarcodeModel barcodeModel = BarcodeModel(
      barCode: '590123412345',
      phone: '8617878497',
      itemName: 'Laptop',
      fontSize: 6,
      address: 'East Kidwai Nagar, Delhi 110023',
      count: 1,
      netQyt: '1 BOX',
      price: 'Rs 300',
      packedDate: '10/06/2023',
      expDate: '12/12/2022',
      packedBy: 'Employee Name',
      taxInclusive: true,
      showNumber: false,
      ingredients: 'Rajma, dal, chawal, oil',
      nutrition: [
        const NutritionalData(name: 'Energy', value: '500 Kcal'),
        const NutritionalData(name: 'Carbohydrate', value: '100 G'),
        const NutritionalData(name: 'Fat', value: '45 G'),
        const NutritionalData(name: 'Sugar', value: '34 G'),
        const NutritionalData(name: 'Protein', value: '12 G'),
      ]);

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
        future: PrintGenerator.instance.generateEBarcode(barcodeModel),
        builder: (context, snapshot) {
          print(snapshot);
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
