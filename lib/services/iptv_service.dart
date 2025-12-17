import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/iptv_models.dart';

class IPTVService extends ChangeNotifier {
  // Dio HTTP client
  late Dio _dio;
  
  // State
  ProcessingProgress _progress = ProcessingProgress(
    state: ProcessingState.idle,
    progress: 0,
    message: '',
  );
  
  List<IPTVPlaylist> _playlists = [];
  List<ChannelGroup> _allGroups = [];
  Set<String> _detectedCountries = {};
  Set<String> _selectedCountries = {};
  bool _mergeFiles = true;
  ExportFormat _exportFormat = ExportFormat.m3u;
  String? _lastExportPath;
  DateTime? _globalExpiryDate;
  
  // Mode
  bool _isAutoMode = false;
  
  // Getters
  ProcessingProgress get progress => _progress;
  List<IPTVPlaylist> get playlists => _playlists;
  List<ChannelGroup> get allGroups => _allGroups;
  Set<String> get detectedCountries => _detectedCountries;
  Set<String> get selectedCountries => _selectedCountries;
  bool get mergeFiles => _mergeFiles;
  ExportFormat get exportFormat => _exportFormat;
  String? get lastExportPath => _lastExportPath;
  DateTime? get globalExpiryDate => _globalExpiryDate;
  bool get isAutoMode => _isAutoMode;
  
  int get selectedGroupsCount => _allGroups.where((g) => g.isSelected).length;
  int get selectedChannelsCount {
    int count = 0;
    for (final g in _allGroups.where((g) => g.isSelected)) {
      count += g.channels.length;
    }
    return count;
  }
  
  IPTVService() {
    _initDio();
  }
  
  void _initDio() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      followRedirects: true,
      maxRedirects: 5,
      validateStatus: (status) => status != null && status < 500,
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
        'Accept': '*/*',
      },
    ));
  }
  
  // Setters
  void setMergeFiles(bool value) {
    _mergeFiles = value;
    notifyListeners();
  }
  
  void setExportFormat(ExportFormat format) {
    _exportFormat = format;
    notifyListeners();
  }
  
  void setAutoMode(bool value) {
    _isAutoMode = value;
    notifyListeners();
  }
  
  void toggleGroupSelection(int index) {
    if (index >= 0 && index < _allGroups.length) {
      _allGroups[index].isSelected = !_allGroups[index].isSelected;
      notifyListeners();
    }
  }
  
  void selectAllGroups() {
    for (final group in _allGroups) {
      group.isSelected = true;
    }
    notifyListeners();
  }
  
  void deselectAllGroups() {
    for (final group in _allGroups) {
      group.isSelected = false;
    }
    notifyListeners();
  }
  
  void toggleCountrySelection(String code) {
    if (_selectedCountries.contains(code)) {
      _selectedCountries.remove(code);
    } else {
      _selectedCountries.add(code);
    }
    notifyListeners();
  }
  
  void selectAllCountries() {
    _selectedCountries = Set.from(_detectedCountries);
    notifyListeners();
  }
  
  void deselectAllCountries() {
    _selectedCountries.clear();
    notifyListeners();
  }
  
  void _updateProgress(ProcessingProgress p) {
    _progress = p;
    notifyListeners();
  }
  
  void reset() {
    _progress = ProcessingProgress(
      state: ProcessingState.idle,
      progress: 0,
      message: '',
    );
    _playlists.clear();
    _allGroups.clear();
    _detectedCountries.clear();
    _selectedCountries.clear();
    _globalExpiryDate = null;
    notifyListeners();
  }
  
  /// Metinden IPTV linklerini çıkar
  List<String> extractLinksFromText(String text) {
    final links = <String>[];
    
    // M3U/M3U8 URL pattern
    final urlPattern = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+\.m3u8?(?:\?[^\s<>"{}|\\^`\[\]]*)?',
      caseSensitive: false,
    );
    
    // Genel URL pattern (get.php, playlist, iptv içerenler)
    final generalPattern = RegExp(
      r'https?://[^\s<>"{}|\\^`\[\]]+(?:get\.php|playlist|iptv|m3u)[^\s<>"{}|\\^`\[\]]*',
      caseSensitive: false,
    );
    
    // DNS/port bazlı URL pattern
    final dnsPattern = RegExp(
      r'https?://(?:\d{1,3}\.){3}\d{1,3}(?::\d+)?/[^\s<>"{}|\\^`\[\]]+',
      caseSensitive: false,
    );
    
    for (final match in urlPattern.allMatches(text)) {
      final url = match.group(0)!.trim();
      if (!links.contains(url)) {
        links.add(url);
      }
    }
    
    for (final match in generalPattern.allMatches(text)) {
      final url = match.group(0)!.trim();
      if (!links.contains(url)) {
        links.add(url);
      }
    }
    
    for (final match in dnsPattern.allMatches(text)) {
      final url = match.group(0)!.trim();
      if (!links.contains(url) && _looksLikeIPTV(url)) {
        links.add(url);
      }
    }
    
    return links;
  }
  
  bool _looksLikeIPTV(String url) {
    final lower = url.toLowerCase();
    return lower.contains('m3u') ||
           lower.contains('playlist') ||
           lower.contains('get.php') ||
           lower.contains('iptv') ||
           lower.contains('live') ||
           lower.contains('stream') ||
           lower.contains('type=m3u');
  }
  
  /// Tek link analiz et (Manuel mod)
  Future<bool> analyzeManualLink(String url) async {
    reset();
    _isAutoMode = false;
    
    _updateProgress(ProcessingProgress(
      state: ProcessingState.testingLinks,
      progress: 0.1,
      message: 'Link test ediliyor...',
      detail: url,
    ));
    
    try {
      // Link'i test et
      final testResult = await _testLink(url);
      
      if (!testResult.isWorking) {
        _updateProgress(ProcessingProgress(
          state: ProcessingState.error,
          progress: 0,
          message: 'Link çalışmıyor!',
          detail: testResult.error ?? 'Bağlantı kurulamadı',
        ));
        return false;
      }
      
      _globalExpiryDate = testResult.expiryDate;
      
      _updateProgress(ProcessingProgress(
        state: ProcessingState.parsingPlaylist,
        progress: 0.3,
        message: 'Playlist analiz ediliyor...',
      ));
      
      // Playlist'i parse et
      final playlist = await _parsePlaylist(url);
      
      if (playlist == null || playlist.channels.isEmpty) {
        _updateProgress(ProcessingProgress(
          state: ProcessingState.error,
          progress: 0,
          message: 'Playlist boş veya geçersiz!',
        ));
        return false;
      }
      
      _playlists.add(playlist);
      _allGroups = playlist.groups;
      
      // Birkaç kanal test et
      _updateProgress(ProcessingProgress(
        state: ProcessingState.testingChannels,
        progress: 0.6,
        message: 'Kanallar test ediliyor...',
        detail: 'Video akışı kontrol ediliyor',
      ));
      
      final channelTestResult = await _testSampleChannels(playlist.channels);
      
      if (!channelTestResult) {
        _updateProgress(ProcessingProgress(
          state: ProcessingState.error,
          progress: 0,
          message: 'Kanallardan video akışı alınamadı!',
        ));
        return false;
      }
      
      _updateProgress(ProcessingProgress(
        state: ProcessingState.completed,
        progress: 1.0,
        message: 'Analiz tamamlandı!',
        detail: '${playlist.totalGroups} grup, ${playlist.totalChannels} kanal bulundu',
      ));
      
      return true;
      
    } catch (e) {
      _updateProgress(ProcessingProgress(
        state: ProcessingState.error,
        progress: 0,
        message: 'Hata oluştu!',
        detail: e.toString(),
      ));
      return false;
    }
  }
  
  /// Çoklu link analiz et (Otomatik mod)
  Future<bool> analyzeAutoLinks(String text) async {
    reset();
    _isAutoMode = true;
    
    _updateProgress(ProcessingProgress(
      state: ProcessingState.extractingLinks,
      progress: 0.05,
      message: 'Linkler ayıklanıyor...',
    ));
    
    // Linkleri çıkar
    final links = extractLinksFromText(text);
    
    if (links.isEmpty) {
      _updateProgress(ProcessingProgress(
        state: ProcessingState.error,
        progress: 0,
        message: 'Hiç IPTV linki bulunamadı!',
        detail: 'Lütfen geçerli M3U/M3U8 linkleri girin',
      ));
      return false;
    }
    
    _updateProgress(ProcessingProgress(
      state: ProcessingState.testingLinks,
      progress: 0.1,
      message: '${links.length} link bulundu, test ediliyor...',
      current: 0,
      total: links.length,
    ));
    
    final workingPlaylists = <IPTVPlaylist>[];
    final startTime = DateTime.now();
    
    // Linkleri test et ve parse et
    for (int i = 0; i < links.length; i++) {
      final url = links[i];
      
      final elapsed = DateTime.now().difference(startTime);
      final avgTimePerLink = i > 0 ? elapsed.inMilliseconds / i : 5000;
      final remaining = Duration(milliseconds: ((links.length - i) * avgTimePerLink).toInt());
      
      _updateProgress(ProcessingProgress(
        state: ProcessingState.testingLinks,
        progress: 0.1 + (0.4 * i / links.length),
        message: 'Linkler test ediliyor...',
        detail: 'Link ${i + 1}/${links.length}',
        current: i + 1,
        total: links.length,
        estimatedTimeRemaining: remaining,
      ));
      
      try {
        final testResult = await _testLink(url);
        
        if (testResult.isWorking) {
          final playlist = await _parsePlaylist(url);
          
          if (playlist != null && playlist.channels.isNotEmpty) {
            // Bitiş tarihini güncelle
            if (testResult.expiryDate != null) {
              if (_globalExpiryDate == null || testResult.expiryDate!.isAfter(_globalExpiryDate!)) {
                _globalExpiryDate = testResult.expiryDate;
              }
            }
            
            workingPlaylists.add(playlist);
          }
        }
      } catch (e) {
        // Hata olan linki atla, devam et
        debugPrint('Link hata: $url - $e');
      }
    }
    
    if (workingPlaylists.isEmpty) {
      _updateProgress(ProcessingProgress(
        state: ProcessingState.error,
        progress: 0,
        message: 'Çalışan playlist bulunamadı!',
        detail: 'Tüm linkler geçersiz veya erişilemez',
      ));
      return false;
    }
    
    _playlists = workingPlaylists;
    
    // Tüm grupları birleştir ve ülkeleri tespit et
    _updateProgress(ProcessingProgress(
      state: ProcessingState.filtering,
      progress: 0.7,
      message: 'Gruplar analiz ediliyor...',
    ));
    
    final allGroupsMap = <String, ChannelGroup>{};
    
    for (final playlist in _playlists) {
      for (final group in playlist.groups) {
        final key = group.name.toLowerCase().trim();
        if (allGroupsMap.containsKey(key)) {
          // Kanalları birleştir
          allGroupsMap[key]!.channels.addAll(group.channels);
        } else {
          allGroupsMap[key] = ChannelGroup(
            name: group.name,
            channels: List.from(group.channels),
            countryCode: group.countryCode,
          );
        }
        
        // Ülke kodunu ekle
        if (group.countryCode != null) {
          _detectedCountries.add(group.countryCode!);
        }
      }
    }
    
    _allGroups = allGroupsMap.values.toList();
    _allGroups.sort((a, b) => a.name.compareTo(b.name));
    
    _updateProgress(ProcessingProgress(
      state: ProcessingState.completed,
      progress: 1.0,
      message: 'Analiz tamamlandı!',
      detail: '${_playlists.length} çalışan playlist, ${_allGroups.length} grup, ${_detectedCountries.length} ülke',
    ));
    
    return true;
  }
  
  /// Ülkelere göre filtrele
  void filterByCountries() {
    for (final group in _allGroups) {
      if (group.countryCode != null && _selectedCountries.contains(group.countryCode)) {
        group.isSelected = true;
      } else if (group.countryCode == null) {
        // Ülkesi belirsiz grupları dahil etme
        group.isSelected = false;
      } else {
        group.isSelected = false;
      }
    }
    notifyListeners();
  }
  
  /// Link test et
  Future<TestResult> _testLink(String url) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      stopwatch.stop();
      
      if (response.statusCode == 200) {
        // Bitiş tarihini kontrol et
        DateTime? expiryDate;
        
        // URL'den exp parametresini kontrol et
        final uri = Uri.parse(url);
        final expParam = uri.queryParameters['exp'];
        if (expParam != null) {
          try {
            final expTimestamp = int.parse(expParam);
            expiryDate = DateTime.fromMillisecondsSinceEpoch(expTimestamp * 1000);
          } catch (_) {}
        }
        
        return TestResult(
          url: url,
          isWorking: true,
          responseTime: stopwatch.elapsedMilliseconds,
          contentType: response.headers.value('content-type'),
          expiryDate: expiryDate,
        );
      }
      
      return TestResult(
        url: url,
        isWorking: false,
        responseTime: stopwatch.elapsedMilliseconds,
        error: 'HTTP ${response.statusCode}',
      );
      
    } on DioException catch (e) {
      stopwatch.stop();
      return TestResult(
        url: url,
        isWorking: false,
        responseTime: stopwatch.elapsedMilliseconds,
        error: e.message ?? 'Bağlantı hatası',
      );
    } catch (e) {
      stopwatch.stop();
      return TestResult(
        url: url,
        isWorking: false,
        responseTime: stopwatch.elapsedMilliseconds,
        error: e.toString(),
      );
    }
  }
  
  /// Playlist parse et
  Future<IPTVPlaylist?> _parsePlaylist(String url) async {
    try {
      final response = await _dio.get(url);
      
      if (response.statusCode != 200) return null;
      
      final content = response.data.toString();
      
      if (!content.contains('#EXTM3U')) return null;
      
      final channels = <Channel>[];
      final groupsMap = <String, List<Channel>>{};
      
      final lines = content.split('\n');
      String? currentExtinf;
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        
        if (line.startsWith('#EXTINF:')) {
          currentExtinf = line;
        } else if (currentExtinf != null && line.isNotEmpty && !line.startsWith('#')) {
          // Kanal oluştur
          final channel = Channel.fromM3ULine(currentExtinf, line);
          channels.add(channel);
          
          // Gruba ekle
          if (!groupsMap.containsKey(channel.groupTitle)) {
            groupsMap[channel.groupTitle] = [];
          }
          groupsMap[channel.groupTitle]!.add(channel);
          
          currentExtinf = null;
        }
      }
      
      // Grupları oluştur
      final groups = groupsMap.entries.map((entry) {
        final countryCode = ChannelGroup.extractCountryCode(entry.key);
        return ChannelGroup(
          name: entry.key,
          channels: entry.value,
          countryCode: countryCode,
        );
      }).toList();
      
      // İsimlere göre sırala
      groups.sort((a, b) => a.name.compareTo(b.name));
      
      return IPTVPlaylist(
        sourceUrl: url,
        channels: channels,
        groups: groups,
      );
      
    } catch (e) {
      debugPrint('Parse error: $e');
      return null;
    }
  }
  
  /// Örnek kanalları test et
  Future<bool> _testSampleChannels(List<Channel> channels) async {
    if (channels.isEmpty) return false;
    
    // Rastgele 3 kanal seç
    final random = Random();
    final sampleSize = min(3, channels.length);
    final sampleIndices = <int>{};
    
    while (sampleIndices.length < sampleSize) {
      sampleIndices.add(random.nextInt(channels.length));
    }
    
    int workingCount = 0;
    
    for (final index in sampleIndices) {
      try {
        final channel = channels[index];
        final response = await _dio.head(
          channel.url,
          options: Options(
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        
        if (response.statusCode == 200) {
          workingCount++;
        }
      } catch (_) {
        // Hata olsa bile devam et
      }
    }
    
    // En az 1 kanal çalışıyorsa OK
    return workingCount > 0;
  }
  
  /// Playlist'i dışa aktar
  Future<String?> exportPlaylist() async {
    try {
      _updateProgress(ProcessingProgress(
        state: ProcessingState.exporting,
        progress: 0.5,
        message: 'Dosya oluşturuluyor...',
      ));
      
      final selectedGroups = _allGroups.where((g) => g.isSelected).toList();
      
      if (selectedGroups.isEmpty) {
        _updateProgress(ProcessingProgress(
          state: ProcessingState.error,
          progress: 0,
          message: 'Hiç grup seçilmedi!',
        ));
        return null;
      }
      
      // İçerik oluştur
      String content;
      switch (_exportFormat) {
        case ExportFormat.m3u:
          content = _generateM3UContent(selectedGroups);
          break;
        case ExportFormat.m3u8:
          content = _generateM3U8Content(selectedGroups);
          break;
        case ExportFormat.m3u8plus:
          content = _generateM3U8PlusContent(selectedGroups);
          break;
      }
      
      // Dosya adı oluştur
      final fileName = _generateFileName();
      
      // Kaydet
      final directory = await _getExportDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content, encoding: utf8);
      
      _lastExportPath = file.path;
      
      _updateProgress(ProcessingProgress(
        state: ProcessingState.completed,
        progress: 1.0,
        message: 'Dışa aktarma tamamlandı!',
        detail: fileName,
      ));
      
      return file.path;
      
    } catch (e) {
      _updateProgress(ProcessingProgress(
        state: ProcessingState.error,
        progress: 0,
        message: 'Dışa aktarma hatası!',
        detail: e.toString(),
      ));
      return null;
    }
  }
  
  String _generateM3UContent(List<ChannelGroup> groups) {
    final buffer = StringBuffer('#EXTM3U\n');
    
    for (final group in groups) {
      for (final channel in group.channels) {
        buffer.writeln(channel.toM3U());
      }
    }
    
    return buffer.toString();
  }
  
  String _generateM3U8Content(List<ChannelGroup> groups) {
    // M3U8 = M3U with UTF-8 encoding (aynı format)
    return _generateM3UContent(groups);
  }
  
  String _generateM3U8PlusContent(List<ChannelGroup> groups) {
    final buffer = StringBuffer('#EXTM3U');
    buffer.write(' x-tvg-url=""');
    buffer.write(' url-tvg=""');
    buffer.writeln();
    
    for (final group in groups) {
      for (final channel in group.channels) {
        buffer.writeln(channel.toM3U());
      }
    }
    
    return buffer.toString();
  }
  
  String _generateFileName() {
    final now = DateTime.now();
    final dateFormat = DateFormat('ddMMyyyy');
    final todayStr = dateFormat.format(now);
    
    // Bitiş tarihi
    String expiryStr = '';
    if (_globalExpiryDate != null) {
      expiryStr = '_${dateFormat.format(_globalExpiryDate!)}';
    }
    
    // Versiyon numarası için dosya sayısını kontrol et
    // Bu basitleştirilmiş versiyon - her seferinde v1 kullanır
    // Gerçek implementasyonda aynı gündeki dosya sayısını kontrol etmeli
    final version = 1;
    
    return '${todayStr}_iptv_v$version$expiryStr${_exportFormat.extension}';
  }
  
  Future<Directory> _getExportDirectory() async {
    Directory? directory;
    
    if (Platform.isAndroid) {
      // Android Downloads/IPTV klasörü
      directory = Directory('/storage/emulated/0/Download/IPTV_Dosyalari');
    } else {
      // Diğer platformlar için documents
      final docs = await getApplicationDocumentsDirectory();
      directory = Directory('${docs.path}/IPTV_Dosyalari');
    }
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory;
  }
}
