import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/iptv_service.dart';
import '../models/iptv_models.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isExporting = false;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    // İşlemi başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startExport();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startExport() async {
    if (_isExporting) return;
    
    setState(() => _isExporting = true);
    
    final service = context.read<IPTVService>();
    final result = await service.exportPlaylist();
    
    setState(() {
      _isExporting = false;
      _isDone = true;
    });
    
    // Kısa bir bekleme sonrası sonuç ekranına git
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/result');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Geri tuşunu engelle
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Consumer<IPTVService>(
          builder: (context, service, _) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.05),
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      
                      // Animated Progress Indicator
                      _buildAnimatedIndicator(service.progress)
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                      
                      const SizedBox(height: 40),
                      
                      // Status Message
                      _buildStatusMessage(service.progress)
                          .animate(delay: 200.ms)
                          .fadeIn(duration: 400.ms),
                      
                      const SizedBox(height: 32),
                      
                      // Progress Bar
                      _buildProgressBar(service.progress)
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 400.ms),
                      
                      const Spacer(flex: 3),
                      
                      // Info Text
                      _buildInfoText()
                          .animate(delay: 400.ms)
                          .fadeIn(duration: 400.ms),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedIndicator(ProcessingProgress progress) {
    final isCompleted = progress.state == ProcessingState.completed;
    final isError = progress.state == ProcessingState.error;
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            if (!isCompleted && !isError)
              Container(
                width: 160 + (_pulseController.value * 20),
                height: 160 + (_pulseController.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.1 + (_pulseController.value * 0.1)),
                    width: 2,
                  ),
                ),
              ),
            
            // Middle ring
            if (!isCompleted && !isError)
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.15),
                    width: 2,
                  ),
                ),
              ),
            
            // Main circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isCompleted
                      ? [AppTheme.successColor, AppTheme.successColor.withOpacity(0.8)]
                      : isError
                          ? [AppTheme.errorColor, AppTheme.errorColor.withOpacity(0.8)]
                          : [AppTheme.primaryColor, AppTheme.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isCompleted
                            ? AppTheme.successColor
                            : isError
                                ? AppTheme.errorColor
                                : AppTheme.primaryColor)
                        .withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 56,
                        color: Colors.white,
                      ).animate().scale(
                          begin: const Offset(0, 0),
                          end: const Offset(1, 1),
                          duration: 400.ms,
                          curve: Curves.elasticOut,
                        )
                    : isError
                        ? const Icon(
                            Icons.close_rounded,
                            size: 56,
                            color: Colors.white,
                          )
                        : SizedBox(
                            width: 56,
                            height: 56,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusMessage(ProcessingProgress progress) {
    return Column(
      children: [
        Text(
          progress.message,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
      ],
    );
  }

  Widget _buildProgressBar(ProcessingProgress progress) {
    return Column(
      children: [
        // Progress percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress.progress * 100).toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            if (progress.etaText.isNotEmpty)
              Text(
                progress.etaText,
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textHint.withOpacity(0.8),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.cardColorLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.progress),
              duration: const Duration(milliseconds: 300),
              builder: (context, value, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        
        // Current/Total
        if (progress.current != null && progress.total != null) ...[
          const SizedBox(height: 8),
          Text(
            '${progress.current} / ${progress.total}',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textHint.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppTheme.textHint.withOpacity(0.7),
          ),
          const SizedBox(width: 8),
          Text(
            'Lütfen bekleyin, işlem devam ediyor...',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
