import 'package:flutter/material.dart';

import '../../../core/di/app_dependencies.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/hifi_button.dart';
import '../../../core/widgets/sub_page_scaffold.dart';
import '../data/reviews_repository.dart';

/// Reviews of one course plus a form for the learner's own rating.
/// States: loading, error (retry), empty, list. Only enrolled learners can
/// save a review; the server decides and the screen explains a refusal.
class CourseReviewsScreen extends StatefulWidget {
  const CourseReviewsScreen({required this.courseId, super.key});

  final String courseId;

  @override
  State<CourseReviewsScreen> createState() => _CourseReviewsScreenState();
}

class _CourseReviewsScreenState extends State<CourseReviewsScreen> {
  final _comment = TextEditingController();
  ReviewsPage? _page;
  bool _loading = true;
  bool _failed = false;
  bool _saving = false;
  int _rating = 0;

  ReviewsRepository get _repo => AppDependencies.reviewsRepository;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final page = await _repo.list(widget.courseId);
      if (!mounted) return;
      final mine = page.mine;
      setState(() {
        _page = page;
        _loading = false;
        if (mine != null && _rating == 0) {
          _rating = mine.rating;
          _comment.text = mine.comment;
        }
      });
    } on Object catch (e) {
      debugPrint('reviews failed to load: $e');
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (_rating == 0 || _saving) return;
    setState(() => _saving = true);
    final result = await _repo.submit(
      widget.courseId,
      rating: _rating,
      comment: _comment.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case ReviewSubmitResult.saved:
        messenger.showSnackBar(
          const SnackBar(content: Text('บันทึกรีวิวแล้ว')),
        );
        await _load();
      case ReviewSubmitResult.notEnrolled:
        messenger.showSnackBar(
          const SnackBar(content: Text('รีวิวได้เฉพาะผู้ที่ลงทะเบียนคอร์สนี้')),
        );
      case ReviewSubmitResult.invalid:
        messenger.showSnackBar(
          const SnackBar(content: Text('ข้อมูลรีวิวไม่ถูกต้อง')),
        );
      case ReviewSubmitResult.failed:
        messenger.showSnackBar(
          const SnackBar(content: Text('บันทึกรีวิวไม่สำเร็จ ลองอีกครั้ง')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _page;
    return SubPageScaffold(
      title: 'รีวิวคอร์ส',
      fallbackRoute: '/course/${widget.courseId}',
      children: [
        if (_loading && page == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_failed && page == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Text(
                  'โหลดรีวิวไม่สำเร็จ',
                  style: AppTypography.base(
                    13,
                    color: AppColors.textSecondary,
                  ),
                ),
                TextButton(onPressed: _load, child: const Text('ลองใหม่')),
              ],
            ),
          )
        else if (page != null) ...[
          _Summary(page: page),
          const SectionLabel('ให้คะแนนคอร์สนี้'),
          _Form(
            rating: _rating,
            controller: _comment,
            saving: _saving,
            hasReview: page.mine != null,
            onRating: (v) => setState(() => _rating = v),
            onSave: _save,
          ),
          const SectionLabel('รีวิวจากผู้เรียน'),
          if (page.items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'ยังไม่มีรีวิว เป็นคนแรกที่รีวิวคอร์สนี้',
                style: AppTypography.base(13, color: AppColors.textSecondary),
              ),
            ),
          for (final r in page.items) ...[
            _ReviewTile(review: r),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.value, this.size = 16, this.onChanged});

  final int value;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          InkResponse(
            key: onChanged == null ? null : ValueKey('star-$i'),
            onTap: onChanged == null ? null : () => onChanged!(i),
            child: Icon(
              i <= value ? Icons.star : Icons.star_border,
              size: size,
              color: const Color(0xFFF59E0B),
            ),
          ),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.page});

  final ReviewsPage page;

  @override
  Widget build(BuildContext context) {
    final label = page.count == 0
        ? 'ยังไม่มีคะแนน'
        : '${page.average.toStringAsFixed(1)} / 5 (${page.count} รีวิว)';
    return AppCard(
      child: Row(
        children: [
          _Stars(value: page.average.round(), size: 20),
          const SizedBox(width: 12),
          Text(label, style: AppTypography.base(13, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form({
    required this.rating,
    required this.controller,
    required this.saving,
    required this.hasReview,
    required this.onRating,
    required this.onSave,
  });

  final int rating;
  final TextEditingController controller;
  final bool saving;
  final bool hasReview;
  final ValueChanged<int> onRating;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Stars(value: rating, size: 30, onChanged: onRating),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 3,
            maxLength: 2000,
            decoration: const InputDecoration(
              hintText: 'เล่าประสบการณ์การเรียน (ไม่บังคับ)',
            ),
          ),
          const SizedBox(height: 8),
          AppButton.primary(
            label: hasReview ? 'อัปเดตรีวิว' : 'ส่งรีวิว',
            loading: saving,
            onPressed: rating == 0 || saving ? null : onSave,
            expand: true,
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final CourseReview review;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.mine ? '${review.author} (คุณ)' : review.author,
                  style: AppTypography.base(13, weight: FontWeight.w600),
                ),
              ),
              Text(
                review.date,
                style: AppTypography.base(11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _Stars(value: review.rating, size: 14),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review.comment, style: AppTypography.base(12.5)),
          ],
        ],
      ),
    );
  }
}
