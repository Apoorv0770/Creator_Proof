import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Glassmorphic Card Widget
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool hasGlow;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 16,
    this.hasGlow = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha(25),
            Colors.white.withAlpha(13),
          ],
        ),
        border: Border.all(color: Colors.white.withAlpha(38)),
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: AppTheme.primary.withAlpha(51),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Neon Glow Text
class NeonText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const NeonText({
    super.key,
    required this.text,
    this.fontSize = 24,
    this.fontWeight = FontWeight.bold,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? AppTheme.primary;
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
        shadows: [
          Shadow(color: textColor.withAlpha(128), blurRadius: 10),
          Shadow(color: textColor.withAlpha(77), blurRadius: 20),
        ],
      ),
    );
  }
}

/// Gradient Button with Glow
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: onPressed != null ? AppTheme.primaryGradient : null,
        color: onPressed == null ? Colors.grey.withAlpha(77) : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: AppTheme.primary.withAlpha(102),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        text,
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
  }
}

/// Status Badge (Verified, Pending, etc.)
class StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  // User-friendly labels (no blockchain jargon)
  factory StatusBadge.secured() => const StatusBadge(
        text: 'Secured',
        color: AppTheme.success,
        icon: Icons.verified,
      );

  factory StatusBadge.processing() => const StatusBadge(
        text: 'Processing',
        color: AppTheme.warning,
        icon: Icons.hourglass_empty,
      );

  factory StatusBadge.failed() => const StatusBadge(
        text: 'Failed',
        color: AppTheme.error,
        icon: Icons.error_outline,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated Stat Card
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? color;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.primary;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cardColor.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: cardColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }
}

/// Upload Zone with Drag & Drop visual
class UploadZone extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasFile;
  final String? fileName;
  final double? progress;
  final Widget? child;
  final double height;

  const UploadZone({
    super.key,
    required this.onTap,
    this.hasFile = false,
    this.fileName,
    this.progress,
    this.child,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasFile ? AppTheme.primary : Colors.white.withAlpha(51),
            width: 2,
            style: hasFile ? BorderStyle.solid : BorderStyle.none,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.surfaceLight.withAlpha(128),
              AppTheme.surface.withAlpha(128),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Dashed border effect
            if (!hasFile && child == null)
              CustomPaint(
                size: Size(double.infinity, height),
                painter: _DashedBorderPainter(),
              ),

            // Custom child content or default content
            Center(
              child: child ?? (hasFile
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            size: 48, color: AppTheme.primary),
                        const SizedBox(height: 12),
                        Text(
                          fileName ?? 'File selected',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: onTap,
                          child: const Text('Change file'),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: 40,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Tap to select your work',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Images, videos, documents, music...',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withAlpha(128),
                          ),
                        ),
                      ],
                    )),
            ),

            // Progress indicator
            if (progress != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withAlpha(25),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                    minHeight: 4,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for dashed border
class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(51)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(20),
      ));

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashWidth).clamp(0, metric.length);
        canvas.drawPath(metric.extractPath(start, end.toDouble()), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Simple animated loading with text
class LoadingOverlay extends StatelessWidget {
  final String message;
  final double? progress;

  const LoadingOverlay({
    super.key,
    required this.message,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background.withAlpha(230),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (progress != null)
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 4,
                      backgroundColor: Colors.white.withAlpha(25),
                      valueColor:
                          const AlwaysStoppedAnimation(AppTheme.primary),
                    ),
                    Text(
                      '${(progress! * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              )
            else
              const CircularProgressIndicator(color: AppTheme.primary),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared Empty State widget
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primary.withAlpha(25),
                    AppTheme.secondary.withAlpha(15),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppTheme.primary.withAlpha(128)),
            ),
            const SizedBox(height: 24),
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withAlpha(153))),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              GradientButton(
                text: actionLabel!,
                onPressed: onAction,
                width: 200,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
