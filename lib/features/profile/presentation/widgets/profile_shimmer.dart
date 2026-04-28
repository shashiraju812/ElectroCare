// lib/features/profile/presentation/widgets/profile_shimmer.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            // Header Shimmer
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
            ),
            const SizedBox(height: 24),
            // Details Shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: List.generate(3, (index) => Container(
                  height: 80,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
