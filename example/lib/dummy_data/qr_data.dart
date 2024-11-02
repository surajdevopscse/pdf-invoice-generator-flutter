import 'package:invoice_generator/models/pdf_settings.dart';
import 'package:invoice_generator/models/qr_model.dart';
final QRDataModel qrDataModel = QRDataModel(
  settings: PdfSettings(
    isCheckedBy: true,
    isAuthSign: true,
    isPreparedBy: true,
    fieldSettings: const FieldSettings(
        shippingAddress: true, bankDetails: false, hsn: true)),
  qrList: [
    QRModel(id: 1, title: 'HostBooks', link: 'https://neo.hostbooks.in'),
    QRModel(id: 2, title: 'HostBooks', link: 'https://neo.hostbooks.in'),
    QRModel(id: 3, title: 'HostBooks', link: 'https://neo.hostbooks.in'),
    QRModel(id: 4, title: 'HostBooks', link: 'https://neo.hostbooks.in'),
    QRModel(id: 5, title: 'HostBooks', link: 'https://neo.hostbooks.in'),
    QRModel(id: 6, title: 'HostBooks', link: 'https://neo.hostbooks.in'),
    QRModel(id: 7, title: 'HostBooks', link: 'https://neo.hostbooks.in'),
  ]
);
