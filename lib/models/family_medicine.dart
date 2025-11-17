class FamilyMedicine {
  final int id;
  final String name;
  final String description;
  final num price;
  final String image;
  final String category;
  final int stockQuantity;
  final String manufacturer;
  final String dosageForm;
  final String dosageInstructions;
  final bool requiresPrescription;

  FamilyMedicine({
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
}
