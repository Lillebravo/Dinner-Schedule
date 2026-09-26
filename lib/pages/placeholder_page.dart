import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common/section_intro.dart';

/// A "coming soon" page reused by every section that isn't built out yet.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionIntro(eyebrow: eyebrow, headline: title, subtitle: subtitle),
            const SizedBox(height: 40),
            Center(child: Icon(icon, size: 72, color: AppColors.of(context).line)),
          ],
        ),
      ),
    );
  }
}
