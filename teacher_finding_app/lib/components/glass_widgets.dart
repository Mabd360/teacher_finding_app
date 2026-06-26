import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/theme.dart';

/// A floating ambient mesh blob for premium glassmorphism backgrounds.
class GlowBlob extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final double opacity;
  final Duration duration;
  final Offset startOffset;
  final Offset endOffset;

  const GlowBlob({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    this.opacity = 0.22,
    this.duration = const Duration(seconds: 25),
    this.startOffset = Offset.zero,
    this.endOffset = const Offset(80, -60),
  });

  @override
  State<GlowBlob> createState() => _GlowBlobState();
}

class _GlowBlobState extends State<GlowBlob> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animationX;
  late final Animation<double> _animationY;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);

    _animationX = Tween<double>(
      begin: widget.startOffset.dx,
      end: widget.endOffset.dx,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _animationY = Tween<double>(
      begin: widget.startOffset.dy,
      end: widget.endOffset.dy,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_animationX.value, _animationY.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(widget.opacity),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A glassmorphic card imitating dark/light mode dashboard glass panels.
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool showNeonBorder;
  final Gradient? neonBorderGradient;
  final double blurSigma;
  final Color? customBgColor;
  final double borderOpacity;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = AppTheme.radiusLg,
    this.showNeonBorder = false,
    this.neonBorderGradient,
    this.blurSigma = 24.0,
    this.customBgColor,
    this.borderOpacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Modern glass-like semi-transparent background color
    final defaultBg = isDark
        ? const Color(0x9A0A0B14) // rgba(10, 11, 20, 0.6)
        : const Color(0xB3FFFFFF); // rgba(255, 255, 255, 0.7)

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: customBgColor ?? defaultBg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 1.0,
            ),
          ),
          child: Stack(
            children: [
              if (showNeonBorder)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: neonBorderGradient ??
                          AppTheme.gradientPrimaryToSecondary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: showNeonBorder
                    ? const EdgeInsets.only(top: 4.0)
                    : EdgeInsets.zero,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A primary neon button with scaling animations and neon glow effects.
class NeonButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color glowColor;
  final Gradient? gradient;
  final double borderRadius;
  final double height;

  const NeonButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.glowColor = AppTheme.primary,
    this.gradient,
    this.borderRadius = AppTheme.radiusLg,
    this.height = 54.0,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultGradient = widget.gradient ?? AppTheme.gradientPrimaryToSecondary;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: widget.onPressed != null ? defaultGradient : null,
                color: widget.onPressed == null ? Colors.grey.withOpacity(0.2) : null,
                boxShadow: widget.onPressed != null && _isHovering
                    ? AppTheme.shadowGlow(widget.glowColor)
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  hoverColor: Colors.white.withOpacity(0.08),
                  splashColor: Colors.white.withOpacity(0.12),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.xl),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A wrapper scaffold that provides the premium ambient floating blobs background.
class GlassScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool resizeToAvoidBottomInset;

  const GlassScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: Stack(
        children: [
          // Ambient Mesh Background Blobs (placed way back)
          Positioned(
            top: -100,
            left: -100,
            child: GlowBlob(
              width: 450,
              height: 450,
              color: AppTheme.primary,
              opacity: 0.18,
              duration: const Duration(seconds: 22),
              startOffset: Offset.zero,
              endOffset: const Offset(60, 40),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: GlowBlob(
              width: 500,
              height: 500,
              color: AppTheme.secondary,
              opacity: 0.16,
              duration: const Duration(seconds: 28),
              startOffset: Offset.zero,
              endOffset: const Offset(-50, -80),
            ),
          ),
          Positioned(
            top: 250,
            right: -100,
            child: GlowBlob(
              width: 350,
              height: 350,
              color: AppTheme.accent,
              opacity: 0.14,
              duration: const Duration(seconds: 20),
              startOffset: Offset.zero,
              endOffset: const Offset(-80, 50),
            ),
          ),
          
          // Full-screen backdrop filter to blend the blobs into a mesh
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),

          // Actual Screen Scaffold Layout
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: appBar,
            body: body,
            bottomNavigationBar: bottomNavigationBar,
            floatingActionButton: floatingActionButton,
            floatingActionButtonLocation: floatingActionButtonLocation,
            resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          ),
        ],
      ),
    );
  }
}
