import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invoice_generator/invoice_generator.dart';
import 'package:printing/printing.dart';

import '../dummy_data/e_invoice_data.dart';

class ThermalPrinter extends StatefulWidget {
  static const String routeName = "/thermal/";
  const ThermalPrinter({super.key});

  @override
  State<ThermalPrinter> createState() => _ThermalPrinterState();
}

class _ThermalPrinterState extends State<ThermalPrinter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thermal Printer'),
      ),
      body: FutureBuilder<Uint8List>(
        future: PrintGenerator.instance.generateThermalInvoice(eInvoiceModel),
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
    );
  }
}
