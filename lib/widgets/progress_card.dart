import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/iptv_models.dart';

class ProgressCard extends StatelessWidget {
  final ProcessingProgress progress;

  const ProgressCard({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.cardColorLight.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Status Icon
          _buildStatusIcon(),
          const SizedBox(height: 20),

          // Message
          Text(
            progress.message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          if (progress.detail != null) ...[
            const SizedBox(height: 8),
            Text(
              progress.detail!,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 24),

          // Progress Bar
          _buildProgressBar(),

          const SizedBox(height: 16),

          // Progress Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                progress.progressText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              if (progress.etaText.isNotEmpty)
                Text(
                  progress.etaText,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textHint.withOpacity(0.8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;
    bool showPulse = false;

    switch (progress.state) {
      case ProcessingState.idle:
        icon = Icons.hourglass_empty_rounded;
        color = AppTheme.textHint;
        break;
      case ProcessingState.extractingLinks:
        icon = Icons.search_rounded;
        color = AppTheme.infoColor;
        showPulse = true;
        break;
      case ProcessingState.testingLinks:
        icon = Icons.wifi_tethering_rounded;
        color = AppTheme.warningColor;
        showPulse = true;
        break;
      case ProcessingState.parsingPlaylist:
        icon = Icons.playlist_add_check_rounded;
        color = AppTheme.infoColor;
        showPulse = true;
        break;
      case ProcessingState.testingChannels:
        icon = Icons.live_tv_rounded;
        color = AppTheme.secondaryColor;
        showPulse = true;
        break;
      case ProcessingState.filtering:
        icon = Icons.filter_list_rounded;
        color = AppTheme.primaryColor;
        showPulse = true;
        break;
      case ProcessingState.exporting:
        icon = Icons.save_rounded;
        color = AppTheme.primaryColor;
        showPulse = true;
        break;
      case ProcessingState.completed:
        icon = Icons.check_circle_rounded;
        color = AppTheme.successColor;
        break;
      case ProcessingState.error:
        icon = Icons.error_rounded;
        color = AppTheme.errorColor;
        break;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        if (showPulse) _buildPulseEffect(color),
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 32,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildPulseEffect(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.2),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Container(
          width: 64 * value,
          height: 64 * value,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1 / value),
            borderRadius: BorderRadius.circular(20 * value),
          ),
        );
      },
      onEnd: () {},
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.progress,
            minHeight: 8,
            backgroundColor: AppTheme.cardColorLight,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor() {
    switch (progress.state) {
      case ProcessingState.error:
        return AppTheme.errorColor;
      case ProcessingState.completed:
        return AppTheme.successColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}

class AnimatedProgressCard extends StatefulWidget {
  final ProcessingProgress progress;

  const AnimatedProgressCard({
    super.key,
    required this.progress,
  });

  @override
  State<AnimatedProgressCard> createState() => _AnimatedProgressCardState();
}

class _AnimatedProgressCardState extends State<AnimatedProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final isActive = widget.progress.state != ProcessingState.idle &&
            widget.progress.state != ProcessingState.completed &&
            widget.progress.state != ProcessingState.error;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppTheme.primaryColor.withOpacity(0.3 + (_pulseController.value * 0.2))
                  : AppTheme.cardColorLight.withOpacity(0.3),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.1 + (_pulseController.value * 0.1)),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: ProgressCard(progress: widget.progress),
        );
      },
    );
  }
}
