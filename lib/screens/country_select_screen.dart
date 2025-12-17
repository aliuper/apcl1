import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/iptv_service.dart';
import '../models/iptv_models.dart';

class CountrySelectScreen extends StatelessWidget {
  const CountrySelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context),
      body: Consumer<IPTVService>(
        builder: (context, service, _) {
          final countries = service.detectedCountries.toList();
          countries.sort();
          
          return Column(
            children: [
              // Info Card
              _buildInfoCard()
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              
              // Quick Actions
              _buildQuickActions(context, service)
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 400.ms),
              
              // Countries Grid
              Expanded(
                child: _buildCountriesGrid(countries, service),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
      title: const Text('Ülke Seçimi'),
      centerTitle: true,
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.secondaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.flag_rounded,
                color: AppTheme.secondaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Sadece seçtiğiniz ülkelerin kanalları yeni playlist\'e eklenecek.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary.withOpacity(0.9),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, IPTVService service) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionButton(
              'Tümünü Seç',
              Icons.select_all_rounded,
              AppTheme.primaryColor,
              () => service.selectAllCountries(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionButton(
              'Seçimi Kaldır',
              Icons.deselect_rounded,
              AppTheme.textSecondary,
              () => service.deselectAllCountries(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountriesGrid(List<String> countryCodes, IPTVService service) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: countryCodes.length,
      itemBuilder: (context, index) {
        final code = countryCodes[index];
        final country = Country.all[code];
        final isSelected = service.selectedCountries.contains(code);
        
        return _buildCountryCard(
          code,
          country?.name ?? code,
          country?.flagEmoji ?? '🌍',
          isSelected,
          () => service.toggleCountrySelection(code),
        ).animate(delay: Duration(milliseconds: 30 * (index % 10)))
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.95, 0.95));
      },
    );
  }

  Widget _buildCountryCard(
    String code,
    String name,
    String flag,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor.withOpacity(0.15) 
                : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryColor.withOpacity(0.5) 
                  : AppTheme.cardColorLight.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              // Flag
              Text(
                flag,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 12),
              
              // Name and Code
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected 
                            ? AppTheme.primaryColor 
                            : AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      code,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textHint.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Check indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.textHint.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Consumer<IPTVService>(
      builder: (context, service, _) {
        final hasSelection = service.selectedCountries.isNotEmpty;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: hasSelection 
                    ? () {
                        service.filterByCountries();
                        Navigator.pushNamed(context, '/export');
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSelection 
                      ? AppTheme.secondaryColor 
                      : AppTheme.cardColorLight,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.cardColorLight,
                  disabledForegroundColor: AppTheme.textHint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: hasSelection ? 4 : 0,
                  shadowColor: AppTheme.secondaryColor.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.filter_alt_rounded,
                      size: 22,
                      color: hasSelection ? Colors.white : AppTheme.textHint,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      hasSelection 
                          ? 'Filtrele ve Devam Et (${service.selectedCountries.length})' 
                          : 'Ülke Seçin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: hasSelection ? Colors.white : AppTheme.textHint,
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
