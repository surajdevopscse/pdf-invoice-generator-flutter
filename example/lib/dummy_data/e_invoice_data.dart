import 'package:invoice_generator/invoice_generator.dart';
import 'package:invoice_generator/models/pdf_settings.dart';

/// E-Invoice Model
final InvoiceModel eInvoiceModel = InvoiceModel(
  dueDate: '10/12/26',
  currencyCode: 'INR',
  taxLabel: 'GSTIN',
  taxRateLabel: 'GST',
  currencySymbol: '₹',
  totalTaxAmountInWords: 'Two Hundred',
  hsnItemCount: '5',
  isIgst: false,
  is3mm: true,
  hsnItems: [
    InvoiceHsnModel(
        hsnCode: '10010',
        totalTaxAmount: '10000',
        gstRate: '18%',
        cessAmount: '3000',
        gstAmount: '7000',
        taxableValue: '1000000'),
    InvoiceHsnModel(
        hsnCode: '11010',
        totalTaxAmount: '10000',
        gstRate: '18%',
        cessAmount: '3000',
        gstAmount: '7000',
        taxableValue: '1000000'),
    InvoiceHsnModel(
        hsnCode: '10110',
        totalTaxAmount: '10000',
        gstRate: '18%',
        cessAmount: '3000',
        gstAmount: '7000',
        taxableValue: '1000000'),
    InvoiceHsnModel(
        hsnCode: '10011',
        totalTaxAmount: '10000',
        gstRate: '6%',
        cessAmount: '3000',
        gstAmount: '7000',
        taxableValue: '1000000'),
    InvoiceHsnModel(
        hsnCode: 'Total',
        totalTaxAmount: '4123456789',
        gstRate: '0',
        cessAmount: '12000',
        gstAmount: '38000',
        taxableValue: '4000000'),
  ],
  tenderDetails: [
    // TenderDetails(tender: 'Cash', refNo: '11', receivedAmount: '12'),
    // TenderDetails(tender: 'Bank', refNo: '12', receivedAmount: '13'),
  ],
  additionalFields: [
    AdditionalFieldsModel(value: 'not', name: 'shiv', totalValue: '240'),
    AdditionalFieldsModel(value: 'not', name: 'abc', totalValue: '240'),
    AdditionalFieldsModel(value: 'not', name: 'bcd', totalValue: '240'),
    AdditionalFieldsModel(value: 'not', name: 'dca', totalValue: '240'),
    AdditionalFieldsModel(value: 'not', name: 'shiv', totalValue: '240'),
  ],
  placeOfSupply: 'sdfs',
  companyName: "Hostbooks",
  companyAddress: 'Gurugram',
  cessLabel: "Cess",
  companyPINCode: '123456',
  cessValue: '33',
  footerTotalAmount: '666666774747477474747744774666',
  moduleType: 'INV',
  id: "INV-00050-2016-0987",
  date: "February 16, 2016j",
  time: "03:18 PM",
  // logoLink: "https://mma.prnewswire.com/media/1837086/Hostbook_Logo.jpg",
  // paymentQrLink: "https://www.werribeebusinessandtourism.org.au/wp-content/uploads/2020/12/QR-Code.png",
  logoBytes: null,
  paymentQrBytes: null,
  salesman: "Kevin",
  buyer: InvoiceCompanyModel(
    name: "Hostbooks",
    address: InvoiceAddressModel(
      name:
          "Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram",
      gstLabel: 'GST',
      gstOrPanValue: 'dd',
      address:
          "Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram",
      pincode: 123456,
    ),
    billingAddress: InvoiceAddressModel(
      name:
          "Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram",
      gstLabel: 'GST',
      gstOrPanValue: 'dd',
      address:
          "Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram",
      pincode: 123456,
    ),
    shippingAddress: InvoiceAddressModel(
      address:
          "Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, GurugramBuilding - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram  Building - 356, Hostbooks Building, Udyog Vihar, Phase 2, Gurugram",
      pincode: 123456,
    ),
  ),
  seller: InvoiceCompanyModel(
    name: "Batman",
    phone: '8295655655',
    email: 'abhi@gmail.com',
    gstLabel: null,
    gstorPanNumber: "27AYTPK8285G1ZM",
    address: InvoiceAddressModel(
      gstLabel: null,
      gstOrPanValue: 'dd',
      address: "Tower- B3, Spaze IT Park, Sohna Road, Gurugram",
      pincode: 123456,
    ),
  ),
  title: 'Tax Invoice',
  items: [
    "MacBook Pro",
    "Samsung LED",
    "AC Split",
    "Belt",
    // "Coffee Vending Machine",
    // "MacBook Pro",
    // "Samsung LED",
    // "AC Split",
    // "Belt",
    // "Coffee Vending Machine",
    // "MacBook Pro",
    // "Samsung LED",
    // "AC Split",
    // "Belt",
    // "Coffee Vending Machine",
    // "MacBook Pro",
    // "Samsung LED",
    // "AC Split",
    // "AC Split",
    // "Belt",
    // "Coffee Vending Machine",
    // "MacBook Pro",
    // "Samsung LED",
    // "AC Split",
    // "AC Split",
    // "Belt",
    // "Coffee Vending Machine",
    // "MacBook Pro",
    // "Samsung LED",
    // "AC Split",
    // "Belt",
    // "Coffee Vending Machine",
    // "MacBook Pro",
    // "Samsung LED",
    // "AC Split",
    // "AC Split",
    // "Belt",
    // "Coffee Vending Machine",
    // "MacBook Pro",
    // "Samsung LED",
    // "AC Split",
    // "AC Split",
    // "Belt",
    // "Belt",
  ]
      .asMap()
      .map((i, e) => MapEntry(
          i,
          InvoiceItemModel(
              gstRate: '5 %',
              hsnOrsacLabel: 'HSN',
              code: i.toString(),
              cess: '120',
              hsn: 'Batman',
              index: ++i,
              taxable: '8',
              afterTaxableFields: [
                AdditionalFieldsModel(value: 'NOT', name: 'a', totalValue: '10')
              ],
              description: 'This is description',
              name: e,
              delivery: '5',
              freight: '5',
              quantity: "1",
              unit: "P",
              price: "1",
              afterUnitPriceFields: [
                AdditionalFieldsModel(
                    value: 'NOT', name: 'b', totalValue: '20'),
                if (i % 2 == 0)
                  AdditionalFieldsModel(
                      value: 'NOT', name: 'a', totalValue: '10'),
                if (i % 2 != 0)
                  AdditionalFieldsModel(
                      value: 'NOT', name: 'ab', totalValue: '100'),
                if (i == 4)
                  AdditionalFieldsModel(
                      value: 'NOT', name: 'abc', totalValue: '1000')
              ],
              discount: "4",
              afterUnitAndDiscountFields: [
                AdditionalFieldsModel(value: 'NOT', name: 'a', totalValue: '10')
              ],
              afterDiscountPriceFields: [
                // AdditionalFieldsModel(value: 'NOT', name: 'a', totalValue: '10')
              ],
              gst: "8",
              amount: "1",
              mrp: "1",
              nonNumericFields: [
                AdditionalFieldsModel(value: 'NOT', name: 'a', totalValue: '10')
              ])))
      .values
      .toList(),
  totalQuantities: "99798989810",
  totalTaxable: '33780809090',
  txnLevelDiscount: '99',
  totalGst: "1844444444444",
  totalDiscount: "40",
  totalAmount: "\u062F\u002E\u0625 189455.00",
  totalItemAmount: "\u062F\u002E\u0625 189455.98",
  totalAmountInWords: "One Hundred",
  subTotalAmount: "100",
  discount: "40",
  sgstLabel: "SGST@9.0%",
  sgstValue: "\u062F\u002E\u062540,000.00",
  cgstLabel: "CGST@9.0%",
  cgstValue: "\u062F\u002E\u062540,000.00",
  receivedAmount: "\u062F\u002E\u06250.00",
  due: "10,56,000.00",
  balanceAmount: '99',
  roundOff: "0.98",
  savedAmount: "10,56,000.00",
  notes: "This is notes",
  termsAndConditionsLink: 'https://www.google.co.in/',
  termsAndConditions: """
1. Period of warranty.
2. Person who is giving the warranty. You are providing the warranty or the original manufacturer is providing it.
3. Contact details. In case, a third party should be contacted, his details. For example, in electronics company provides the warranty and company’s service centre needs to be contacted and not the actual seller.
""",
  customerSupportEmail: "kevin.josh@hostbooks.com",
  settings: PdfSettings(
      isCheckedBy: true,
      isAuthSign: true,
      isPreparedBy: true,
      fieldSettings: const FieldSettings(
          shippingAddress: true,
          bankDetails: false,
          hsn: true,
          pan: true,
          gstin: true)),
  companyGST: '',
  companyPan: '',
  printCopyTitle: 'Original for Recipient',
);
