import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// Premium primary button with glow effect
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;
  final IconData? icon;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 48,
    this.borderRadius = AppTheme.radiusLg,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 16,
    this.icon,
    this.fullWidth = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _pressController.forward();
  }

  void _onTapUp() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = widget.backgroundColor ?? AppTheme.primary;
    final txColor = widget.textColor ?? Colors.white;

    return ScaleTransition(
      scale: _pressAnimation,
      child: GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) {
          _onTapUp();
          if (widget.isEnabled && !widget.isLoading) {
            widget.onPressed();
          }
        },
        onTapCancel: _onTapUp,
        child: Container(
          width: widget.fullWidth ? double.infinity : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [bgColor, bgColor.withOpacity(0.8)],
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            boxShadow: widget.isEnabled ? AppTheme.shadowGlow(bgColor) : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isEnabled && !widget.isLoading
                  ? widget.onPressed
                  : null,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(txColor),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: txColor, size: 20),
                            const SizedBox(width: AppTheme.md),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: txColor,
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary button with outline
class SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final double? width;
  final double height;
  final double borderRadius;
  final Color? borderColor;
  final Color? textColor;
  final double fontSize;
  final IconData? icon;
  final bool fullWidth;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.width,
    this.height = 48,
    this.borderRadius = AppTheme.radiusLg,
    this.borderColor,
    this.textColor,
    this.fontSize = 16,
    this.icon,
    this.fullWidth = false,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _pressAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _pressAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _onTapDown() {
    _pressController.forward();
  }

  void _onTapUp() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        widget.borderColor ??
        (isDark ? AppTheme.borderDark : AppTheme.borderLight);
    final textColor =
        widget.textColor ?? (isDark ? AppTheme.secondary : AppTheme.primary);

    return ScaleTransition(
      scale: _pressAnimation,
      child: GestureDetector(
        onTapDown: (_) => _onTapDown(),
        onTapUp: (_) {
          _onTapUp();
          if (widget.isEnabled && !widget.isLoading) {
            widget.onPressed();
          }
        },
        onTapCancel: _onTapUp,
        child: Container(
          width: widget.fullWidth ? double.infinity : widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Colors.transparent,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isEnabled && !widget.isLoading
                  ? widget.onPressed
                  : null,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(textColor),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: textColor, size: 20),
                            const SizedBox(width: AppTheme.md),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              color: textColor,
                              fontSize: widget.fontSize,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Text button with hover effect
class TextPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color? textColor;
  final double fontSize;
  final IconData? icon;
  final bool enabled;

  const TextPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.textColor,
    this.fontSize = 14,
    this.icon,
    this.enabled = true,
  });

  @override
  State<TextPrimaryButton> createState() => _TextPrimaryButtonState();
}

class _TextPrimaryButtonState extends State<TextPrimaryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        widget.textColor ?? (isDark ? AppTheme.secondary : AppTheme.primary);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onPressed : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: textColor.withOpacity(widget.enabled ? 1 : 0.5),
                size: widget.fontSize + 2,
              ),
              const SizedBox(width: AppTheme.sm),
            ],
            Text(
              widget.label,
              style: TextStyle(
                color: textColor.withOpacity(widget.enabled ? 1 : 0.5),
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w600,
                decoration: _isHovered && widget.enabled
                    ? TextDecoration.underline
                    : TextDecoration.none,
                decorationColor: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
