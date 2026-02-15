import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:motor_ambos/src/app/motorambos_theme_extension.dart';
import 'package:motor_ambos/src/features/services/data/mock_services.dart';
import 'package:motor_ambos/src/features/services/domain/service_provider.dart';

class ServiceCategoryScreen extends StatelessWidget {
  final ServiceCategory category;

  const ServiceCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;
    
    // Filter the mock data
    final providers = mockServices.where((s) => s.category.name == category.name).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          category.label.toUpperCase(),
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list_rounded, color: theme.colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: providers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 60, color: motTheme.subtleBorder),
                  const SizedBox(height: 16),
                  Text(
                    'No ${category.label} found yet.',
                    style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: providers.length,
              itemBuilder: (context, index) {
                return _ProviderCard(provider: providers[index]);
              },
            ),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final ServiceProvider provider;

  const _ProviderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motTheme = theme.extension<MotorAmbosTheme>()!;

    return GestureDetector(
      onTap: () => context.pushNamed('service-provider-detail', extra: provider),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: motTheme.subtleBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Icon + Name + Verified Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: motTheme.inputBg,
                  borderRadius: BorderRadius.circular(12),
                  // Placeholder for actual image loading
                  image: provider.imageUrl.isNotEmpty
                      ? null // DecorationImage(image: AssetImage(provider.imageUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: provider.imageUrl.isEmpty 
                    ? Icon(Icons.storefront_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))
                    : const Icon(Icons.business_rounded, color: Colors.blueGrey), // Temp
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(provider.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.colorScheme.onSurface, letterSpacing: -0.5))),
                        if (provider.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.verified_rounded, color: Colors.blueAccent, size: 16),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(provider.rating.toString(), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                        Text(' (120+)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: motTheme.slateText)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),

          // Info Rows: Address, Hours, Phone
          _InfoRow(icon: Icons.location_on_rounded, text: provider.address, isBold: false),
          const SizedBox(height: 12),
          _InfoRow(icon: Icons.access_time_filled_rounded, text: 'Open: ${provider.openHours}', isBold: false),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'CALL NOW',
                  icon: Icons.phone_rounded,
                  color: theme.colorScheme.onSurface, // Primary text color for outline
                  isPrimary: false,
                  onTap: () {}, // Implement call launch
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'DIRECTIONS',
                  icon: Icons.directions_rounded,
                  color: theme.colorScheme.primary, // Brand Green
                  isPrimary: true,
                  onTap: () {}, // Implement map launch
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isBold;

  const _InfoRow({required this.icon, required this.text, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13, 
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500, 
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8)
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({required this.label, required this.icon, required this.color, required this.isPrimary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.transparent,
          border: Border.all(color: isPrimary ? Colors.transparent : Colors.grey.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isPrimary ? Colors.white : color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isPrimary ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
