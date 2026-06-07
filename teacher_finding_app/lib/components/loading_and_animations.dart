import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../utils/theme.dart';

/// Loading shimmer skeleton
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final double angle;

  const ShimmerLoading({super.key, required this.child, this.angle = 45});

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
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
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 - (_controller.value * 2), widget.angle / 45),
              end: Alignment(1 - (_controller.value * 2), widget.angle / 45),
              colors: [
                Colors.grey[300] ?? Colors.grey,
                Colors.grey[100] ?? Colors.white70,
                Colors.grey[300] ?? Colors.grey,
              ],
              stops: const [0, 0.5, 1],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Skeleton loading card
class SkeletonCard extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius = AppTheme.radiusLg,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShimmerLoading(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Loading state widget
class LoadingWidget extends StatelessWidget {
  final String? label;
  final double size;
  final Color? color;

  const LoadingWidget({super.key, this.label, this.size = 48, this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loadingColor =
        color ?? (isDark ? AppTheme.secondary : AppTheme.primary);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
              strokeWidth: 3,
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: AppTheme.lg),
            Text(
              label!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: loadingColor),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated page transition
class FadeInPageTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const FadeInPageTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Slide up page transition
class SlideUpPageTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const SlideUpPageTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: duration,
      tween: Tween(begin: 1, end: 0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 100 * value),
          child: Opacity(opacity: 1 - (value * 0.2), child: child),
        );
      },
      child: child,
    );
  }
}

/// Animated number counter
class AnimatedCounter extends StatelessWidget {
  final int end;
  final Duration duration;
  final TextStyle? textStyle;
  final String suffix;

  const AnimatedCounter({
    super.key,
    required this.end,
    this.duration = const Duration(milliseconds: 1500),
    this.textStyle,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      duration: duration,
      tween: IntTween(begin: 0, end: end),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '$value$suffix',
          style: textStyle ?? Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}

/// Staggered list animation
class StaggeredAnimationList extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration itemDuration;

  const StaggeredAnimationList({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.itemDuration = const Duration(milliseconds: 600),
  });

  @override
  State<StaggeredAnimationList> createState() => _StaggeredAnimationListState();
}

class _StaggeredAnimationListState extends State<StaggeredAnimationList>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration:
          widget.itemDuration +
          (widget.staggerDelay * (widget.children.length - 1)),
      vsync: this,
    )..forward();

    _animations = List.generate(
      widget.children.length,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (widget.staggerDelay.inMilliseconds *
                        index /
                        (_controller.duration!.inMilliseconds))
                    .clamp(0, 1)
                as double,
            ((widget.staggerDelay.inMilliseconds * index +
                            widget.itemDuration.inMilliseconds) /
                        _controller.duration!.inMilliseconds)
                    .clamp(0, 1)
                as double,
            curve: Curves.easeOut,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.children.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Opacity(
              opacity: _animations[index].value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - _animations[index].value)),
                child: child,
              ),
            );
          },
          child: widget.children[index],
        );
      },
    );
  }
}

/// Premium background with animated glowing blurred circles
class GlowBackground extends StatefulWidget {
  final Widget child;

  const GlowBackground({super.key, required this.child});

  @override
  State<GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<GlowBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background color base
        Container(
          color: isDark ? AppTheme.bgDark : AppTheme.bgLight,
        ),
        
        // Animated gradient blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double animVal = _controller.value;
            final double x1 = size.width * 0.2 + (size.width * 0.1 * math.sin(animVal * 2 * math.pi));
            final double y1 = size.height * 0.2 + (size.height * 0.1 * math.cos(animVal * 2 * math.pi));
            final double x2 = size.width * 0.7 + (size.width * 0.1 * math.cos(animVal * 2 * math.pi));
            final double y2 = size.height * 0.6 + (size.height * 0.1 * math.sin(animVal * 2 * math.pi));

            return Stack(
              children: [
                // Blob 1
                Positioned(
                  left: x1 - 150,
                  top: y1 - 150,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isDark ? AppTheme.primary : AppTheme.primaryLight)
                          .withOpacity(isDark ? 0.12 : 0.15),
                    ),
                  ),
                ),
                // Blob 2
                Positioned(
                  left: x2 - 150,
                  top: y2 - 150,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isDark ? AppTheme.secondary : AppTheme.secondaryLight)
                          .withOpacity(isDark ? 0.08 : 0.12),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // Backdrop filter blur layer
        Positioned.fill(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 75, sigmaY: 75),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Main content on top
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}
