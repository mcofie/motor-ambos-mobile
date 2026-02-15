import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor.withAlpha(240),
            elevation: 0,
            expandedHeight: 60,
            title: Text('Services', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: theme.colorScheme.onSurface, letterSpacing: -1.0)),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: 0.15), shape: BoxShape.circle),
                  child: Icon(Icons.search_rounded, color: theme.colorScheme.onSurface, size: 20),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // --- Search Bar Placeholder ---
                  const SizedBox(height: 12),
                  _buildSearchBar(theme, motTheme),
                  const SizedBox(height: 24),

                  // --- Radar Pulse Section ---
                  _ServiceRadarPulse(theme: theme, motTheme: motTheme),
                  const SizedBox(height: 32),
                  
                  // --- Categories ---
                  _sectionHeader('POPULAR CATEGORIES'),
                  const SizedBox(height: 16),
                  _CategoriesGrid(theme: theme, motTheme: motTheme),
                  const SizedBox(height: 32),
                  
                  // --- Featured Services ---
                  _sectionHeader('FEATURED SERVICES'),
                  const SizedBox(height: 16),
                  _FeaturedServiceCard(
                    title: 'Mobile Mechanic',
                    subtitle: 'Full diagnostic & repair at your location',
                    price: 'From GHS 150',
                    icon: Icons.handyman_rounded,
                    color: Colors.blueAccent,
                    tags: ['Verified', 'Fast'],
                  ),
                  const SizedBox(height: 12),
                  _FeaturedServiceCard(
                    title: 'Instant Insurance',
                    subtitle: 'Renew SIC / Enterprise / Star instantly',
                    price: 'Govt. Rates',
                    icon: Icons.verified_user_rounded,
                    color: Colors.tealAccent,
                    tags: ['Digital', 'Official'],
                  ),
                  const SizedBox(height: 12),
                  _FeaturedServiceCard(
                    title: 'Fuel Delivery',
                    subtitle: 'Emergency Petrol or Diesel top-up',
                    price: 'Market Price',
                    icon: Icons.local_gas_station_rounded,
                    color: Colors.orangeAccent,
                    tags: ['Rescue'],
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, MotorAmbosTheme motTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: Colors.grey.withValues(alpha: 0.8), size: 20),
          const SizedBox(width: 12),
          Text('Search for help, insurance...', style: TextStyle(color: Colors.grey.withValues(alpha: 0.8), fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5),
    );
  }
}

class _ServiceRadarPulse extends StatelessWidget {
  final ThemeData theme;
  final MotorAmbosTheme motTheme;

  const _ServiceRadarPulse({required this.theme, required this.motTheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 25, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(3, (index) {
                return Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.45), width: 1.5),
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .scale(begin: const Offset(1, 1), end: const Offset(2.4, 2.4), duration: 2500.ms, delay: (index * 800).ms, curve: Curves.easeOut)
                  .fade(begin: 1.0, end: 0.0);
              }),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.blueAccent, Colors.cyanAccent]),
                  shape: BoxShape.circle
                ),
                child: const Icon(Icons.radar_rounded, color: Colors.white, size: 24),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SERVICE PULSE', style: TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                const Text('Nearby Activity', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text('12 Verified providers online', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  final ThemeData theme;
  final MotorAmbosTheme motTheme;

  const _CategoriesGrid({required this.theme, required this.motTheme});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _CategoryTile(label: 'Insurance', icon: Icons.security_rounded, color: Colors.tealAccent, desc: 'Digital Renewal'),
        _CategoryTile(label: 'Roadworthy', icon: Icons.assignment_rounded, color: Colors.orangeAccent, desc: 'Renew Fast'),
        _CategoryTile(label: 'Repair', icon: Icons.build_rounded, color: Colors.blueAccent, desc: 'Certified Help'),
        _CategoryTile(label: 'Concierge', icon: Icons.auto_awesome_rounded, color: Colors.purpleAccent, desc: 'Premium Care'),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String label, desc;
  final IconData icon;
  final Color color;

  const _CategoryTile({required this.label, required this.desc, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: motTheme.subtleBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: -0.3)),
              const SizedBox(height: 2),
              Text(desc, style: TextStyle(color: motTheme.slateText, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturedServiceCard extends StatelessWidget {
  final String title, subtitle, price;
  final IconData icon;
  final Color color;
  final List<String> tags;

  const _FeaturedServiceCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
    required this.color,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: motTheme.subtleBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.5)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: TextStyle(color: motTheme.slateText, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: tags.map((tag) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: theme.colorScheme.onSurface.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(tag.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface.withValues(alpha: 0.4), letterSpacing: 0.5)),
                )).toList(),
              ),
              Text(price, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }
}
