import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Caps the max width of the child on wider viewports (tablet/desktop) and centers it.
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;
  final ScrollPhysics? physics;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 650,
    this.padding = const EdgeInsets.symmetric(horizontal: AppTheme.lg),
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth <= maxWidth) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Splits the screen into two columns on desktop/tablet (Width > 800),
/// showing a premium brand banner on the left and the main form on the right.
/// On mobile, it defaults to just the form.
class ResponsiveSplitLayout extends StatelessWidget {
  final Widget formChild;
  final String title;
  final String subtitle;

  const ResponsiveSplitLayout({
    super.key,
    required this.formChild,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Mobile layout
    if (screenWidth <= 850) {
      return formChild;
    }

    // Desktop/Tablet split layout
    return Row(
      children: [
        // Left Column: Premium Brand Banner
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.gradientPrimaryToAccent,
            ),
            child: Stack(
              children: [
                // Subtle decorative background circles
                Positioned(
                  top: -100,
                  left: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -150,
                  right: -50,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.xxxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppTheme.radiusXxl),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppTheme.xl),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.md),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.85),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Right Column: The Action/Form
        Expanded(
          flex: 6,
          child: Container(
            color: isDark ? AppTheme.bgDark : AppTheme.bgLight,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.xxl),
                  child: formChild,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
