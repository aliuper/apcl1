import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/iptv_service.dart';
import '../widgets/gradient_card.dart';
import '../widgets/mode_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF12121a),
              AppTheme.backgroundColor,
              Color(0xFF0d0d14),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Logo Section
                _buildLogoSection()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.2, end: 0),

                const SizedBox(height: 16),

                // Title
                const Text(
                  'IPTV Group Editor',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                )
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 8),

                Text(
                  'Profesyonel Playlist Düzenleme',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary.withOpacity(0.8),
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 500.ms),

                const Spacer(flex: 2),

                // Mode Cards
                _buildModeCards(context),

                const Spacer(flex: 3),

                // Footer
                _buildFooter()
                    .animate(delay: 800.ms)
                    .fadeIn(duration: 500.ms),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppTheme.primaryColor,
            Color(0xFF8B5CF6),
            AppTheme.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Icon(
        Icons.playlist_play_rounded,
        size: 52,
        color: Colors.white,
      ),
    );
  }

  Widget _buildModeCards(BuildContext context) {
    return Column(
      children: [
        // Manuel Mode Card
        ModeCard(
          icon: Icons.edit_note_rounded,
          title: 'Manuel Düzenleme',
          subtitle: 'Tek link girişi ile detaylı grup seçimi',
          gradientColors: const [
            Color(0xFF6C5CE7),
            Color(0xFF8B5CF6),
          ],
          onTap: () {
            context.read<IPTVService>().reset();
            Navigator.pushNamed(context, '/manual');
          },
        )
            .animate(delay: 400.ms)
            .fadeIn(duration: 500.ms)
            .slideX(begin: -0.2, end: 0),

        const SizedBox(height: 16),

        // Auto Mode Card
        ModeCard(
          icon: Icons.auto_awesome_rounded,
          title: 'Otomatik Düzenleme',
          subtitle: 'Çoklu link & ülke bazlı filtreleme',
          gradientColors: const [
            Color(0xFF00D9FF),
            Color(0xFF00B4DB),
          ],
          onTap: () {
            context.read<IPTVService>().reset();
            Navigator.pushNamed(context, '/auto');
          },
        )
            .animate(delay: 500.ms)
            .fadeIn(duration: 500.ms)
            .slideX(begin: 0.2, end: 0),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFeatureBadge(Icons.speed_rounded, 'Hızlı'),
            const SizedBox(width: 16),
            _buildFeatureBadge(Icons.shield_rounded, 'Güvenli'),
            const SizedBox(width: 16),
            _buildFeatureBadge(Icons.cloud_off_rounded, 'Offline'),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'v2.0.0 • Made with ❤️',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textHint.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.cardColorLight.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
