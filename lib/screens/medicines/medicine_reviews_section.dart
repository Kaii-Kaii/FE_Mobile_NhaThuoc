import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nha_thuoc/models/danh_gia_thuoc_model.dart';
import 'package:quan_ly_nha_thuoc/providers/customer_provider.dart';
import 'package:quan_ly_nha_thuoc/services/danh_gia_service.dart';
import 'package:quan_ly_nha_thuoc/theme/app_theme.dart';
import 'package:quan_ly_nha_thuoc/utils/snackbar_helper.dart';

class MedicineReviewsSection extends StatefulWidget {
  final String maThuoc;

  const MedicineReviewsSection({super.key, required this.maThuoc});

  @override
  State<MedicineReviewsSection> createState() => _MedicineReviewsSectionState();
}

class _MedicineReviewsSectionState extends State<MedicineReviewsSection> {
  final DanhGiaService _service = DanhGiaService();
  List<DanhGiaThuocModel> _reviews = [];
  bool _loading = true;
  DanhGiaThuocModel? _userReview;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      setState(() => _loading = true);
      final reviews = await _service.getReviewsByMedicine(widget.maThuoc);

      final customerProvider = context.read<CustomerProvider>();
      final currentMaKH = customerProvider.customer?.maKH;

      DanhGiaThuocModel? myReview;
      if (currentMaKH != null) {
        try {
          myReview = reviews.firstWhere((r) => r.maKH == currentMaKH);
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _reviews = reviews;
          _userReview = myReview;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final total = _reviews.fold(0, (sum, item) => sum + item.soSao);
    return total / _reviews.length;
  }

  void _showReviewDialog() {
    final customerProvider = context.read<CustomerProvider>();
    if (!customerProvider.hasCustomerInfo) {
      SnackBarHelper.show(
        context,
        'Vui lòng đăng nhập để đánh giá',
        type: SnackBarType.warning,
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => _ReviewDialog(
            initialRating: _userReview?.soSao ?? 5,
            initialContent: _userReview?.noiDung ?? '',
            onSubmit: (rating, content) async {
              try {
                await _service.upsertReview(
                  maKH: customerProvider.customer!.maKH,
                  maThuoc: widget.maThuoc,
                  soSao: rating,
                  noiDung: content,
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadReviews();
                  SnackBarHelper.show(
                    context,
                    'Đánh giá thành công',
                    type: SnackBarType.success,
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                // Check for specific error message about "completed order"
                String msg = e.toString();
                if (msg.contains(
                  'Khách chỉ được đánh giá sau khi đơn hàng đã hoàn thành',
                )) {
                  msg =
                      'Bạn cần mua sản phẩm này và đơn hàng đã hoàn thành để đánh giá.';
                }
                SnackBarHelper.show(context, msg, type: SnackBarType.error);
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        if (_reviews.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Chưa có đánh giá nào',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          )
        else
          ..._reviews.map((r) => _ReviewItem(review: r)),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá sản phẩm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                _StarRating(rating: _averageRating, size: 18),
                const SizedBox(width: 8),
                Text(
                  '(${_reviews.length} đánh giá)',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        TextButton.icon(
          onPressed: _showReviewDialog,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primaryColor,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          icon: Icon(_userReview != null ? Icons.edit : Icons.rate_review),
          label: Text(_userReview != null ? 'Sửa' : 'Viết đánh giá'),
        ),
      ],
    );
  }
}

class _ReviewItem extends StatelessWidget {
  final DanhGiaThuocModel review;

  const _ReviewItem({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Khách hàng', // API doesn't return customer name in review model, maybe update later if needed
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimaryColor,
                ),
              ),
              if (review.ngayDanhGia != null)
                Text(
                  DateFormat('dd/MM/yyyy').format(review.ngayDanhGia!),
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 6),
          _StarRating(rating: review.soSao.toDouble(), size: 14),
          const SizedBox(height: 8),
          Text(
            review.noiDung,
            style: const TextStyle(color: AppTheme.textSecondaryColor),
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Function(int)? onRatingChanged;

  const _StarRating({
    required this.rating,
    this.size = 24,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating;
        return GestureDetector(
          onTap:
              onRatingChanged != null
                  ? () => onRatingChanged!(index + 1)
                  : null,
          child: Icon(
            filled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: Colors.amber,
            size: size,
          ),
        );
      }),
    );
  }
}

class _ReviewDialog extends StatefulWidget {
  final int initialRating;
  final String initialContent;
  final Function(int, String) onSubmit;

  const _ReviewDialog({
    required this.initialRating,
    required this.initialContent,
    required this.onSubmit,
  });

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  late int _rating;
  late TextEditingController _controller;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _controller = TextEditingController(text: widget.initialContent);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Đánh giá sản phẩm'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StarRating(
            rating: _rating.toDouble(),
            size: 40,
            onRatingChanged: (r) => setState(() => _rating = r),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Nhập nội dung đánh giá...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed:
              _submitting
                  ? null
                  : () async {
                    if (_rating == 0) {
                      SnackBarHelper.show(
                        context,
                        'Vui lòng chọn số sao',
                        type: SnackBarType.warning,
                      );
                      return;
                    }
                    setState(() => _submitting = true);
                    await widget.onSubmit(_rating, _controller.text);
                    // Dialog closed by callback
                  },
          child:
              _submitting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Gửi đánh giá'),
        ),
      ],
    );
  }
}
