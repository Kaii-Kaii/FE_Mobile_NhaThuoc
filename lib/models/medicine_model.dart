import 'dart:convert';

class Medicine {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final int stockQuantity;
  final String manufacturer;
  final String dosageForm; // Viên, siro, ống, etc.
  final String dosageInstructions;
  final bool requiresPrescription;

  Medicine({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    required this.stockQuantity,
    required this.manufacturer,
    required this.dosageForm,
    required this.dosageInstructions,
    required this.requiresPrescription,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'],
      category: json['category'],
      stockQuantity: json['stockQuantity'],
      manufacturer: json['manufacturer'],
      dosageForm: json['dosageForm'],
      dosageInstructions: json['dosageInstructions'],
      requiresPrescription: json['requiresPrescription'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image': image,
      'category': category,
      'stockQuantity': stockQuantity,
      'manufacturer': manufacturer,
      'dosageForm': dosageForm,
      'dosageInstructions': dosageInstructions,
      'requiresPrescription': requiresPrescription,
    };
  }
}

class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({
    required this.medicine,
    this.quantity = 1,
  });

  double get totalPrice => medicine.price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'medicine': medicine.toJson(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      medicine: Medicine.fromJson(json['medicine']),
      quantity: json['quantity'],
    );
  }
}