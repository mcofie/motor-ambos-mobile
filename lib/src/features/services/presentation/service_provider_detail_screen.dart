import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';
import 'package:motor_ambos/src/features/services/domain/service_provider.dart';

class ServiceProviderDetailScreen extends StatelessWidget {
  final ServiceProvider provider;

  const ServiceProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Cover Image & AppBar
          SliverAppBar(
            pinned: true,
            expandedHeight: 220,
            backgroundColor: theme.scaffoldBackgroundColor,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () {}, // Favorite
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                    child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: motTheme.inputBg), // Placeholder
                  // If use real image: Image.asset(provider.imageUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent, theme.scaffoldBackgroundColor],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Center(child: Icon(Icons.storefront_rounded, size: 60, color: theme.colorScheme.onSurface.withValues(alpha: 0.2))),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Headings
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          provider.name,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, height: 1.1, color: theme.colorScheme.onSurface),
                        ),
                      ),
                      if (provider.isVerified)
                        const Icon(Icons.verified_rounded, color: Colors.blueAccent, size: 24),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text('${provider.rating}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      const SizedBox(width: 4),
                      Text('(${provider.reviewCount} reviews)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: motTheme.slateText)),
                      const SizedBox(width: 16),
                      Icon(Icons.location_on_rounded, color: motTheme.slateText, size: 14),
                      const SizedBox(width: 4),
                      Text(provider.distance, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: motTheme.slateText)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 3. Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: _FeatureButton(icon: Icons.phone_rounded, label: 'Call', onTap: (){}),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FeatureButton(icon: Icons.directions_rounded, label: 'Direction', onTap: (){}),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FeatureButton(icon: Icons.share_rounded, label: 'Share', onTap: (){}),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 4. About
                  const Text('ABOUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text(
                    provider.about,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.6, color: theme.colorScheme.onSurface.withValues(alpha: 0.8)),
                  ),

                  const SizedBox(height: 32),

                  // 5. Services Menu
                  const Text('SERVICES & PRICING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                  const SizedBox(height: 12),
                  ...provider.services.map((s) => _ServiceListTile(service: s)),

                  const SizedBox(height: 32),

                  // 6. Location / Hours
                   const Text('LOCATION & HOURS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
                   const SizedBox(height: 12),
                   _InfoTile(icon: Icons.access_time_filled_rounded, text: provider.openHours),
                   const SizedBox(height: 8),
                   _InfoTile(icon: Icons.map_rounded, text: provider.address),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.paddingOf(context).bottom + 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(top: BorderSide(color: motTheme.subtleBorder)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Text('BOOK APPOINTMENT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
        ),
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FeatureButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: motTheme.subtleBorder),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.onSurface),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withValues(alpha: 0.8))),
          ],
        ),
      ),
    );
  }
}

class _ServiceListTile extends StatelessWidget {
  final ServiceItem service;
  const _ServiceListTile({required this.service});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: motTheme.subtleBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: theme.colorScheme.onSurface)),
                if (service.duration != null)
                  Text(service.duration!, style: TextStyle(fontSize: 11, color: motTheme.slateText, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(
            service.price == 0 ? 'Free Quote' : 'GHS ${service.price.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.green),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoTile({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: theme.colorScheme.onSurface))),
      ],
    );
  }
}
