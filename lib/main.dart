import 'package:flutter/material.dart';
import 'api.dart';
import 'theme.dart';
import 'pages/login_page.dart';
import 'pages/home_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Api.loadToken();
  runApp(const XingheApp());
}

class XingheApp extends StatelessWidget {
  const XingheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '星河软件站',
      debugShowMaterialGrid: false,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: Api.token == null ? const LoginPage() : const HomeShell(),
    );
  }
}
