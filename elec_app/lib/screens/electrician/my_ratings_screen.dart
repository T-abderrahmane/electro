import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/localization.dart';

class MyRatingsScreen extends StatelessWidget {
  const MyRatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizer.of(context);

    // Mock ratings data - in real app, fetch from backend
    final ratings = _getMockRatings();
    final averageRating =
        ratings.isEmpty
            ? 0.0
            : ratings.map((r) => r.rating).reduce((a, b) => a + b) /
                ratings.length;

    return Directionality(
      textDirection: l10n.direction,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(l10n.tr('تقييماتي', 'Mes evaluations')),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Rating Summary Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary,
                    AppColors.secondary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: Colors.amber, size: 40),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < averageRating.round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber,
                        size: 24,
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.tr(
                      'بناءً على ${ratings.length} تقييم',
                      'Base sur ${ratings.length} avis',
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Rating Breakdown
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tr('توزيع التقييمات', 'Repartition des notes'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(5, (index) {
                    final star = 5 - index;
                    final count =
                        ratings.where((r) => r.rating.round() == star).length;
                    final percentage =
                        ratings.isEmpty ? 0.0 : count / ratings.length;
                    return _RatingBar(
                      stars: star,
                      count: count,
                      percentage: percentage,
                    );
                  }),
                ],
              ),
            ),

            // Reviews Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    l10n.tr('آراء العملاء', 'Avis clients'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    l10n.tr(
                      '${ratings.length} تقييم',
                      '${ratings.length} avis',
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Reviews List
            Expanded(
              child:
                  ratings.isEmpty
                      ? _EmptyReviews(l10n: l10n)
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: ratings.length,
                        itemBuilder: (context, index) {
                          return _ReviewCard(review: ratings[index]);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  List<_Rating> _getMockRatings() {
    return [
      _Rating(
        clientName: 'أحمد محمد',
        rating: 5,
        comment: 'عمل ممتاز وسريع، أنصح به بشدة!',
        date: DateTime.now().subtract(const Duration(days: 2)),
        serviceType: 'إصلاح',
      ),
      _Rating(
        clientName: 'محمد علي',
        rating: 4,
        comment: 'خدمة جيدة جداً، شكراً على العمل المتقن',
        date: DateTime.now().subtract(const Duration(days: 5)),
        serviceType: 'تركيب',
      ),
      _Rating(
        clientName: 'سعيد أحمد',
        rating: 5,
        comment: 'محترف ودقيق في عمله، ملتزم بالمواعيد',
        date: DateTime.now().subtract(const Duration(days: 8)),
        serviceType: 'صيانة',
      ),
      _Rating(
        clientName: 'خالد يوسف',
        rating: 4,
        comment: 'عمل جيد، أسعار معقولة',
        date: DateTime.now().subtract(const Duration(days: 15)),
        serviceType: 'إصلاح',
      ),
      _Rating(
        clientName: 'عمر حسن',
        rating: 5,
        comment: 'أفضل كهربائي تعاملت معه!',
        date: DateTime.now().subtract(const Duration(days: 20)),
        serviceType: 'تركيب',
      ),
    ];
  }
}

class _Rating {
  final String clientName;
  final double rating;
  final String comment;
  final DateTime date;
  final String serviceType;

  _Rating({
    required this.clientName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.serviceType,
  });
}

class _RatingBar extends StatelessWidget {
  final int stars;
  final int count;
  final double percentage;

  const _RatingBar({
    required this.stars,
    required this.count,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              '$stars',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.background,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 30,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final _Rating review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    review.clientName[0],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.clientName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < review.rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 16,
                          );
                        }),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            review.serviceType,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.date),
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'اليوم';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} أيام';
    } else if (diff.inDays < 30) {
      final weeks = (diff.inDays / 7).floor();
      return 'منذ $weeks أسبوع';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _EmptyReviews extends StatelessWidget {
  final AppLocalizer l10n;

  const _EmptyReviews({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 60,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tr('لا توجد تقييمات بعد', 'Aucune evaluation pour le moment'),
            style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
