import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/first_screen.dart';
import 'providers/user_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const SuitmediaApp(),
    ),
  );
}

class SuitmediaApp extends StatelessWidget {
  const SuitmediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Suitmedia App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const FirstScreen(),
    );
  }
}
