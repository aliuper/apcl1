import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/iptv_service.dart';
import '../widgets/gradient_card.dart';

class AutoScreen extends StatefulWidget {
  const AutoScreen({super.key});

  @override
  State<AutoScreen> createState() => _AutoScreenState();
}

class _AutoScreenState extends State<AutoScreen> {
  final _linksController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isAnalyzing = false;
  bool _mergeFiles = true;
  int _detectedLinkCount = 0;

  @override
  void initState() {
    super.initState();
    _linksController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _linksController.removeListener(_onTextChanged);
    _linksController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _linksController.text;
    final service = context.read<IPTVService>();
    final links = service.extractLinksFromText(text);
    setState(() {
      _detectedLinkCount = links.length;
    });
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      _linksController.text = data!.text!;
    }
  }

  Future<void> _analyzeLinks() async {
    final text = _linksController.text.trim();
    
    if (text.isEmpty) {
      _showSnackBar('Lütfen IPTV linkleri veya metin girin', isError: true);
      return;
    }

    setState(() => _isAnalyzing = true);

    final service = context.read<IPTVService>();
    service.setAutoMode(true);
    service.setMergeFiles(_mergeFiles);
    
    final success = await service.analyzeAutoLinks(text);

    setState(() => _isAnalyzing = false);

    if (success && mounted) {
      // Ülke seçim ekranına git
      Navigator.pushNamed(context, '/country-select');
    } else if (mounted) {
      _showSnackBar(service.progress.detail ?? 'Analiz başarısız', isError: true);
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

            // Links Input Section
            _buildInputSection()
                .animate(delay: 100.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 16),

            // Detected Links Badge
            if (_detectedLinkCount > 0) _buildDetectedBadge(),

            const SizedBox(height: 20),

            // Options Section
            _buildOptionsSection()
                .animate(delay: 200.ms)
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),

            const SizedBox(height: 24),

            // How It Works Section
            _buildHowItWorksSection()
                .animate(delay: 250.ms)
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
      title: const Text('Otomatik Düzenleme'),
      centerTitle: true,
    );
  }

  Widget _buildInfoCard() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppTheme.secondaryColor.withOpacity(0.3),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.secondaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Karışık metin veya çoklu linkler girin. Sistem otomatik olarak IPTV linklerini bulacak, test edecek ve ülke bazlı filtreleme yapacak.',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'IPTV Linkleri',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton.icon(
              onPressed: _pasteFromClipboard,
              icon: const Icon(Icons.content_paste_rounded, size: 18),
              label: const Text('Yapıştır'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppTheme.secondaryColor
                  : AppTheme.cardColorLight.withOpacity(0.3),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: _linksController,
            focusNode: _focusNode,
            maxLines: null,
            expands: true,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
            decoration: InputDecoration(
              hintText: 'Linkleri buraya girin veya yapıştırın...\n\nÖrnek:\nhttp://example.com/get.php?username=xxx&password=xxx&type=m3u_plus\n\nVeya karışık metin içinde linkler olabilir.',
              hintStyle: TextStyle(
                color: AppTheme.textHint.withOpacity(0.4),
                fontSize: 13,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetectedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.successColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppTheme.successColor,
          ),
          const SizedBox(width: 8),
          Text(
            '$_detectedLinkCount link tespit edildi',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildOptionsSection() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tek Dosyada Birleştir',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tüm linkleri tek playlist\'te topla',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 1.1,
            child: Switch(
              value: _mergeFiles,
              onChanged: (value) => setState(() => _mergeFiles = value),
              activeColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nasıl Çalışır?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 12),
        _buildStepItem(1, 'Linkler otomatik bulunur', Icons.search_rounded),
        _buildStepItem(2, 'Her link test edilir', Icons.wifi_tethering_rounded),
        _buildStepItem(3, 'Ülke seçimi yapılır', Icons.flag_rounded),
        _buildStepItem(4, 'Filtrelenmiş dosya oluşturulur', Icons.file_download_rounded),
      ],
    );
  }

  Widget _buildStepItem(int step, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withOpacity(0.8),
                  AppTheme.secondaryColor.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$step',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            size: 18,
            color: AppTheme.textSecondary.withOpacity(0.6),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    final hasContent = _linksController.text.trim().isNotEmpty;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: hasContent && !_isAnalyzing ? _analyzeLinks : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasContent ? AppTheme.secondaryColor : AppTheme.cardColorLight,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.cardColorLight,
          disabledForegroundColor: AppTheme.textHint,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: hasContent ? 4 : 0,
          shadowColor: AppTheme.secondaryColor.withOpacity(0.4),
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
                    Icons.auto_fix_high_rounded,
                    size: 24,
                    color: hasContent ? Colors.white : AppTheme.textHint,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Linkleri Bul ve Analiz Et',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: hasContent ? Colors.white : AppTheme.textHint,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
