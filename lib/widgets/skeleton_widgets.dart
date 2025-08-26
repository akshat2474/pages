import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonContainer extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonContainer({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class PostCardSkeleton extends StatelessWidget {
  final bool isLarge;

  const PostCardSkeleton({super.key, this.isLarge = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonContainer(
                  width: 80,
                  height: 16,
                  borderRadius: BorderRadius.circular(4),
                ),

                SizedBox(height: 16),

                SkeletonContainer(
                  width: double.infinity,
                  height: isLarge ? 32 : 24,
                ),

                SizedBox(height: 8),

                SkeletonContainer(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: isLarge ? 32 : 24,
                ),

                SizedBox(height: 12),

                SkeletonContainer(width: double.infinity, height: 16),

                SizedBox(height: 8),

                SkeletonContainer(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 16,
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    SkeletonContainer(width: 80, height: 12),
                    SizedBox(width: 8),
                    SkeletonContainer(
                      width: 4,
                      height: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    SizedBox(width: 8),
                    SkeletonContainer(width: 60, height: 12),
                    Spacer(),
                    SkeletonContainer(width: 40, height: 12),
                  ],
                ),
              ],
            ),
          ),

          if (isLarge) ...[
            SizedBox(width: 32),
            SkeletonContainer(
              width: 120,
              height: 120,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ],
      ),
    );
  }
}

class DailyContentSkeleton extends StatelessWidget {
  const DailyContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonContainer(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(12),
              ),
              SizedBox(width: 16),
              SkeletonContainer(width: 180, height: 18),
            ],
          ),

          SizedBox(height: 24),

          Row(
            children: [
              SkeletonContainer(width: 20, height: 20),
              SizedBox(width: 8),
              SkeletonContainer(width: 100, height: 16),
            ],
          ),
          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonContainer(width: 150, height: 28),
                SizedBox(height: 8),
                SkeletonContainer(width: double.infinity, height: 16),
                SizedBox(height: 4),
                SkeletonContainer(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 16,
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          Row(
            children: [
              SkeletonContainer(width: 20, height: 20),
              SizedBox(width: 8),
              SkeletonContainer(width: 120, height: 16),
            ],
          ),
          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                SkeletonContainer(width: double.infinity, height: 18),
                SizedBox(height: 8),
                SkeletonContainer(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 18,
                ),
                SizedBox(height: 8),
                SkeletonContainer(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PostListSkeleton extends StatelessWidget {
  final int itemCount;

  const PostListSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Container(
          margin: EdgeInsets.only(bottom: 32),
          child: PostCardSkeleton(isLarge: index == 0),
        ),
      ),
    );
  }
}

class RecentPostsSkeleton extends StatelessWidget {
  final int itemCount;

  const RecentPostsSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 768 ? 3 : 1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.2,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonContainer(
                width: 80,
                height: 14,
                borderRadius: BorderRadius.circular(3),
              ),

              SizedBox(height: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonContainer(width: double.infinity, height: 18),
                    SizedBox(height: 8),
                    SkeletonContainer(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 18,
                    ),
                    SizedBox(height: 8),
                    SkeletonContainer(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: 18,
                    ),

                    Spacer(),

                    SkeletonContainer(width: 60, height: 12),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
