import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Gradient Border Card - matches web app's feature cards with cyan-to-purple gradient borders
class GradientBorderCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;
  final double borderWidth;
  final List<Color>? gradientColors;
  final VoidCallback? onTap;
  final bool hasGlow;

  const GradientBorderCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.borderWidth = 1.5,
    this.gradientColors,
    this.onTap,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradientColors ?? [AppTheme.primary, AppTheme.secondary];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: colors[0].withAlpha(77),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ]
            : null,
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(borderRadius - borderWidth),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius - borderWidth),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(20),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Step Card with large background number - matches "How It Works" section in web app
class StepCard extends StatelessWidget {
  final String stepNumber; // "01", "02", etc.
  final IconData icon;
  final String title;
  final String description;
  final Color? accentColor;
  final bool isActive;

  const StepCard({
    super.key,
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.description,
    this.accentColor,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? AppTheme.primary;

    return GradientBorderCard(
      hasGlow: isActive,
      gradientColors: isActive
          ? [color, AppTheme.secondary]
          : [Colors.white24, Colors.white10],
      child: Stack(
        children: [
          // Large background number
          Positioned(
            right: -10,
            top: -20,
            child: Text(
              stepNumber,
              style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.w900,
                color: Colors.white.withAlpha(8),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon in colored circle
              IconCircle(
                icon: icon,
                color: color,
                size: 48,
              ),
              const SizedBox(height: 16),
              // Step number badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(38),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Step $stepNumber',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withAlpha(153),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Icon with colored circular background - matches web app's icon style
class IconCircle extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final bool hasGlow;

  const IconCircle({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.hasGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: color.withAlpha(102),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ]
            : null,
      ),
      child: Icon(
        icon,
        color: color,
        size: size * 0.5,
      ),
    );
  }
}

/// Gradient Text with optional pink highlight - matches web app headlines
class GradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final List<Color>? colors;
  final TextAlign textAlign;

  const GradientText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.fontWeight = FontWeight.bold,
    this.colors,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => LinearGradient(
        colors: colors ?? [AppTheme.primary, AppTheme.secondary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1.2,
        ),
      ),
    );
  }
}

/// Highlighted Text - pink accent for emphasis words (matching web app)
class HighlightedText extends StatelessWidget {
  final String normalText;
  final String highlightText;
  final String? suffixText;
  final double fontSize;
  final FontWeight fontWeight;
  final Color highlightColor;
  final TextAlign textAlign;

  const HighlightedText({
    super.key,
    required this.normalText,
    required this.highlightText,
    this.suffixText,
    this.fontSize = 28,
    this.fontWeight = FontWeight.bold,
    this.highlightColor = AppTheme.accent,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: Colors.white,
          height: 1.3,
        ),
        children: [
          TextSpan(text: normalText),
          TextSpan(
            text: highlightText,
            style: TextStyle(color: highlightColor),
          ),
          if (suffixText != null) TextSpan(text: suffixText),
        ],
      ),
    );
  }
}

/// Feature Card - compact version for feature grids
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppTheme.primary;

    return GradientBorderCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconCircle(icon: icon, color: color, size: 44),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withAlpha(153),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Shimmer Gradient Button
class ShimmerGradientButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final List<Color>? gradientColors;

  const ShimmerGradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.gradientColors,
  });

  @override
  State<ShimmerGradientButton> createState() => _ShimmerGradientButtonState();
}

class _ShimmerGradientButtonState extends State<ShimmerGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
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
    final colors =
        widget.gradientColors ?? [AppTheme.primary, AppTheme.secondary];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width ?? double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors[0], colors[1], colors[0]],
              stops: [0.0, _controller.value, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: colors[0].withAlpha(102),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, color: Colors.white),
                            const SizedBox(width: 10),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Background Blob Decoration - gradient blobs for hero sections
class BackgroundBlob extends StatelessWidget {
  final Color color;
  final double size;
  final Offset offset;
  final double opacity;

  const BackgroundBlob({
    super.key,
    required this.color,
    this.size = 300,
    this.offset = Offset.zero,
    this.opacity = 0.3,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withAlpha((opacity * 255).toInt()),
              color.withAlpha(0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated floating decoration (sparkles/particles)
class FloatingSparkle extends StatefulWidget {
  final Color color;
  final double size;

  const FloatingSparkle({
    super.key,
    this.color = AppTheme.primary,
    this.size = 8,
  });

  @override
  State<FloatingSparkle> createState() => _FloatingSparkleState();
}

class _FloatingSparkleState extends State<FloatingSparkle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withAlpha((_animation.value * 204).toInt()),
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha((_animation.value * 128).toInt()),
                blurRadius: widget.size * 2,
                spreadRadius: widget.size / 2,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Stats Display Row - matching web app's statistics section
class StatsRow extends StatelessWidget {
  final List<StatItem> stats;

  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((stat) {
        return Column(
          children: [
            GradientText(
              text: stat.value,
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
            const SizedBox(height: 4),
            Text(
              stat.label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha(153),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class StatItem {
  final String value;
  final String label;

  const StatItem({required this.value, required this.label});
}

/// Hero Section with gradient blobs background
class HeroSection extends StatelessWidget {
  final Widget child;
  final bool showBlobs;

  const HeroSection({
    super.key,
    required this.child,
    this.showBlobs = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (showBlobs) ...[
          BackgroundBlob(
            color: AppTheme.secondary,
            size: 400,
            offset: const Offset(-150, -100),
            opacity: 0.25,
          ),
          BackgroundBlob(
            color: AppTheme.primary,
            size: 300,
            offset: Offset(MediaQuery.of(context).size.width - 100, 100),
            opacity: 0.15,
          ),
        ],
        child,
      ],
    );
  }
}

/// Section Title with optional highlight
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? highlightWord;
  final Color highlightColor;
  final TextAlign textAlign;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.highlightWord,
    this.highlightColor = AppTheme.accent,
    this.textAlign = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    // Split title around highlight word if provided
    Widget titleWidget;
    if (highlightWord != null && title.contains(highlightWord!)) {
      final parts = title.split(highlightWord!);
      titleWidget = HighlightedText(
        normalText: parts[0],
        highlightText: highlightWord!,
        suffixText: parts.length > 1 ? parts[1] : null,
        fontSize: 28,
        textAlign: textAlign,
      );
    } else {
      titleWidget = Text(
        title,
        textAlign: textAlign,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }

    return Column(
      crossAxisAlignment: textAlign == TextAlign.center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        titleWidget,
        if (subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            subtitle!,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withAlpha(153),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

/// Logo Widget matching CreatorShield branding
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool hasGlow;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.hasGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: hasGlow
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withAlpha(102),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            Icons.shield_rounded,
            size: size * 0.55,
            color: Colors.white,
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.3),
          GradientText(
            text: 'CreatorShield',
            fontSize: size * 0.35,
            fontWeight: FontWeight.w800,
          ),
        ],
      ],
    );
  }
}

/// Outline Button with gradient border
class GradientOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double? width;

  const GradientOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(10.5),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10.5),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 8),
                  ],
                  GradientText(
                    text: text,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated counter for stats
class AnimatedCounter extends StatefulWidget {
  final int targetValue;
  final TextStyle? style;
  final Duration duration;
  final String? suffix;

  const AnimatedCounter({
    super.key,
    required this.targetValue,
    this.style,
    this.duration = const Duration(milliseconds: 1200),
    this.suffix,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.targetValue.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetValue != widget.targetValue) {
      _animation = Tween<double>(
        begin: oldWidget.targetValue.toDouble(),
        end: widget.targetValue.toDouble(),
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          '${_animation.value.toInt()}${widget.suffix ?? ''}',
          style: widget.style,
        );
      },
    );
  }
}

/// Shimmer Loading Placeholder
class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: const [
                Color(0xFF1E293B),
                Color(0xFF2D3B4F),
                Color(0xFF1E293B),
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
              begin: const Alignment(-1.0, 0.0),
              end: const Alignment(1.0, 0.0),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton Proof Card for loading state
class SkeletonProofCard extends StatelessWidget {
  const SkeletonProofCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(25)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(height: 120, borderRadius: 16),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 18, width: 180),
                SizedBox(height: 8),
                ShimmerBox(height: 14, width: 120),
                SizedBox(height: 10),
                Row(
                  children: [
                    ShimmerBox(height: 24, width: 70, borderRadius: 20),
                    SizedBox(width: 8),
                    ShimmerBox(height: 14, width: 60),
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

/// Pulsing Glow effect for CTAs
class PulseGlow extends StatefulWidget {
  final Widget child;
  final Color color;
  final double maxRadius;

  const PulseGlow({
    super.key,
    required this.child,
    this.color = AppTheme.primary,
    this.maxRadius = 20,
  });

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
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
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.color.withAlpha((50 + (30 * _controller.value)).toInt()),
                blurRadius: widget.maxRadius * (0.5 + 0.5 * _controller.value),
                spreadRadius: widget.maxRadius * 0.1 * _controller.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Bottom Sheet Handle widget
class BottomSheetHandle extends StatelessWidget {
  const BottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
