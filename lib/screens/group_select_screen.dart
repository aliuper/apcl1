import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/iptv_service.dart';
import '../models/iptv_models.dart';

class GroupSelectScreen extends StatefulWidget {
  const GroupSelectScreen({super.key});

  @override
  State<GroupSelectScreen> createState() => _GroupSelectScreenState();
}

class _GroupSelectScreenState extends State<GroupSelectScreen> {
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChannelGroup> _getFilteredGroups(List<ChannelGroup> groups) {
    if (_searchQuery.isEmpty) return groups;
    return groups.where((g) => 
      g.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<IPTVService>(
        builder: (context, service, _) {
          final groups = _getFilteredGroups(service.allGroups);
          
          return CustomScrollView(
            slivers: [
              // App Bar
              _buildSliverAppBar(service),
              
              // Stats Bar
              SliverToBoxAdapter(
                child: _buildStatsBar(service)
                    .animate()
                    .fadeIn(duration: 300.ms),
              ),
              
              // Search Bar
              SliverToBoxAdapter(
                child: _buildSearchBar()
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 300.ms),
              ),
              
              // Groups List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final group = groups[index];
                      return _buildGroupItem(group, service, index)
                          .animate(delay: Duration(milliseconds: 50 * (index % 10)))
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.1, end: 0);
                    },
                    childCount: groups.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSliverAppBar(IPTVService service) {
    return SliverAppBar(
      backgroundColor: AppTheme.backgroundColor,
      pinned: true,
      expandedHeight: 60,
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
      title: const Text('Grup Seçimi'),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.select_all_rounded, size: 18),
          ),
          onPressed: () => service.selectAllGroups(),
          tooltip: 'Tümünü Seç',
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.deselect_rounded, size: 18),
          ),
          onPressed: () => service.deselectAllGroups(),
          tooltip: 'Seçimi Kaldır',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStatsBar(IPTVService service) {
    final totalGroups = service.allGroups.length;
    final selectedGroups = service.selectedGroupsCount;
    final selectedChannels = service.selectedChannelsCount;
    final totalChannels = service.allGroups.fold<int>(0, (sum, g) => sum + g.channelCount);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.cardColor,
            AppTheme.cardColorLight.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            selectedGroups.toString(),
            'Seçili Grup',
            AppTheme.primaryColor,
          ),
          _buildStatDivider(),
          _buildStatItem(
            totalGroups.toString(),
            'Toplam Grup',
            AppTheme.textSecondary,
          ),
          _buildStatDivider(),
          _buildStatItem(
            selectedChannels.toString(),
            'Seçili Kanal',
            AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppTheme.cardColorLight.withOpacity(0.5),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.cardColorLight.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(
              Icons.search_rounded,
              color: AppTheme.textHint.withOpacity(0.5),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Grup ara...',
                  hintStyle: TextStyle(
                    color: AppTheme.textHint.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            if (_searchQuery.isNotEmpty)
              IconButton(
                icon: Icon(
                  Icons.clear_rounded,
                  color: AppTheme.textHint.withOpacity(0.5),
                  size: 20,
                ),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupItem(ChannelGroup group, IPTVService service, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => service.toggleGroupSelection(
            service.allGroups.indexOf(group),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: group.isSelected 
                  ? AppTheme.primaryColor.withOpacity(0.1) 
                  : AppTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: group.isSelected 
                    ? AppTheme.primaryColor.withOpacity(0.4) 
                    : AppTheme.cardColorLight.withOpacity(0.2),
                width: group.isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Flag / Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: group.isSelected
                        ? AppTheme.primaryColor.withOpacity(0.2)
                        : AppTheme.cardColorLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      group.flagEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                
                // Group Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: group.isSelected 
                              ? AppTheme.primaryColor 
                              : AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${group.channelCount} kanal',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Checkbox
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: group.isSelected 
                        ? AppTheme.primaryColor 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: group.isSelected 
                          ? AppTheme.primaryColor 
                          : AppTheme.textHint.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: group.isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 18,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Consumer<IPTVService>(
      builder: (context, service, _) {
        final hasSelection = service.selectedGroupsCount > 0;
        
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
                    ? () => Navigator.pushNamed(context, '/export')
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasSelection 
                      ? AppTheme.primaryColor 
                      : AppTheme.cardColorLight,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppTheme.cardColorLight,
                  disabledForegroundColor: AppTheme.textHint,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: hasSelection ? 4 : 0,
                  shadowColor: AppTheme.primaryColor.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.save_rounded,
                      size: 22,
                      color: hasSelection ? Colors.white : AppTheme.textHint,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      hasSelection 
                          ? 'Seçilenleri Kaydet (${service.selectedGroupsCount})' 
                          : 'Grup Seçin',
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
