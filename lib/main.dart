import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'di/service_locator.dart';
import 'features/converter/presentation/bloc/converter_bloc.dart';
import 'features/converter/presentation/bloc/converter_event.dart';
import 'features/converter/presentation/pages/converter_page.dart';
import 'features/converter/domain/usecases/get_history.dart';
import 'features/converter/domain/usecases/get_latest_rate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('themeMode');
  final themeMode = _stringToThemeMode(savedTheme);

  runApp(MyApp(savedThemeMode: themeMode));
}


ThemeMode _stringToThemeMode(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    default:
      return 'system';
  }
}

class MyApp extends StatefulWidget {
  final ThemeMode savedThemeMode;
  const MyApp({super.key, required this.savedThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.savedThemeMode;
  }

  Future<void> _toggleTheme() async {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _themeModeToString(_themeMode));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

   
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),


      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Colors.tealAccent,
          surface: Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      home: Builder(
        builder: (context) => BlocProvider(
          create: (_) => ConverterBloc(
            getLatestRate: sl<GetLatestRate>(),
            getHistory: sl<GetHistory>(),
          )..add(const ConverterInit()),
          child: ConverterPageWithThemeToggle(toggleTheme: _toggleTheme),
        ),
      ),
    );
  }
}


class ConverterPageWithThemeToggle extends StatelessWidget {
  final VoidCallback toggleTheme;
  const ConverterPageWithThemeToggle({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: false, 
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Currency Converter',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: isDark
                ? 'Switch to Light Theme'
                : 'Switch to Dark Theme',
            icon: Icon(
              isDark ? Icons.wb_sunny_outlined : Icons.nightlight_round,
            ),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: const ConverterPage(),
    );
  }
}
