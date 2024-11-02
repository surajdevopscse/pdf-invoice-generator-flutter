import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:invoice_generator/invoice_generator.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../dummy_data/e_invoice_data.dart';
import '../dummy_data/qr_data.dart';

class QRGenerator extends StatefulWidget {
  static const String routeName = "/qr_generator";
  const QRGenerator({super.key});
  @override
  State<QRGenerator> createState() => _QRGeneratorState();
}

class _QRGeneratorState extends State<QRGenerator> {
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
        title: const Text('QR Generator'),
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
        future: PrintGenerator.instance.qrGenerator(qrDataModel),
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
