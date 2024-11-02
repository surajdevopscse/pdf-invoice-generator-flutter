import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:invoice_generator/invoice_generator.dart';
import 'package:printing/printing.dart';

import '../dummy_data/e_journal_data.dart';

class JournalExample extends StatefulWidget {
  static const String routeName = "/journal/";
  const JournalExample({super.key});

  @override
  State<JournalExample> createState() => _JournalExampleState();
}

class _JournalExampleState extends State<JournalExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal PDF'),
      ),
      body: FutureBuilder<Uint8List>(
        future: PrintGenerator.instance.generateEJournal(eJournalModel),
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
