import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:invoice_generator/invoice_generator.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../dummy_data/e_invoice_data.dart';

class HalfPrintGstInvoice extends StatefulWidget {
  static const String routeName = "/halfPrintGstInvoice";
  const HalfPrintGstInvoice({super.key});
  @override
  State<HalfPrintGstInvoice> createState() => _HalfPrintGstInvoiceState();
}

class _HalfPrintGstInvoiceState extends State<HalfPrintGstInvoice> {
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
        title: const Text('Half Print GST Invoice'),
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
      body: FutureBuilder<Uint8List>(
        future: PrintGenerator.instance.halfPrint(eInvoiceModel),
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
    );
  }
}
