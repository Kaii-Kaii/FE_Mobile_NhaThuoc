import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/binh_luan_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/binh_luan_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/snackbar_helper.dart';

class MedicineCommentsSection extends StatefulWidget {
  final String maThuoc;

  const MedicineCommentsSection({super.key, required this.maThuoc});

  @override
  State<MedicineCommentsSection> createState() =>
      _MedicineCommentsSectionState();
}

class _MedicineCommentsSectionState extends State<MedicineCommentsSection> {
  final BinhLuanService _service = BinhLuanService();
  final TextEditingController _controller = TextEditingController();

  List<BinhLuanModel> _comments = [];
  bool _loading = true;
  String? _replyingToId;
  String? _replyingToName;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final comments = await _service.getCommentsByMedicine(widget.maThuoc);
      if (mounted) {
        setState(() {
          _comments = comments;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitComment() async {
    final user = context.read<AuthProvider>().user;
    if (user == null || user.maKhachHang == null) {
      SnackBarHelper.show(
        context,
        'Vui lòng đăng nhập để bình luận',
        type: SnackBarType.error,
      );
      return;
    }

    final content = _controller.text.trim();
    if (content.isEmpty) return;

    // Close keyboard
    FocusScope.of(context).unfocus();

    try {
      final newComment = await _service.createComment(
        maThuoc: widget.maThuoc,
        maKH: user.maKhachHang,
        noiDung: content,
        traLoiChoBinhLuan: _replyingToId,
      );

      if (newComment != null) {
        _controller.clear();
        setState(() {
          _replyingToId = null;
          _replyingToName = null;
        });
        await _loadComments();
        if (mounted) {
          SnackBarHelper.show(
            context,
            'Đã gửi bình luận',
            type: SnackBarType.success,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.show(context, 'Lỗi: $e', type: SnackBarType.error);
      }
    }
  }

  Future<void> _deleteComment(String maBL) async {
    try {
      final success = await _service.deleteComment(maBL);
      if (success) {
        await _loadComments();
        if (mounted) {
          SnackBarHelper.show(
            context,
            'Đã xóa bình luận',
            type: SnackBarType.success,
          );
        }
      } else {
        if (mounted) {
          SnackBarHelper.show(
            context,
            'Không thể xóa bình luận',
            type: SnackBarType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackBarHelper.show(context, 'Lỗi: $e', type: SnackBarType.error);
      }
    }
  }

  void _startReply(BinhLuanModel comment) {
    // Find the thread root and the latest comment in that thread
    final root = _findRootFor(comment);
    if (root != null) {
      final latest = _findLatestInThread(root);
      setState(() {
        _replyingToId = latest.maBL;
        _replyingToName =
            latest.maNV != null ? 'Nhân viên tư vấn' : 'Khách hàng';
      });
    } else {
      // Fallback
      setState(() {
        _replyingToId = comment.maBL;
        _replyingToName =
            comment.maNV != null ? 'Nhân viên tư vấn' : 'Khách hàng';
      });
    }
  }

  void _cancelReply() {
    setState(() {
      _replyingToId = null;
      _replyingToName = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            'Hỏi đáp về sản phẩm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryColor,
            ),
          ),
        ),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Chưa có câu hỏi nào',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return _buildCommentItem(comment);
            },
          ),
        const SizedBox(height: 24),
        _buildInputArea(),
      ],
    );
  }

  // Helper to find the root of a comment
  BinhLuanModel? _findRootFor(BinhLuanModel target) {
    for (final root in _comments) {
      if (root.maBL == target.maBL) return root;
      if (_isDescendant(root, target.maBL)) return root;
    }
    return null;
  }

  bool _isDescendant(BinhLuanModel parent, String targetId) {
    for (final reply in parent.replies) {
      if (reply.maBL == targetId) return true;
      if (_isDescendant(reply, targetId)) return true;
    }
    return false;
  }

  // Helper to find the latest comment in a thread (root + replies)
  BinhLuanModel _findLatestInThread(BinhLuanModel root) {
    final all = [root, ..._getFlattenedReplies(root)];
    // Sort by time descending
    all.sort((a, b) {
      final t1 = a.thoiGian ?? DateTime(2000);
      final t2 = b.thoiGian ?? DateTime(2000);
      return t2.compareTo(t1); // Descending
    });
    return all.first;
  }

  List<BinhLuanModel> _getFlattenedReplies(BinhLuanModel comment) {
    final List<BinhLuanModel> flattened = [];

    void recurse(BinhLuanModel current) {
      if (current.replies.isNotEmpty) {
        for (final reply in current.replies) {
          flattened.add(reply);
          recurse(reply);
        }
      }
    }

    recurse(comment);
    return flattened;
  }

  Widget _buildCommentItem(BinhLuanModel comment) {
    final isStaff = comment.maNV != null;
    final user = context.read<AuthProvider>().user;
    final isMe =
        user != null &&
        ((comment.maKH != null && comment.maKH == user.maKhachHang));

    // Flatten all replies (replies of replies) into a single list
    final allReplies = _getFlattenedReplies(comment);
    // Sort replies by time ascending (oldest first) to show conversation flow
    allReplies.sort((a, b) {
      final t1 = a.thoiGian ?? DateTime(2000);
      final t2 = b.thoiGian ?? DateTime(2000);
      return t1.compareTo(t2);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Root comment
        _buildSingleCommentBubble(
          comment,
          isStaff,
          isMe,
          isRoot: true,
          showReply: allReplies.isEmpty,
        ),

        // Replies
        if (allReplies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 12),
            child: Column(
              children:
                  allReplies.asMap().entries.map((entry) {
                    final index = entry.key;
                    final reply = entry.value;
                    final isReplyStaff = reply.maNV != null;
                    final isReplyMe =
                        user != null &&
                        ((reply.maKH != null &&
                            reply.maKH == user.maKhachHang));
                    final isLast = index == allReplies.length - 1;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSingleCommentBubble(
                        reply,
                        isReplyStaff,
                        isReplyMe,
                        isRoot: false,
                        showReply: isLast,
                      ),
                    );
                  }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildSingleCommentBubble(
    BinhLuanModel comment,
    bool isStaff,
    bool isMe, {
    required bool isRoot,
    bool showReply = true,
  }) {
    final dateStr =
        comment.thoiGian != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(comment.thoiGian!.toLocal())
            : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor:
              isStaff
                  ? AppTheme.primaryColor
                  : AppTheme.secondaryColor.withOpacity(0.1),
          child: Icon(
            isStaff ? Icons.support_agent : Icons.person,
            size: 18,
            color: isStaff ? Colors.white : AppTheme.secondaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    isStaff
                        ? 'Nhân viên tư vấn'
                        : (isMe ? 'Bạn' : 'Khách hàng'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color:
                          isStaff
                              ? AppTheme.primaryColor
                              : AppTheme.textPrimaryColor,
                    ),
                  ),
                  if (isStaff) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.verified,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                  const Spacer(),
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                comment.noiDung,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimaryColor,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (showReply)
                    InkWell(
                      onTap: () => _startReply(comment),
                      child: Text(
                        'Trả lời',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  if (isMe) ...[
                    if (showReply) const SizedBox(width: 16),
                    InkWell(
                      onTap: () => _deleteComment(comment.maBL),
                      child: Text(
                        'Xóa',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    final user = context.watch<AuthProvider>().user;
    if (user == null || user.maKhachHang == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'Vui lòng đăng nhập để đặt câu hỏi',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_replyingToId != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              children: [
                Text(
                  'Đang trả lời $_replyingToName',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _cancelReply,
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText:
                      _replyingToId != null
                          ? 'Nhập câu trả lời...'
                          : 'Đặt câu hỏi về sản phẩm...',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _submitComment,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
