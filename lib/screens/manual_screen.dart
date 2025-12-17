import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/iptv_service.dart';
import '../widgets/gradient_card.dart';
import '../widgets/custom_button.dart';

class ManualScreen extends StatefulWidget {
  const ManualScreen({super.key});

  @override
  State<ManualScreen> createState() => _ManualScreenState();
}

class _ManualScreenState extends State<ManualScreen> {
  final _linkController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _linkController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _linkController.text = data!.text!;
      setState(() {});
    }
  }

  Future<void> _analyzeLink() async {
    final link = _linkController.text.trim();
    
    if (link.isEmpty) {
      _showSnackBar('Lütfen bir IPTV linki girin', isError: true);
      return;
    }

    if (!_isValidUrl(link)) {
      _showSnackBar('Geçersiz URL formatı', isError: true);
      return;
    }

    setState(() => _isAnalyzing = true);

    final service = context.read<IPTVService>();
    service.setAutoMode(false);
    
    final success = await service.analyzeManualLink(link);

    setState(() => _isAnalyzing = false);

    if (success && mounted) {
      Navigator.pushNamed(context, '/group-select');
    } else if (mounted) {
      _showSnackBar(service.progress.detail ?? 'Analiz başarısız', isError: true);
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppTheme.errorColor : AppTheme.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            _buildInfoCard()
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Link Input Section
            _buildInputSection()
                .animate(delay: 100.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // Features Section
            _buildFeaturesSection()
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 32),

            // Analyze Button
            _buildAnalyzeButton()
                .animate(delay: 300.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_rounded, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text('Manuel Düzenleme'),
      centerTitle: true,
    );
  }

  Widget _buildInfoCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppTheme.primaryColor.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'IPTV linkinizi girin. Sistem otomatik olarak linki test edecek, kanal gruplarını listeleyecek ve seçim yapmanızı sağlayacak.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'IPTV Link',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppTheme.primaryColor
                  : AppTheme.cardColorLight.withOpacity(0.3),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Icon(
                Icons.link_rounded,
                color: AppTheme.textHint.withOpacity(0.6),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _linkController,
                  focusNode: _focusNode,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'M3U/M3U8 link girin...',
                    hintStyle: TextStyle(
                      color: AppTheme.textHint.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.content_paste_rounded,
                  color: AppTheme.primaryColor.withOpacity(0.8),
                ),
                onPressed: _pasteFromClipboard,
                tooltip: 'Yapıştır',
              ),
              if (_linkController.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: AppTheme.textHint.withOpacity(0.6),
                  ),
                  onPressed: () {
                    _linkController.clear();
                    setState(() {});
                  },
                  tooltip: 'Temizle',
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Yapılacak İşlemler',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          Icons.wifi_tethering_rounded,
          'Link bağlantı testi',
          AppTheme.infoColor,
        ),
        _buildFeatureItem(
          Icons.live_tv_rounded,
          'Video akış kontrolü',
          AppTheme.secondaryColor,
        ),
        _buildFeatureItem(
          Icons.folder_rounded,
          'Grup analizi',
          AppTheme.warningColor,
        ),
        _buildFeatureItem(
          Icons.calendar_today_rounded,
          'Bitiş tarihi tespiti',
          AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withOpacity(0.9),
            ),
          ),
          const Spacer(),
          Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: AppTheme.textHint.withOpacity(0.4),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final hasLink = _linkController.text.trim().isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: hasLink && !_isAnalyzing ? _analyzeLink : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasLink ? AppTheme.primaryColor : AppTheme.cardColorLight,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.cardColorLight,
          disabledForegroundColor: AppTheme.textHint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: hasLink ? 4 : 0,
          shadowColor: AppTheme.primaryColor.withOpacity(0.4),
        ),
        child: _isAnalyzing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Analiz Ediliyor...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_arrow_rounded,
                    size: 24,
                    color: hasLink ? Colors.white : AppTheme.textHint,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Analiz Et ve Başlat',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasLink ? Colors.white : AppTheme.textHint,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
