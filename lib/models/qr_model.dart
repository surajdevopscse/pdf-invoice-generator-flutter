import 'package:invoice_generator/models/pdf_settings.dart';

class QRModel {
  final int? id;
  final String? title;
  final String? link;

  QRModel({
    this.id,
    this.title,
    this.link,
  });

  QRModel copy() {
    return QRModel(
      id: id,
      title: title,
      link: link,
    );
  }
}

class QRDataModel {
  final PdfSettings? settings;
  List<QRModel>? qrList;
  QRDataModel({this.settings, this.qrList});
}
