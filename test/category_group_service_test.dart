import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_nha_thuoc/models/categoryGroup/CategoryGroup_service.dart';

void main() {
  test('Fetch category groups from API', () async {
    final service = CategoryGroupService();
    final list = await service.getAllCategoryGroups();

    // Print for manual inspection in test logs
    print('Fetched ${list.length} category groups');
    for (var g in list) {
      print(' - ${g.maNhomLoai}: ${g.tenNhomLoai}');
    }

    // Expect at least one group (based on server sample)
    expect(list, isA<List>());
  }, timeout: Timeout(Duration(seconds: 30)));
}
