// lib/features/profile/presentation/screens/profile_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Services
import '../../../../services/auth_service.dart';
import '../../../../services/order_service.dart';
import '../../../../services/language_service.dart';

// Features (Modular Profile)
import '../providers/profile_provider.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_details.dart';
import '../widgets/profile_orders.dart';
import '../widgets/profile_settings.dart';
import '../widgets/profile_shimmer.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialProfile();
    });
  }

  void _fetchInitialProfile() {
    final auth = legacy.Provider.of<AuthService>(context, listen: false);
    if (auth.currentUser != null) {
      ref.read(profileNotifierProvider.notifier).fetchProfile(auth.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = legacy.Provider.of<AuthService>(context);
    final orderService = legacy.Provider.of<OrderService>(context);
    final langService = legacy.Provider.of<LanguageService>(context);
    
    final orders = orderService.allOrders;
    final isGuest = auth.currentUser == null;
    final fallbackName = auth.userName ?? 'Guest User';

    final profileState = ref.watch(profileNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: RefreshIndicator(
        onRefresh: () async {
          if (!isGuest) {
            await ref.read(profileNotifierProvider.notifier).fetchProfile(auth.currentUser!.uid);
          }
        },
        child: CustomScrollView(
          slivers: [
            profileState.when(
              loading: () => const ProfileShimmer(),
              error: (err, _) => SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('Error: $err'),
                        TextButton(
                          onPressed: () => _fetchInitialProfile(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              data: (_) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            
            // Only show content if not loading/error OR if we have data (already handled by .when)
            if (profileState.hasValue) ...[
              ProfileHeader(
                fallbackName: fallbackName,
                orderCount: orders.length,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ProfileDetails(auth: auth),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              if (!isGuest) ProfileOrders(orders: orders),
              if (!isGuest) const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ProfileSettings(
                isGuest: isGuest,
                auth: auth,
                langService: langService,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
