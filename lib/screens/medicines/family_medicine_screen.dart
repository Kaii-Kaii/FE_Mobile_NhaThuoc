import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/medicine_provider.dart';
import '../../models/medicine_by_type.dart';
import '../medicines/medicine_detail_screen.dart';

class FamilyMedicineScreen extends StatefulWidget {
  const FamilyMedicineScreen({super.key});

  @override
  State<FamilyMedicineScreen> createState() => _FamilyMedicineScreenState();
}

class _FamilyMedicineScreenState extends State<FamilyMedicineScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MedicineProvider>().fetchByLoai("LT001");
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicineProvider>();
    final list = provider.medicinesByLoai;
    final loading = provider.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF03A297),
        title: const Text(
          'Thuốc theo loại',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : list.isEmpty
              ? const Center(
                child: Text(
                  "Không có thuốc nào",
                  style: TextStyle(fontSize: 16),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final m = list[index];
                  return _buildCard(m);
                },
              ),
    );
  }

  Widget _buildCard(MedicineByType m) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MedicineDetailScreen(maThuoc: m.maThuoc),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            // ---- IMAGE ----
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                m.urlAnh ?? "",
                width: 100,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    width: 100,
                    height: 120,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),

            // ---- INFO ----
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.tenThuoc,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      m.tenNCC ?? "",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),

                    const SizedBox(height: 10),

                    // Giá hiển thị theo option đầu tiên
                    Text(
                      m.giaThuocs.isNotEmpty
                          ? "${m.giaThuocs.first.donGia} đ"
                          : "Không có giá",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
