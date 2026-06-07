import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'cards.dart';


/// Modern search bar component
class ModernSearchBar extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSearch;
  final VoidCallback? onClear;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final IconData leadingIcon;
  final IconData? trailingIcon;
  final bool enabled;

  const ModernSearchBar({
    super.key,
    this.hintText = 'Search...',
    this.controller,
    this.onChanged,
    this.onSearch,
    this.onClear,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = AppTheme.radiusLg,
    this.leadingIcon = Icons.search,
    this.trailingIcon,
    this.enabled = true,
  });

  @override
  State<ModernSearchBar> createState() => _ModernSearchBarState();
}

class _ModernSearchBarState extends State<ModernSearchBar> {
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ??
        (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight);
    final borderColor = widget.borderColor ??
        (isDark ? AppTheme.borderDark : AppTheme.borderLight);

    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      onSubmitted: (_) => widget.onSearch?.call(),
      onTap: () => setState(() => _isFocused = true),
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: bgColor,
        prefixIcon: Icon(widget.leadingIcon),
        suffixIcon: _controller.text.isNotEmpty && widget.onClear != null
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  widget.onClear?.call();
                  setState(() {});
                },
              )
            : widget.trailingIcon != null
                ? Icon(widget.trailingIcon)
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: AppTheme.lg, vertical: AppTheme.md),
      ),
    );
  }
}

/// Rating widget with stars
class RatingWidget extends StatelessWidget {
  final double rating;
  final int totalReviews;
  final double? maxRating;
  final Color? starColor;
  final double starSize;
  final bool showValue;
  final TextStyle? textStyle;

  const RatingWidget({
    super.key,
    required this.rating,
    this.totalReviews = 0,
    this.maxRating = 5.0,
    this.starColor,
    this.starSize = 18,
    this.showValue = true,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = starColor ?? AppTheme.warning;
    final displayRating = (rating * 10).round() / 10;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: starSize * 5 + 8,
          height: starSize,
          child: Stack(
            children: [
              Row(
                children: List.generate(
                  5,
                  (index) => Expanded(
                    child: Icon(
                      Icons.star_border,
                      color: (isDark
                              ? AppTheme.textMutedDark
                              : AppTheme.textMutedLight)
                          .withOpacity(0.3),
                      size: starSize,
                    ),
                  ),
                ),
              ),
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: (rating / (maxRating ?? 5)),
                  child: Row(
                    children: List.generate(
                      5,
                      (index) => Expanded(
                        child: Icon(
                          Icons.star_rounded,
                          color: color,
                          size: starSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showValue) ...[
          const SizedBox(width: AppTheme.sm),
          Text(
            displayRating.toString(),
            style: textStyle ??
                Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isDark
                          ? AppTheme.textDarkDark
                          : AppTheme.textDarkLight,
                    ),
          ),
          if (totalReviews > 0) ...[
            const SizedBox(width: AppTheme.xs),
            Text(
              '($totalReviews)',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ],
      ],
    );
  }
}

/// Teacher card for listing
class TeacherCard extends StatelessWidget {
  final String name;
  final String subject;
  final String? imageUrl;
  final double rating;
  final int reviews;
  final String hourlyRate;
  final List<String>? subjects;
  final VoidCallback? onTap;
  final bool isBookmarked;
  final VoidCallback? onBookmarkPressed;

  const TeacherCard({
    super.key,
    required this.name,
    required this.subject,
    this.imageUrl,
    this.rating = 0,
    this.reviews = 0,
    this.hourlyRate = '',
    this.subjects,
    this.onTap,
    this.isBookmarked = false,
    this.onBookmarkPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: ModernCard(
        padding: const EdgeInsets.all(AppTheme.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    image: imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl == null
                      ? Icon(
                          Icons.person,
                          color: AppTheme.primary,
                          size: 28,
                        )
                      : null,
                ),
                const SizedBox(width: AppTheme.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppTheme.xs),
                      Text(
                        subject,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (onBookmarkPressed != null)
                  IconButton(
                    onPressed: onBookmarkPressed,
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? AppTheme.warning : null,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.md),
            RatingWidget(
              rating: rating,
              totalReviews: reviews,
              starSize: 14,
            ),
            if (hourlyRate.isNotEmpty) ...[
              const SizedBox(height: AppTheme.md),
              Text(
                hourlyRate,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
