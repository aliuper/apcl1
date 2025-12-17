# 📺 IPTV Group Editor

<p align="center">
  <img src="assets/icons/app_icon.png" width="120" alt="IPTV Group Editor Logo">
</p>

<p align="center">
  <strong>Profesyonel IPTV Playlist Düzenleme Uygulaması</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.24-blue?logo=flutter" alt="Flutter">
  <img src="https://img.shields.io/badge/Dart-3.2-blue?logo=dart" alt="Dart">
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android" alt="Android">
  <img src="https://img.shields.io/badge/License-MIT-yellow" alt="License">
</p>

---

## ✨ Özellikler

### 🎯 Manuel Düzenleme Modu
- Tek IPTV linki girişi
- Otomatik link doğrulama ve test
- Video akış kontrolü
- Detaylı grup listesi ve seçimi
- Bitiş tarihi tespiti

### 🚀 Otomatik Düzenleme Modu
- Çoklu link veya karışık metin desteği
- Otomatik IPTV linki çıkarma
- Toplu link testi
- **Ülke bazlı filtreleme** (TR, DE, AT, US, UK, FR, vb.)
- Tüm playlistleri tek dosyada birleştirme seçeneği

### 📁 Dışa Aktarma
- **M3U** - Standart playlist formatı
- **M3U8** - HTTP Live Streaming formatı
- **M3U8 Plus** - Gelişmiş metadata desteği
- Akıllı dosya isimlendirme (tarih + versiyon + bitiş tarihi)

### 🎨 Modern Arayüz
- Material Design 3
- Koyu tema
- Akıcı animasyonlar (60fps)
- Responsive tasarım

---

## 📱 Ekran Görüntüleri

| Ana Sayfa | Manuel Mod | Grup Seçimi |
|:---------:|:----------:|:-----------:|
| ![Home](screenshots/home.png) | ![Manual](screenshots/manual.png) | ![Groups](screenshots/groups.png) |

| Ülke Seçimi | Dışa Aktarma | Sonuç |
|:-----------:|:------------:|:-----:|
| ![Countries](screenshots/countries.png) | ![Export](screenshots/export.png) | ![Result](screenshots/result.png) |

---

## 🛠️ Kurulum

### Gereksinimler
- Flutter 3.24+
- Dart 3.2+
- Android SDK 21+

### Geliştirme

```bash
# Repository'yi klonla
git clone https://github.com/yourusername/iptv_group_editor.git
cd iptv_group_editor

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

### APK Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APKs (daha küçük boyut)
flutter build apk --release --split-per-abi
```

---

## 🔄 GitHub Actions ile Otomatik Build

Repository'ye push yaptığınızda veya tag oluşturduğunuzda otomatik olarak APK oluşturulur.

### Release Oluşturma

```bash
# Yeni versiyon tag'i oluştur
git tag v2.0.0
git push origin v2.0.0
```

Bu işlem sonrasında GitHub Actions:
1. APK'ları build eder
2. Otomatik release oluşturur
3. APK'ları release'e ekler

---

## 📂 Proje Yapısı

```
lib/
├── main.dart              # Uygulama giriş noktası
├── theme/
│   └── app_theme.dart     # Tema ve stil tanımları
├── models/
│   └── iptv_models.dart   # Data modelleri
├── services/
│   ├── iptv_service.dart  # IPTV işlemleri
│   └── storage_service.dart
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── manual_screen.dart
│   ├── auto_screen.dart
│   ├── group_select_screen.dart
│   ├── country_select_screen.dart
│   ├── export_screen.dart
│   ├── processing_screen.dart
│   └── result_screen.dart
└── widgets/
    ├── gradient_card.dart
    ├── mode_card.dart
    ├── progress_card.dart
    └── custom_button.dart
```

---

## 🌍 Desteklenen Ülkeler

| Kod | Ülke | Kod | Ülke |
|-----|------|-----|------|
| 🇹🇷 TR | Türkiye | 🇩🇪 DE | Almanya |
| 🇦🇹 AT | Avusturya | 🇺🇸 US | Amerika |
| 🇬🇧 UK | İngiltere | 🇫🇷 FR | Fransa |
| 🇮🇹 IT | İtalya | 🇪🇸 ES | İspanya |
| 🇳🇱 NL | Hollanda | 🇧🇪 BE | Belçika |
| 🇷🇴 RO | Romanya | 🇷🇺 RU | Rusya |
| 🇵🇱 PL | Polonya | 🇬🇷 GR | Yunanistan |
| ⚽ SPORTS | Spor | 🎬 MOVIE | Film |
| 👶 KIDS | Çocuk | 📰 NEWS | Haber |

*ve daha fazlası...*

---

## 📋 Dosya İsimlendirme

Oluşturulan dosyalar şu formatta isimlendirilir:

```
DDMMYYYY_iptv_vX_DDMMYYYY.m3u
│        │    │  │
│        │    │  └── Bitiş tarihi (varsa)
│        │    └───── Versiyon numarası
│        └────────── Sabit prefix
└─────────────────── Oluşturma tarihi
```

**Örnek:** `17122025_iptv_v1_31012026.m3u8`

---

## 🔐 İzinler

Uygulama şu izinleri kullanır:

- **INTERNET** - Link testi için
- **WRITE_EXTERNAL_STORAGE** - Dosya kaydetmek için
- **READ_EXTERNAL_STORAGE** - Mevcut dosyaları okumak için

---

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add amazing feature'`)
4. Push yapın (`git push origin feature/amazing-feature`)
5. Pull Request açın

---

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır. Detaylar için [LICENSE](LICENSE) dosyasına bakın.

---

## 📧 İletişim

Sorularınız veya önerileriniz için issue açabilirsiniz.

---

<p align="center">
  Made with ❤️ and Flutter
</p>
