import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/iptv_service.dart';
import '../models/iptv_models.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goHome(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Consumer<IPTVService>(
          builder: (context, service, _) {
            final isSuccess = service.progress.state == ProcessingState.completed;
            
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.5,
                  colors: [
                    (isSuccess ? AppTheme.successColor : AppTheme.errorColor)
                        .withOpacity(0.08),
                    AppTheme.backgroundColor,
                  ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      
                      // Result Icon
                      _buildResultIcon(isSuccess)
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            end: const Offset(1, 1),
                            curve: Curves.elasticOut,
                            duration: 800.ms,
                          ),
                      
                      const SizedBox(height: 32),
                      
                      // Title
                      Text(
                        isSuccess ? 'Başarıyla Tamamlandı!' : 'İşlem Başarısız',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isSuccess 
                              ? AppTheme.successColor 
                              : AppTheme.errorColor,
                        ),
                      )
                          .animate(delay: 300.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),
                      
                      const SizedBox(height: 12),
                      
                      // Subtitle
                      Text(
                        isSuccess
                            ? 'Playlist dosyanız oluşturuldu'
                            : service.progress.detail ?? 'Bir hata oluştu',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate(delay: 400.ms)
                          .fadeIn(duration: 400.ms),
                      
                      const SizedBox(height: 32),
                      
                      // File Info Card (sadece başarılıysa)
                      if (isSuccess && service.lastExportPath != null)
                        _buildFileInfoCard(service)
                            .animate(delay: 500.ms)
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: 0.1, end: 0),
                      
                      const Spacer(flex: 3),
                      
                      // Action Buttons
                      _buildActionButtons(context, isSuccess)
                          .animate(delay: 600.ms)
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: 0.1, end: 0),
                      
                      const SizedBox(height: 16),
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

  Widget _buildResultIcon(bool isSuccess) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (isSuccess ? AppTheme.successColor : AppTheme.errorColor)
                    .withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        
        // Main circle
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: isSuccess
                  ? [AppTheme.successColor, const Color(0xFF22C55E)]
                  : [AppTheme.errorColor, const Color(0xFFDC2626)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Icon(
            isSuccess ? Icons.check_rounded : Icons.close_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildFileInfoCard(IPTVService service) {
    final filePath = service.lastExportPath!;
    final fileName = filePath.split('/').last;
    final folderPath = filePath.substring(0, filePath.lastIndexOf('/'));
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.insert_drive_file_rounded,
                  color: AppTheme.successColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dosya Oluşturuldu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHint.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          const Divider(color: AppTheme.cardColorLight),
          const SizedBox(height: 16),
          
          // File Name
          _buildInfoRow(
            Icons.description_rounded,
            'Dosya Adı',
            fileName,
          ),
          const SizedBox(height: 12),
          
          // Folder Path
          _buildInfoRow(
            Icons.folder_rounded,
            'Konum',
            folderPath,
          ),
          
          const SizedBox(height: 16),
          
          // Stats Row
          Row(
            children: [
              _buildStatChip(
                Icons.folder_rounded,
                '${service.selectedGroupsCount} grup',
                AppTheme.primaryColor,
              ),
              const SizedBox(width: 10),
              _buildStatChip(
                Icons.tv_rounded,
                '${service.selectedChannelsCount} kanal',
                AppTheme.secondaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: AppTheme.textHint.withOpacity(0.6),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textHint.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isSuccess) {
    return Column(
      children: [
        // Primary Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => _goHome(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess 
                  ? AppTheme.primaryColor 
                  : AppTheme.cardColorLight,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: isSuccess ? 4 : 0,
              shadowColor: AppTheme.primaryColor.withOpacity(0.4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSuccess ? Icons.add_rounded : Icons.refresh_rounded,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  isSuccess ? 'Yeni İşlem' : 'Tekrar Dene',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (isSuccess) ...[
          const SizedBox(height: 12),
          
          // Secondary Button - Open Folder
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => _showSnackBar(context, 'Dosya yöneticisinde açılıyor...'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
                side: BorderSide(
                  color: AppTheme.cardColorLight.withOpacity(0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.folder_open_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Klasörü Aç',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
