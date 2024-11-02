import 'package:flutter/material.dart';
import 'package:invoice_generator_example/examples/barcode_example.dart';
import 'package:invoice_generator_example/examples/fnb_invoice_example.dart';
import 'package:invoice_generator_example/examples/invoice_example.dart';
import 'package:invoice_generator_example/examples/journal_example.dart';
import 'package:invoice_generator_example/examples/qr_generator.dart';
import 'package:invoice_generator_example/examples/receipt_example.dart';
import 'package:invoice_generator_example/examples/tax_invoice_2.dart';
import 'package:invoice_generator_example/examples/tax_invoice_3.dart';
import 'package:invoice_generator_example/examples/tax_invoice_4.dart';
import 'package:invoice_generator_example/examples/tax_invoice_5.dart';
import 'package:invoice_generator_example/examples/tax_invoice_6.dart';
import 'package:invoice_generator_example/examples/tax_invoice_7.dart';

import 'examples/half_print.dart';
import 'examples/half_print_gst_invoice.dart';
import 'examples/tax_invoice.dart';
import 'examples/thermal_printer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      routes: {
        HomeWidget.routeName: (context) => const HomeWidget(),
        InvoiceExample.routeName: (context) => const InvoiceExample(),
        JournalExample.routeName: (context) => const JournalExample(),
        ReceiptExample.routeName: (context) => const ReceiptExample(),
        BarcodeExample.routeName: (context) => const BarcodeExample(),
        TaxInvoiceExample.routeName: (context) => const TaxInvoiceExample(),
        TaxInvoiceExample2.routeName: (context) => const TaxInvoiceExample2(),
        TaxInvoiceExample3.routeName: (context) => const TaxInvoiceExample3(),
        TaxInvoiceExample4.routeName: (context) => const TaxInvoiceExample4(),
        TaxInvoiceExample5.routeName: (context) => const TaxInvoiceExample5(),
        TaxInvoiceExample6.routeName: (context) => const TaxInvoiceExample6(),
        TaxInvoiceExample7.routeName: (context) => const TaxInvoiceExample7(),
        HalfPrint.routeName: (context) => const HalfPrint(),
        QRGenerator.routeName: (context) => const QRGenerator(),
        HalfPrintGstInvoice.routeName: (context) => const HalfPrintGstInvoice(),
        FnbInvoiceExample.routeName: (context) => const FnbInvoiceExample(),
        ThermalPrinter.routeName: (context) => const ThermalPrinter(),
      },
    );
  }
}

class HomeWidget extends StatelessWidget {
  static const String routeName = "/";
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Generator'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, InvoiceExample.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Invoice"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, JournalExample.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Journal"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, ReceiptExample.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Receipt"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, TaxInvoiceExample.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Tax"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, TaxInvoiceExample2.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Tax-2"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, TaxInvoiceExample3.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Tax-3"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, TaxInvoiceExample4.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Tax-4"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, TaxInvoiceExample5.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Tax-5"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, TaxInvoiceExample6.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Tax-6"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, TaxInvoiceExample7.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Tax-7"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, HalfPrint.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Half Print"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, BarcodeExample.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Barcode Invoice"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, FnbInvoiceExample.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Fbn Invoice"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, HalfPrintGstInvoice.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Half Print GST Invoice"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, QRGenerator.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("QR Generator"),
                ),
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, ThermalPrinter.routeName);
                },
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Thermal Invoice Printer"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
