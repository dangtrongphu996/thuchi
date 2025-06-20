import 'package:flutter/material.dart';
import '../models/danh_muc.dart';
import 'all_transactions_screen.dart';

class ExpenseCategoriesScreen extends StatelessWidget {
  final List<DanhMuc> danhMucs;
  final Map<int, double> tongChiTheoDanhMuc;

  const ExpenseCategoriesScreen({
    Key? key,
    required this.danhMucs,
    required this.tongChiTheoDanhMuc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sắp xếp danhMucs theo tổng chi giảm dần
    final sortedDanhMucs = List<DanhMuc>.from(danhMucs)..sort(
      (a, b) => (tongChiTheoDanhMuc[b.id] ?? 0).compareTo(
        tongChiTheoDanhMuc[a.id] ?? 0,
      ),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh mục chi phí'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sortedDanhMucs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final dm = sortedDanhMucs[index];
          final tong = tongChiTheoDanhMuc[dm.id] ?? 0;
          return Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Text(
                dm.icon ?? '',
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(
                dm.ten,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Tổng chi: ${tong.toStringAsFixed(0)} đ'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => AllTransactionsScreen(
                          loai: 2,
                          title: 'Giao dịch chi: ${dm.ten}',
                          danhMucId: dm.id,
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
