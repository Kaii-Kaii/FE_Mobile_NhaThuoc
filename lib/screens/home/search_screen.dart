import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  final List<String> _hotItems = const [
    'Omega 3',
    'Vitamin E',
    'Kem chống nắng',
    'Men vi sinh',
    'Bao cao su',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tìm theo tên thuốc,...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (v) {
                    // implement search action
                  },
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Tìm kiếm', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 4),
          const Text('Tìm kiếm hàng đầu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._hotItems.map((s) => Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.timer, size: 16, color: Colors.black54),
                    ),
                    title: Text(s),
                    onTap: () {
                      // handle item tap
                    },
                  ),
                  const Divider(height: 1),
                ],
              )),
        ],
      ),
    );
  }
}
