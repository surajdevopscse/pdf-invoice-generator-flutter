import 'package:invoice_generator/invoice_generator.dart';

/// E-Receipt Model
final ReceiptModel eReceiptModel = ReceiptModel(
  modelSubType: 'PAC',
  title: "Receipt Voucher",
  id: "RPT-00050-2016",
  date: "February 16, 2016",
  logoBytes: null,
  buyer: ReceiptCompanyModel(
    name: "Hostbooks",
    address: ReceiptAddressModel(
      address: "Building - 356, Hostjjjjjkjkjugram",
      pincode: 123456,
    ),
    billingAddress: ReceiptAddressModel(
      address:
          "Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram",
      pincode: 123456,
    ),
    customerAddress: ReceiptAddressModel(
      address:
          "Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram",
      pincode: 123456,
    ),
    bankAccount: ReceiptBankAccountModel(
      bankName: "Bank of India",
      holderName: "James Harris",
      accountNumber: "123456789",
      ifsc: "BOI012345",
      type: ReceiptBankAccountType.current,
    ),
    gstNumber: "27AYTPK8285G1ZM",
  ),
  seller: ReceiptCompanyModel(
    name: "Antino",
    address: ReceiptAddressModel(
      address: "Tower- B3, Spaze IT Park, Sohna Road, Gurugram",
      pincode: 123456,
    ),
    bankAccount: ReceiptBankAccountModel(
      bankName: "Reserve Bank of India",
      holderName: "Joe Biden",
      accountNumber: "123456789",
      ifsc: "BOI012345",
      type: ReceiptBankAccountType.current,
    ),
  ),
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
    "Belt",
    "Coffee Vending Machine",
    "MacBook Pro",
    "Samsung LED",
    "AC Split",
  ]
      .asMap()
      .map((i, e) => MapEntry(
          i,
          ReceiptItemModel(
            index: ++i,
            id: "84748",
            name: e,
            date: "22, July 2022",
            gst: "GST @0.25%",
            amount: "100",
          )))
      .values
      .toList(),
  sgstLabel: "", // "SGST@9.0%",
  sgstValue: "", // "100",
  cgstLabel: "",
  cgstValue: "",
  isReversedCharge: null,
  unadjustedAmount: "",
  totalAmount: "100",
  totalAmountInWords: "One Hundred Only",
  transaction: ReceiptTransactionModel(
    transferType: "Cheque/DD",
    accountNumber: "0987654321",
    ifsc: "ABCDEF ",
    date: "22, July 2022",
    amount: "₹ 10,40,000.00",
    receivedAs: "On Account Recorded",
  ),
  termsAndConditionsLink: "https://www.google.co.in/",
  termsAndConditions: """
1. Period of warranty.
2. Person who is giving the warranty. You are providing the warranty or the original manufacturer is providing it.
3. Contact details. In case, a third party should be contacted, his details. For example, in electronics company provides the warranty and company’s service centre needs to be contacted and not the actual seller.
""",
  customerSupportEmail: "kevin.josh@hostbooks.com",
);
