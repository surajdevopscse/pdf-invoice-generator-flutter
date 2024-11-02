import 'package:invoice_generator/enums/fnb_item_status.dart';
import 'package:invoice_generator/enums/fnb_order_status.dart';
import 'package:invoice_generator/models/fnb_invoice_model.dart';

final OrderDetail dummyFbnInvoiceModal = OrderDetail(
  orderId: "e3bf00a4-1c41-4f0b-9222-1d7be2843a12",
  orderNo: "M01/2023/000072",
  invoiceNo: "",
  tokenNo: 15,
  tableId: 14,
  tableName: 'AC10',
  floorNo: 3,
  tableOccupiedBy: 2,
  totalItems: 2,
  totalAmount: 60,
  paidAmount: '0',
  orderedAt: DateTime.now(),
  customerName: "Cash customer",
  customerEmail: '',
  customerPhone: '9999999999',
  customerAddress: '',
  mergedTables: [],
  status: OrderStatus.pending,
  printerWiseKots: [
    PrinterWiseKots(
      kitchens: {
        '2b336c1d-26d9-48d4-b068-ae04b4730adc': PrinterKitchen(
          items: {
            '2': PrinterKitchenItem(
              itemUuid: '2b336c1d-26d9-48d4-b068-ae04b4730adc',
              itemId: '151',
              name: 'Water Melon Juice',
              variantName: 'NA',
              qty: 2,
              note: '',
              status: ItemStatus.pending,
              price: 30,
            )
          },
          kitchenId: '2',
        )
      },
      printerId: '973b1528-a6d7-4c38-93f3-0b18c9f9807d-163127',
      printerName: 'Epson',
      printerPort: '9100',
      printerIpAddress: '172.17.6.200',
      isDefault: true,
    ),
  ],
  kotItems: [
    Kot(
      id: 151,
      itemName: 'Water Melon Juice',
      variantName: 'NA',
      uuid: "2b336c1d-26d9-48d4-b068-ae04b4730adc",
      itemThumbnail: '',
      itemQty: 2,
      itemImages: [],
      itemPrice: 30,
      note: '',
      status: ItemStatus.pending,
      printer: Printer(
        printerId: "973b1528-a6d7-4c38-93f3-0b18c9f9807d-163127",
        printerName: 'Epson',
        printerPort: '9100',
        printerIPAddress: "172.17.6.200",
      ),
      kitchenDetail: KitchenDetail(
        kitchenId: 2,
        kitchenName: 'BEVERAGES',
      ),
    )
  ],
  tableCapacity: 4,
  billedBy: BilledBy(name: 'name', phone: 9988998800),
  billedAt: DateTime.now(),
);
