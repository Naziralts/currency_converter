import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'di/service_locator.dart';
import 'features/converter/presentation/bloc/converter_bloc.dart';
import 'features/converter/presentation/bloc/converter_event.dart';
import 'features/converter/presentation/pages/converter_page.dart';
import 'features/converter/domain/usecases/get_history.dart';
import 'features/converter/domain/usecases/get_latest_rate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: Builder(
        builder: (context) => BlocProvider(
          create: (_) => ConverterBloc(
            getLatestRate: sl<GetLatestRate>(),
            getHistory: sl<GetHistory>(),
          )..add(const ConverterInit()),
          child: const ConverterPage(),
        ),
      ),
    );
  }
}
