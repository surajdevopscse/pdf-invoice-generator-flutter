import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invoice_generator/invoice_generator.dart';
import 'package:invoice_generator_example/dummy_data/e_receipt_data.dart';
import 'package:printing/printing.dart';

import '../dummy_data/e_invoice_data.dart';

class ReceiptExample extends StatefulWidget {
  static const String routeName = "/receipt/";
  const ReceiptExample({super.key});

  @override
  State<ReceiptExample> createState() => _ReceiptExampleState();
}

class _ReceiptExampleState extends State<ReceiptExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt PDF'),
      ),

      //
      /// For Development Purpose Only
      /// =============================
      body: FutureBuilder<Uint8List>(
        future: PrintGenerator.instance.generateEReceipt(eReceiptModel),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PdfPreview(
              build: (format) => snapshot.data!,
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
