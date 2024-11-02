class BarcodeModel {
  final String barCode;
  final int count;
  final int width;
  final int height;
  final int fontSize;
  final String fontFamily;
  final bool showNumber;
  final bool? taxInclusive;
  final String? itemName;
  final String? ingredients;
  final String? price;
  final String? netQyt;
  final String? mfd;
  final String phone;
  final String? mkd;
  final String? email;
  final String? address;
  final String? customerCare;
  final String? packedDate;
  final String? expDate;
  final String? packedBy;
  final List<NutritionalData> nutrition;

  BarcodeModel(
      {this.itemName,
      required this.barCode,
      this.count = 2,
      this.width = 54,
      this.height = 36,
      this.showNumber = false,
      this.taxInclusive,
      this.price,
      this.netQyt,
      this.mfd,
      this.ingredients,
      required this.phone,
      this.mkd,
      this.email,
      this.address,
      this.customerCare,
      this.fontSize = 8,
      this.fontFamily = 'Mulish',
      this.packedBy,
      this.expDate,
      this.packedDate,
      this.nutrition = const []});
}

class NutritionalData {
  final String name;
  final String value;

  const NutritionalData({required this.name, required this.value});
}
