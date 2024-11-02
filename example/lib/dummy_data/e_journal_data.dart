import 'package:invoice_generator/invoice_generator.dart';

/// E-Invoice Model
final JournalModel eJournalModel = JournalModel(
  id: "INV-00050-2016",
  date: "February 16, 2016",
  autoReversingDate: "DD/MM/YYYY",
  logoBytes: null,
  items: [
    "Belt",
    "Coffee Vending Machine",
    "MacBook Pro",
    "Samsung LED",
    "AC Split",
    "Belt",
    "Coffee Vending Machine",
    "MacBook Pro",
    "Samsung LED",
    "AC Split",
    "Coffee Vending Machine",
    "MacBook Pro",
    "Samsung LED",
    "AC Split",
    "MacBook Pro",
    "Coffee Vending Machine",
    "MacBook Pro",
    "Samsung LED",
    "AC Split",
    "MacBook Pro",
    "MacBook Pro",
    "Coffee Vending Machine",
    "MacBook Pro",
    "Samsung LED",
    "AC Split",
    "MacBook Pro",
    "Coffee Vending Machine",
    "MacBook Pro",
    "Samsung LED",
    "AC Split",
    "MacBook Pro",
    "MacBook Pro",
    // "Coffee Vending Machine",
    // "MacBook Pro",
    // "Samsung LED",
    // "AC Split",
    // "MacBook Pro",
  ]
      .asMap()
      .map((i, e) => MapEntry(
          i,
          JournalItemModel(
            index: ++i,
            id: "84748",
            account: e,
            date: DateTime.now(),
            dateString: "February 16, 2016",
            creditAmount: "100.0",
            debitAmount: "1000.0",
            description: null,
          )))
      .values
      .toList(),
  totalCreditAmount: "10000.0",
  totalDebitAmount: "10000.0",
  gstin: "07AADCK7940H1ZE",
  narration: "BOIUjasjdklfjkldsafjadsfkljjfkdsakjldsfjadsfaklj34567",
  termsAndConditionsLink: "https://www.google.co.in/",
  termsAndConditions: """
1. Period of warranty.
2. Person who is giving the warranty. You are providing the warranty or the original manufacturer is providing it.
3. Contact details. In case, a third party should be contacted, his details. For example, in electronics company provides the warranty and company’s service centre needs to be contacted and not the actual seller.
""",
  customerSupportEmail: "kevin.josh@hostbooks.com",
);
