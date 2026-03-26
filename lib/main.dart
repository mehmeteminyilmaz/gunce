import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path_provider/path_provider.dart';
import 'models/entry.dart';
import 'screens/splash_screen.dart';
import 'utils/notification_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr', null);
  await Hive.initFlutter();
  Hive.registerAdapter(EntryAdapter());
  await Hive.openBox<Entry>('entries');
  await Hive.openBox('profile');
  await NotificationService().init();

  runApp(const GunceApp());
}

class GunceApp extends StatefulWidget {
  const GunceApp({super.key});

  @override
  State<GunceApp> createState() => _GunceAppState();
}

class _GunceAppState extends State<GunceApp> {
  late Box _profileBox;

  @override
  void initState() {
    super.initState();
    _profileBox = Hive.box('profile');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _profileBox.listenable(keys: ['isDarkMode', 'zenThemeIndex']),
      builder: (context, Box box, child) {
        final isDarkMode = box.get('isDarkMode', defaultValue: false);
        final themeIndex = box.get('zenThemeIndex', defaultValue: 0);
        final zenTheme = ZenThemeType.values[themeIndex % ZenThemeType.values.length];
        
        return MaterialApp(
          title: 'Günce',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.getTheme(zenTheme, false),
          darkTheme: AppTheme.getTheme(zenTheme, true),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}