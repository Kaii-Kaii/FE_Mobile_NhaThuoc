import 'family_medicine.dart';

class CartItemDummy {
  final FamilyMedicine medicine;
  int quantity;

  CartItemDummy({required this.medicine, required this.quantity});

  num get totalPrice => medicine.price * quantity;
}
