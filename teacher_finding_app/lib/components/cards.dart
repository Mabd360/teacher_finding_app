import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../utils/theme.dart';
import 'buttons.dart';

/// Premium glass card with backdrop blur
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurAmount;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = AppTheme.radiusXl,
    this.blurAmount = 10,
    this.padding = const EdgeInsets.all(AppTheme.lg),
    this.backgroundColor,
    this.boxShadow,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ??
        (isDark
            ? AppTheme.cardDark.withOpacity(0.4)
            : AppTheme.cardLight.withOpacity(0.6));

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border:
                    border ??
                    Border.all(
                      color: isDark
                          ? AppTheme.borderDark.withOpacity(0.3)
                          : AppTheme.borderLight.withOpacity(0.3),
                      width: 1,
                    ),
                boxShadow: boxShadow ?? AppTheme.shadowMedium,
              ),
              padding: padding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern elevated card
class ModernCard extends StatefulWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final bool hover;
  final Color? borderColor;

  const ModernCard({
    super.key,
    required this.child,
    this.borderRadius = AppTheme.radiusLg,
    this.padding = const EdgeInsets.all(AppTheme.lg),
    this.backgroundColor,
    this.boxShadow,
    this.onTap,
    this.hover = true,
    this.borderColor,
  });

  @override
  State<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends State<ModernCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        widget.backgroundColor ??
        (isDark ? AppTheme.cardDark : AppTheme.cardLight);
    final borderColor =
        widget.borderColor ??
        (isDark ? AppTheme.borderDark : AppTheme.borderLight);

    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(color: borderColor),
              boxShadow: widget.hover && _isHovered
                  ? AppTheme.shadowLarge
                  : widget.boxShadow ?? AppTheme.shadowMedium,
            ),
            transform: widget.hover && _isHovered
                ? Matrix4.translationValues(0, -4, 0)
                : Matrix4.identity(),
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Dashboard statistics card
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? backgroundColor;
  final String? trend;
  final Color? trendColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor = AppTheme.primary,
    this.backgroundColor,
    this.trend,
    this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ?? (isDark ? AppTheme.cardDark : AppTheme.cardLight);

    return ModernCard(
      backgroundColor: bgColor,
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.md,
                    vertical: AppTheme.xs,
                  ),
                  decoration: BoxDecoration(
                    color: (trendColor ?? AppTheme.success).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    trend!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: trendColor ?? AppTheme.success,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppTheme.lg),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppTheme.sm),
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}

/// Section header with optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final IconData? actionIcon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onActionPressed,
    this.actionLabel,
    this.actionIcon = Icons.arrow_forward,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: AppTheme.sm),
                Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (onActionPressed != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onActionPressed,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (actionLabel != null)
                      Text(
                        actionLabel!,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(width: AppTheme.xs),
                    Icon(
                      actionIcon,
                      color: Theme.of(context).primaryColor,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Profile header component
class ProfileHeader extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? imageUrl;
  final Widget? avatar;
  final Color? backgroundColor;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.subtitle,
    this.imageUrl,
    this.avatar,
    this.backgroundColor,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ?? (isDark ? AppTheme.cardDark : AppTheme.cardLight);

    return ModernCard(
      backgroundColor: bgColor,
      padding: const EdgeInsets.all(AppTheme.xl),
      child: Row(
        children: [
          avatar ??
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null
                    ? Icon(Icons.person, color: AppTheme.primary, size: 32)
                    : null,
              ),
          const SizedBox(width: AppTheme.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppTheme.xs),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          if (onEditPressed != null)
            IconButton(
              onPressed: onEditPressed,
              icon: const Icon(Icons.edit),
              color: Theme.of(context).primaryColor,
              tooltip: 'Edit profile',
            ),
        ],
      ),
    );
  }
}

/// Empty state widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final Color? iconColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.onActionPressed,
    this.actionLabel,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color =
        iconColor ??
        (isDark ? AppTheme.textMutedDark : AppTheme.textMutedLight);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color.withOpacity(0.3)),
          const SizedBox(height: AppTheme.xl),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            const SizedBox(height: AppTheme.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg),
              child: Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ],
          if (onActionPressed != null && actionLabel != null) ...[
            const SizedBox(height: AppTheme.xl),
            PrimaryButton(label: actionLabel!, onPressed: onActionPressed!),
          ],
        ],
      ),
    );
  }
}
