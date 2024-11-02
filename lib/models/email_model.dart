class EmailModel {
  String greeting;
  String contactName;
  String body;
  String subject;
  String businessName;

  EmailInvoiceDetail invoiceDetail;
  EmailSettings emailSettings;

  EmailModel(
      {required this.subject,
      required this.greeting,
      required this.body,
      required this.contactName,
      required this.businessName,
      this.emailSettings = const EmailSettings(),
      required this.invoiceDetail});
}

class EmailInvoiceDetail {
  final String txnNumber;
  final String txnDate;
  final String? otherDate;
  final String txnAmount;
  final String balanceDue;
  final String received;
  final String taxableValue;
  final String igstAmount;
  final String cgstAmount;
  final String sgstAmount;
  final String status;
  final String totalTaxAmount;
  final String cessAmount;

  EmailInvoiceDetail(
      {required this.txnNumber,
      required this.txnDate,
      this.otherDate,
      required this.txnAmount,
      required this.igstAmount,
      required this.cgstAmount,
      required this.sgstAmount,
      required this.received,
      required this.balanceDue,
      required this.status,
      required this.cessAmount,
      required this.taxableValue,
      required this.totalTaxAmount});
}

class EmailSettings {
  final bool showTxnNumber;
  final bool showTxnDate;
  final bool showTxnAmount;
  final bool showReceivedAmount;
  final bool showBalanceDue;
  final bool viewInvoice;
  final bool showPayNow;
  final bool showHbPower;

  const EmailSettings(
      {this.showPayNow = false,
      this.viewInvoice = false,
      this.showBalanceDue = false,
      this.showReceivedAmount = false,
      this.showTxnAmount = false,
      this.showTxnNumber = false,
      this.showHbPower = false,
      this.showTxnDate = false});
}
