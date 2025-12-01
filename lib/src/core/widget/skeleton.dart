import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';

class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;
  final double radius;

  const SkeletonCard({
    super.key,
    this.height = 100,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: Theme.of(context).extension<MotorAmbosTheme>()!.subtleBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Skeleton(width: 40, height: 40, radius: 12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Skeleton(width: 120, height: 16),
                    const SizedBox(height: 8),
                    const Skeleton(width: 80, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          const Skeleton(width: double.infinity, height: 12),
        ],
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 100,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (_, __) => SkeletonCard(height: itemHeight),
    );
  }
}
