import 'package:flutter/material.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        backgroundColor: cs.primaryContainer,
        foregroundColor: cs.onPrimaryContainer,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    cs.primaryContainer,
                    cs.secondaryContainer,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.workspace_premium,
                    size: 72,
                    color: cs.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Timelapse Premium',
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.onPrimaryContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock the full power of long-delay timelapse photography',
                    style: tt.bodyLarge?.copyWith(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Features list
                  Text(
                    "What you'll get",
                    style: tt.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _FeatureItem(
                    icon: Icons.folder_open_outlined,
                    color: cs.primary,
                    title: 'Unlimited Projects',
                    subtitle: 'No cap on the number of timelapse projects',
                    available: true,
                  ),
                  _FeatureItem(
                    icon: Icons.hd_outlined,
                    color: cs.secondary,
                    title: '4K Export',
                    subtitle: 'Full resolution 3840×2160 MP4 export',
                    available: true,
                  ),
                  _FeatureItem(
                    icon: Icons.palette_outlined,
                    color: cs.tertiary,
                    title: 'Color Grading Presets',
                    subtitle: 'Cinematic looks: Warm, Cool, Vintage, B&W',
                    available: true,
                  ),
                  _FeatureItem(
                    icon: Icons.cloud_upload_outlined,
                    color: cs.error,
                    title: 'Cloud HQ Render',
                    subtitle: 'Server-side rendering with stabilization',
                    available: false,
                    comingSoon: true,
                  ),

                  const SizedBox(height: 32),

                  // Pricing placeholder
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Early Access Pricing',
                          style: tt.labelLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$2.99',
                              style: tt.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '/month',
                                style: tt.bodyLarge?.copyWith(
                                    color: cs.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'or \$19.99/year — save 44%',
                          style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Purchase button (Phase 1 placeholder)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _showComingSoon(context),
                      icon: const Icon(Icons.workspace_premium),
                      label: const Text('Subscribe — Coming Soon'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _showComingSoon(context),
                      child: const Text('Restore Purchase'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Disclaimer
                  Text(
                    'Purchases are managed by your app store. '
                    'Subscriptions auto-renew unless cancelled at least '
                    '24 hours before the end of the current period.',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  VoidCallback _showComingSoon(BuildContext context) {
    return () {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium subscriptions coming soon!'),
          duration: Duration(seconds: 2),
        ),
      );
    };
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool available;
  final bool comingSoon;

  const _FeatureItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.available,
    this.comingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 8),
                    if (comingSoon)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.tertiaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Coming Soon',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: cs.onTertiaryContainer),
                        ),
                      ),
                  ],
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
