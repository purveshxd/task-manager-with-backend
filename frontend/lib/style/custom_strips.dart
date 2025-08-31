import 'package:flutter/material.dart';

class StripedProgressBar extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color backgroundColor;
  final Color progressColor;
  final Color stripeColor;
  final double stripeWidth;
  final BorderRadius? borderRadius;
  final Duration animationDuration;

  const StripedProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.backgroundColor = const Color(0xFF2A2A2A),
    this.progressColor = const Color(0xFF4F46E5),
    this.stripeColor = const Color(0xFF6366F1),
    this.stripeWidth = 4.0,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<StripedProgressBar> createState() => _StripedProgressBarState();
}

class _StripedProgressBarState extends State<StripedProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _stripeAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _stripeAnimation;
  late Animation<double> _progressAnimation;

  double _currentProgress = 0.0;

  @override
  void initState() {
    super.initState();

    // Animation for moving stripes
    _stripeAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _stripeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stripeAnimationController,
        curve: Curves.easeOut,
      ),
    );

    // Animation for progress value changes
    _progressAnimationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Initialize with the initial progress value
    _currentProgress = widget.progress;
    _progressAnimation =
        Tween<double>(begin: _currentProgress, end: widget.progress).animate(
          CurvedAnimation(
            parent: _progressAnimationController,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void didUpdateWidget(StripedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animate to new progress value when it changes
    if (oldWidget.progress != widget.progress) {
      _animateToNewProgress(widget.progress);
    }

    // Update animation duration if it changed
    if (oldWidget.animationDuration != widget.animationDuration) {
      _progressAnimationController.duration = widget.animationDuration;
    }
  }

  void _animateToNewProgress(double newProgress) {
    _progressAnimation =
        Tween<double>(begin: _currentProgress, end: newProgress).animate(
          CurvedAnimation(
            parent: _progressAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    _progressAnimationController.reset();
    _progressAnimationController.forward().then((_) {
      _currentProgress = newProgress;
    });
  }

  @override
  void dispose() {
    _stripeAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
      ),
      child: ClipRRect(
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(widget.height / 2),
        child: AnimatedBuilder(
          animation: Listenable.merge([_stripeAnimation, _progressAnimation]),
          builder: (context, child) {
            return CustomPaint(
              size: Size(double.infinity, widget.height),
              painter: StripedProgressPainter(
                progress: _progressAnimation.value,
                progressColor: widget.progressColor,
                stripeColor: widget.stripeColor,
                stripeWidth: widget.stripeWidth,
                animationValue: _stripeAnimation.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class StripedProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color stripeColor;
  final double stripeWidth;
  final double animationValue;

  StripedProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.stripeColor,
    required this.stripeWidth,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final progressWidth = size.width * progress;

    // Draw the progress background
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, progressWidth, size.height),
      progressPaint,
    );

    // Draw the animated stripes
    if (progressWidth > 0) {
      final stripePaint = Paint()
        ..color = stripeColor
        ..style = PaintingStyle.fill;

      final stripeSpacing = stripeWidth * 2;
      final animationOffset = animationValue * stripeSpacing;

      // Create clipping region for progress area
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, progressWidth, size.height));

      for (
        double x = -stripeSpacing + animationOffset;
        x < progressWidth + stripeSpacing;
        x += stripeSpacing
      ) {
        final path = Path();
        path.moveTo(x, 0);
        path.lineTo(x + stripeWidth, 0);
        path.lineTo(x + stripeWidth + (size.height * 0.5), size.height);
        path.lineTo(x + (size.height * 0.5), size.height);
        path.close();

        canvas.drawPath(path, stripePaint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(StripedProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.animationValue != animationValue;
  }
}

// Alternative simpler implementation using LinearProgressIndicator
class SimpleStripedProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color backgroundColor;
  final Color progressColor;

  const SimpleStripedProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.backgroundColor = const Color(0xFF2A2A2A),
    this.progressColor = const Color(0xFF4F46E5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          minHeight: height,
        ),
      ),
    );
  }
}

// Usage example with animated progress
class ProgressExample extends StatefulWidget {
  const ProgressExample({super.key});

  @override
  State<ProgressExample> createState() => _ProgressExampleState();
}

class _ProgressExampleState extends State<ProgressExample> {
  double _progress = 0.83;
  int _completedTasks = 10;
  final int _totalTasks = 12;

  void _completeTask() {
    if (_completedTasks < _totalTasks) {
      setState(() {
        _completedTasks++;
        _progress = _completedTasks / _totalTasks;
      });
    }
  }

  void _resetProgress() {
    setState(() {
      _completedTasks = 0;
      _progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F2937),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's progress",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "$_completedTasks/$_totalTasks Tasks",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress percentage
              Text(
                "${(_progress * 100).toInt()}%",
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 20),

              // Animated striped progress bar
              StripedProgressBar(
                progress: _progress,
                height: 8,
                backgroundColor: const Color(0xFF374151),
                progressColor: const Color(0xFF4F46E5),
                stripeColor: const Color(0xFF6366F1),
                animationDuration: const Duration(milliseconds: 1000),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _completedTasks < _totalTasks
                          ? _completeTask
                          : null,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text("Complete Task"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _resetProgress,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Reset"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9CA3AF),
                      side: const BorderSide(color: Color(0xFF374151)),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Demo with different animation speeds
              const Text(
                "Different animation speeds:",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),

              Column(
                children: [
                  Row(
                    children: [
                      const Text(
                        "Fast (300ms): ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Expanded(
                        child: StripedProgressBar(
                          progress: _progress,
                          height: 6,
                          backgroundColor: const Color(0xFF374151),
                          progressColor: const Color(0xFF10B981),
                          stripeColor: const Color(0xFF34D399),
                          animationDuration: const Duration(milliseconds: 300),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        "Slow (2000ms): ",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      Expanded(
                        child: StripedProgressBar(
                          progress: _progress,
                          height: 6,
                          backgroundColor: const Color(0xFF374151),
                          progressColor: const Color(0xFFF59E0B),
                          stripeColor: const Color(0xFFFBBF24),
                          animationDuration: const Duration(milliseconds: 2000),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
