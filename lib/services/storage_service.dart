import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyLastFormat = 'last_format';
  static const String _keyMergeFiles = 'merge_files';
  static const String _keySelectedCountries = 'selected_countries';
  
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();
  
  // Son kullanılan format
  Future<String> getLastFormat() async {
    final prefs = await _prefs;
    return prefs.getString(_keyLastFormat) ?? 'm3u';
  }
  
  Future<void> setLastFormat(String format) async {
    final prefs = await _prefs;
    await prefs.setString(_keyLastFormat, format);
  }
  
  // Dosyaları birleştir ayarı
  Future<bool> getMergeFiles() async {
    final prefs = await _prefs;
    return prefs.getBool(_keyMergeFiles) ?? true;
  }
  
  Future<void> setMergeFiles(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_keyMergeFiles, value);
  }
  
  // Son seçilen ülkeler
  Future<List<String>> getSelectedCountries() async {
    final prefs = await _prefs;
    return prefs.getStringList(_keySelectedCountries) ?? [];
  }
  
  Future<void> setSelectedCountries(List<String> countries) async {
    final prefs = await _prefs;
    await prefs.setStringList(_keySelectedCountries, countries);
  }
}
