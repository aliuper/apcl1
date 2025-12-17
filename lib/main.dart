import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme/app_theme.dart';
import 'services/iptv_service.dart';
import 'services/storage_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/manual_screen.dart';
import 'screens/auto_screen.dart';
import 'screens/group_select_screen.dart';
import 'screens/country_select_screen.dart';
import 'screens/export_screen.dart';
import 'screens/processing_screen.dart';
import 'screens/result_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Sistem UI ayarları
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0a0a0f),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Sadece dikey mod
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const IPTVGroupEditorApp());
}

class IPTVGroupEditorApp extends StatelessWidget {
  const IPTVGroupEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => IPTVService()),
        Provider(create: (_) => StorageService()),
      ],
      child: MaterialApp(
        title: 'IPTV Group Editor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/manual': (context) => const ManualScreen(),
          '/auto': (context) => const AutoScreen(),
          '/group-select': (context) => const GroupSelectScreen(),
          '/country-select': (context) => const CountrySelectScreen(),
          '/export': (context) => const ExportScreen(),
          '/processing': (context) => const ProcessingScreen(),
          '/result': (context) => const ResultScreen(),
        },
      ),
    );
  }
}
