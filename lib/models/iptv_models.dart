import 'package:flutter/material.dart';

/// Tek bir IPTV kanalı
class Channel {
  final String name;
  final String url;
  final String groupTitle;
  final String? logo;
  final String? tvgId;
  final String? tvgName;
  final Map<String, String> attributes;

  Channel({
    required this.name,
    required this.url,
    required this.groupTitle,
    this.logo,
    this.tvgId,
    this.tvgName,
    this.attributes = const {},
  });

  /// M3U satırından channel oluştur
  factory Channel.fromM3ULine(String extinf, String url) {
    final attributes = <String, String>{};
    String name = '';
    String groupTitle = 'Uncategorized';
    String? logo;
    String? tvgId;
    String? tvgName;

    // Attribute'ları parse et
    final attrRegex = RegExp(r'(\w+(?:-\w+)?)="([^"]*)"');
    for (final match in attrRegex.allMatches(extinf)) {
      final key = match.group(1)!.toLowerCase();
      final value = match.group(2)!;
      attributes[key] = value;

      switch (key) {
        case 'group-title':
          groupTitle = value;
          break;
        case 'tvg-logo':
          logo = value;
          break;
        case 'tvg-id':
          tvgId = value;
          break;
        case 'tvg-name':
          tvgName = value;
          break;
      }
    }

    // İsmi al (son virgülden sonrası)
    final commaIndex = extinf.lastIndexOf(',');
    if (commaIndex != -1) {
      name = extinf.substring(commaIndex + 1).trim();
    }

    return Channel(
      name: name,
      url: url.trim(),
      groupTitle: groupTitle,
      logo: logo,
      tvgId: tvgId,
      tvgName: tvgName,
      attributes: attributes,
    );
  }

  /// M3U formatına dönüştür
  String toM3U() {
    final buffer = StringBuffer('#EXTINF:-1');
    
    if (tvgId != null) buffer.write(' tvg-id="$tvgId"');
    if (tvgName != null) buffer.write(' tvg-name="$tvgName"');
    if (logo != null) buffer.write(' tvg-logo="$logo"');
    buffer.write(' group-title="$groupTitle"');
    
    // Diğer attribute'lar
    for (final entry in attributes.entries) {
      if (!['group-title', 'tvg-logo', 'tvg-id', 'tvg-name'].contains(entry.key)) {
        buffer.write(' ${entry.key}="${entry.value}"');
      }
    }
    
    buffer.write(',$name\n');
    buffer.write(url);
    
    return buffer.toString();
  }

  @override
  String toString() => 'Channel($name, $groupTitle)';
}

/// Kanal grubu
class ChannelGroup {
  final String name;
  final List<Channel> channels;
  bool isSelected;
  final String? countryCode;

  ChannelGroup({
    required this.name,
    required this.channels,
    this.isSelected = false,
    this.countryCode,
  });

  int get channelCount => channels.length;

  /// Grup isminden ülke kodu çıkar
  static String? extractCountryCode(String groupName) {
    final upperName = groupName.toUpperCase();
    
    // Bilinen ülke kodları ve varyasyonları
    final countryPatterns = {
      'TR': ['TR', 'TURKEY', 'TÜRK', 'TURK', 'TÜRKİYE', 'TURKIYE'],
      'DE': ['DE', 'GERMANY', 'GERMAN', 'ALMANYA', 'DEUTSCH'],
      'AT': ['AT', 'AUSTRIA', 'AVUSTURYA', 'ÖSTERREICH'],
      'US': ['US', 'USA', 'UNITED STATES', 'AMERICA', 'ABD'],
      'UK': ['UK', 'GB', 'UNITED KINGDOM', 'BRITISH', 'ENGLAND', 'İNGİLTERE'],
      'FR': ['FR', 'FRANCE', 'FRENCH', 'FRANSA', 'FRANÇAIS'],
      'IT': ['IT', 'ITALY', 'ITALIAN', 'İTALYA', 'ITALIANO'],
      'ES': ['ES', 'SPAIN', 'SPANISH', 'İSPANYA', 'ESPAÑOL'],
      'NL': ['NL', 'NETHERLANDS', 'DUTCH', 'HOLLANDA', 'NEDERLAND'],
      'BE': ['BE', 'BELGIUM', 'BELGIAN', 'BELÇİKA'],
      'RO': ['RO', 'ROMANIA', 'ROMANIAN', 'ROMANYA'],
      'RU': ['RU', 'RUSSIA', 'RUSSIAN', 'RUSYA'],
      'PL': ['PL', 'POLAND', 'POLISH', 'POLONYA'],
      'GR': ['GR', 'GREECE', 'GREEK', 'YUNANİSTAN'],
      'PT': ['PT', 'PORTUGAL', 'PORTUGUESE', 'PORTEKİZ'],
      'SA': ['SA', 'SAUDI', 'ARAB', 'ARABIC', 'ARAP'],
      'AE': ['AE', 'UAE', 'EMIRATES', 'BAE'],
      'IN': ['IN', 'INDIA', 'INDIAN', 'HİNDİSTAN'],
      'PK': ['PK', 'PAKISTAN', 'PAKISTANI'],
      'BR': ['BR', 'BRAZIL', 'BRAZILIAN', 'BREZİLYA'],
      'MX': ['MX', 'MEXICO', 'MEXICAN', 'MEKSİKA'],
      'CA': ['CA', 'CANADA', 'CANADIAN', 'KANADA'],
      'AU': ['AU', 'AUSTRALIA', 'AUSTRALIAN', 'AVUSTRALYA'],
      'JP': ['JP', 'JAPAN', 'JAPANESE', 'JAPONYA'],
      'KR': ['KR', 'KOREA', 'KOREAN', 'KORE'],
      'CN': ['CN', 'CHINA', 'CHINESE', 'ÇİN'],
      'AL': ['AL', 'ALBANIA', 'ALBANIAN', 'ARNAVUTLUK'],
      'RS': ['RS', 'SERBIA', 'SERBIAN', 'SIRBİSTAN'],
      'HR': ['HR', 'CROATIA', 'CROATIAN', 'HIRVATİSTAN'],
      'BA': ['BA', 'BOSNIA', 'BOSNIAN', 'BOSNA'],
      'MK': ['MK', 'MACEDONIA', 'MACEDONIAN', 'MAKEDONYA'],
      'BG': ['BG', 'BULGARIA', 'BULGARIAN', 'BULGARİSTAN'],
      'HU': ['HU', 'HUNGARY', 'HUNGARIAN', 'MACARİSTAN'],
      'CZ': ['CZ', 'CZECH', 'CZECHIA', 'ÇEK'],
      'SK': ['SK', 'SLOVAKIA', 'SLOVAK', 'SLOVAKYA'],
      'SE': ['SE', 'SWEDEN', 'SWEDISH', 'İSVEÇ'],
      'NO': ['NO', 'NORWAY', 'NORWEGIAN', 'NORVEÇ'],
      'DK': ['DK', 'DENMARK', 'DANISH', 'DANİMARKA'],
      'FI': ['FI', 'FINLAND', 'FINNISH', 'FİNLANDİYA'],
      'IR': ['IR', 'IRAN', 'IRANIAN', 'İRAN', 'PERSIAN'],
      'AF': ['AF', 'AFGHANISTAN', 'AFGHAN', 'AFGANİSTAN'],
      'AZ': ['AZ', 'AZERBAIJAN', 'AZERI', 'AZERBAYCAN'],
      'KZ': ['KZ', 'KAZAKHSTAN', 'KAZAK', 'KAZAKİSTAN'],
      'UZ': ['UZ', 'UZBEKISTAN', 'UZBEK', 'ÖZBEKİSTAN'],
      'UA': ['UA', 'UKRAINE', 'UKRAINIAN', 'UKRAYNA'],
      'BY': ['BY', 'BELARUS', 'BELARUSIAN', 'BELARUS'],
      'IL': ['IL', 'ISRAEL', 'ISRAELI', 'İSRAİL', 'HEBREW'],
      'EG': ['EG', 'EGYPT', 'EGYPTIAN', 'MISIR'],
      'MA': ['MA', 'MOROCCO', 'MOROCCAN', 'FAS'],
      'DZ': ['DZ', 'ALGERIA', 'ALGERIAN', 'CEZAYİR'],
      'TN': ['TN', 'TUNISIA', 'TUNISIAN', 'TUNUS'],
      'XX': ['XXX', 'ADULT', 'PORN', '+18', '18+', 'EROTIC'],
      'SPORTS': ['SPORT', 'SPORTS', 'SPOR', 'FOOTBALL', 'SOCCER', 'NBA', 'NFL', 'UFC', 'BEIN'],
      'MOVIE': ['MOVIE', 'FILM', 'CINEMA', 'SİNEMA', 'FİLM'],
      'KIDS': ['KIDS', 'CHILDREN', 'ÇOCUK', 'CARTOON', 'ANİME', 'DISNEY'],
      'NEWS': ['NEWS', 'HABER', 'NOTICIAS'],
      'MUSIC': ['MUSIC', 'MÜZIK', 'MUSICA'],
      'DOCU': ['DOCUMENTARY', 'BELGESEL', 'DOCU', 'DOKU'],
    };

    for (final entry in countryPatterns.entries) {
      for (final pattern in entry.value) {
        // Tam kelime eşleşmesi veya başında/sonunda
        if (upperName.startsWith('$pattern ') ||
            upperName.startsWith('$pattern|') ||
            upperName.startsWith('$pattern:') ||
            upperName.startsWith('$pattern-') ||
            upperName.endsWith(' $pattern') ||
            upperName.endsWith('|$pattern') ||
            upperName == pattern ||
            upperName.contains(' $pattern ') ||
            upperName.contains('|$pattern|')) {
          return entry.key;
        }
      }
    }

    return null;
  }

  /// Ülke bayrağı emoji
  String get flagEmoji {
    if (countryCode == null || countryCode!.length != 2) {
      return '🌍';
    }
    
    // Special categories
    switch (countryCode) {
      case 'XX':
        return '🔞';
      case 'SPORTS':
        return '⚽';
      case 'MOVIE':
        return '🎬';
      case 'KIDS':
        return '👶';
      case 'NEWS':
        return '📰';
      case 'MUSIC':
        return '🎵';
      case 'DOCU':
        return '📚';
    }
    
    // Ülke kodu -> bayrak emoji
    final codeUnits = countryCode!.toUpperCase().codeUnits;
    final flagCodeUnits = codeUnits.map((c) => c - 0x41 + 0x1F1E6).toList();
    return String.fromCharCodes(flagCodeUnits);
  }

  @override
  String toString() => 'ChannelGroup($name, ${channels.length} channels)';
}

/// IPTV Playlist
class IPTVPlaylist {
  final String sourceUrl;
  final List<Channel> channels;
  final List<ChannelGroup> groups;
  final DateTime? expiryDate;
  final bool isWorking;
  final String? error;
  final Map<String, String> metadata;

  IPTVPlaylist({
    required this.sourceUrl,
    required this.channels,
    required this.groups,
    this.expiryDate,
    this.isWorking = true,
    this.error,
    this.metadata = const {},
  });

  int get totalChannels => channels.length;
  int get totalGroups => groups.length;

  /// Seçili grupları al
  List<ChannelGroup> get selectedGroups => groups.where((g) => g.isSelected).toList();

  /// Seçili kanallları al
  List<Channel> get selectedChannels {
    final selected = <Channel>[];
    for (final group in selectedGroups) {
      selected.addAll(group.channels);
    }
    return selected;
  }

  /// M3U formatına dönüştür
  String toM3U({List<ChannelGroup>? customGroups}) {
    final buffer = StringBuffer('#EXTM3U');
    
    // Metadata
    for (final entry in metadata.entries) {
      buffer.write(' ${entry.key}="${entry.value}"');
    }
    buffer.writeln();
    
    final groupsToExport = customGroups ?? selectedGroups;
    for (final group in groupsToExport) {
      for (final channel in group.channels) {
        buffer.writeln(channel.toM3U());
      }
    }
    
    return buffer.toString();
  }

  /// M3U8 formatına dönüştür (UTF-8 BOM ile)
  String toM3U8({List<ChannelGroup>? customGroups}) {
    return toM3U(customGroups: customGroups);
  }

  /// M3U8 Plus formatına dönüştür (ek metadata ile)
  String toM3U8Plus({List<ChannelGroup>? customGroups}) {
    final buffer = StringBuffer('#EXTM3U');
    buffer.write(' url-tvg="http://epg.example.com"');
    buffer.write(' x-tvg-url="http://epg.example.com"');
    buffer.write(' refresh="3600"');
    
    // Metadata
    for (final entry in metadata.entries) {
      buffer.write(' ${entry.key}="${entry.value}"');
    }
    buffer.writeln();
    
    final groupsToExport = customGroups ?? selectedGroups;
    for (final group in groupsToExport) {
      for (final channel in group.channels) {
        buffer.writeln(channel.toM3U());
      }
    }
    
    return buffer.toString();
  }

  @override
  String toString() => 'IPTVPlaylist($sourceUrl, $totalChannels channels, $totalGroups groups)';
}

/// Test sonucu
class TestResult {
  final String url;
  final bool isWorking;
  final int responseTime; // ms
  final String? error;
  final String? contentType;
  final DateTime? expiryDate;

  TestResult({
    required this.url,
    required this.isWorking,
    this.responseTime = 0,
    this.error,
    this.contentType,
    this.expiryDate,
  });
}

/// Export formatları
enum ExportFormat {
  m3u('M3U', '.m3u', 'Standart playlist formatı'),
  m3u8('M3U8', '.m3u8', 'HTTP Live Streaming için'),
  m3u8plus('M3U8 Plus', '.m3u8', 'Gelişmiş metadata ile');

  final String displayName;
  final String extension;
  final String description;

  const ExportFormat(this.displayName, this.extension, this.description);
}

/// İşlem durumu
enum ProcessingState {
  idle,
  extractingLinks,
  testingLinks,
  parsingPlaylist,
  testingChannels,
  filtering,
  exporting,
  completed,
  error,
}

/// İşlem ilerleme bilgisi
class ProcessingProgress {
  final ProcessingState state;
  final double progress; // 0.0 - 1.0
  final String message;
  final String? detail;
  final int? current;
  final int? total;
  final Duration? estimatedTimeRemaining;

  ProcessingProgress({
    required this.state,
    required this.progress,
    required this.message,
    this.detail,
    this.current,
    this.total,
    this.estimatedTimeRemaining,
  });

  String get progressText {
    if (current != null && total != null) {
      return '$current / $total';
    }
    return '${(progress * 100).toStringAsFixed(1)}%';
  }

  String get etaText {
    if (estimatedTimeRemaining == null) return '';
    final eta = estimatedTimeRemaining!;
    if (eta.inMinutes > 0) {
      return 'Tahmini: ${eta.inMinutes}dk ${eta.inSeconds % 60}sn';
    }
    return 'Tahmini: ${eta.inSeconds}sn';
  }
}

/// Country bilgisi
class Country {
  final String code;
  final String name;
  final String flagEmoji;
  bool isSelected;

  Country({
    required this.code,
    required this.name,
    required this.flagEmoji,
    this.isSelected = false,
  });

  static final Map<String, Country> all = {
    'TR': Country(code: 'TR', name: 'Türkiye', flagEmoji: '🇹🇷'),
    'DE': Country(code: 'DE', name: 'Almanya', flagEmoji: '🇩🇪'),
    'AT': Country(code: 'AT', name: 'Avusturya', flagEmoji: '🇦🇹'),
    'US': Country(code: 'US', name: 'Amerika', flagEmoji: '🇺🇸'),
    'UK': Country(code: 'UK', name: 'İngiltere', flagEmoji: '🇬🇧'),
    'FR': Country(code: 'FR', name: 'Fransa', flagEmoji: '🇫🇷'),
    'IT': Country(code: 'IT', name: 'İtalya', flagEmoji: '🇮🇹'),
    'ES': Country(code: 'ES', name: 'İspanya', flagEmoji: '🇪🇸'),
    'NL': Country(code: 'NL', name: 'Hollanda', flagEmoji: '🇳🇱'),
    'BE': Country(code: 'BE', name: 'Belçika', flagEmoji: '🇧🇪'),
    'RO': Country(code: 'RO', name: 'Romanya', flagEmoji: '🇷🇴'),
    'RU': Country(code: 'RU', name: 'Rusya', flagEmoji: '🇷🇺'),
    'PL': Country(code: 'PL', name: 'Polonya', flagEmoji: '🇵🇱'),
    'GR': Country(code: 'GR', name: 'Yunanistan', flagEmoji: '🇬🇷'),
    'PT': Country(code: 'PT', name: 'Portekiz', flagEmoji: '🇵🇹'),
    'SA': Country(code: 'SA', name: 'Arap', flagEmoji: '🇸🇦'),
    'IN': Country(code: 'IN', name: 'Hindistan', flagEmoji: '🇮🇳'),
    'BR': Country(code: 'BR', name: 'Brezilya', flagEmoji: '🇧🇷'),
    'AL': Country(code: 'AL', name: 'Arnavutluk', flagEmoji: '🇦🇱'),
    'RS': Country(code: 'RS', name: 'Sırbistan', flagEmoji: '🇷🇸'),
    'HR': Country(code: 'HR', name: 'Hırvatistan', flagEmoji: '🇭🇷'),
    'BG': Country(code: 'BG', name: 'Bulgaristan', flagEmoji: '🇧🇬'),
    'HU': Country(code: 'HU', name: 'Macaristan', flagEmoji: '🇭🇺'),
    'UA': Country(code: 'UA', name: 'Ukrayna', flagEmoji: '🇺🇦'),
    'AZ': Country(code: 'AZ', name: 'Azerbaycan', flagEmoji: '🇦🇿'),
    'SPORTS': Country(code: 'SPORTS', name: 'Spor', flagEmoji: '⚽'),
    'MOVIE': Country(code: 'MOVIE', name: 'Film/Sinema', flagEmoji: '🎬'),
    'KIDS': Country(code: 'KIDS', name: 'Çocuk', flagEmoji: '👶'),
    'NEWS': Country(code: 'NEWS', name: 'Haber', flagEmoji: '📰'),
    'MUSIC': Country(code: 'MUSIC', name: 'Müzik', flagEmoji: '🎵'),
    'DOCU': Country(code: 'DOCU', name: 'Belgesel', flagEmoji: '📚'),
  };
}
