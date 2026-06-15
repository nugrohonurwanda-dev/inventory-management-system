import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_3/providers/auth_provider.dart';
import 'package:flutter_application_3/providers/category_provider.dart';
import 'package:flutter_application_3/providers/product_provider.dart'; // FIX: uncomment
import 'package:flutter_application_3/login_page.dart';
import 'package:flutter_application_3/register_page.dart';
import 'package:flutter_application_3/main_menu_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(
            create: (_) => ProductProvider()), // FIX: uncomment
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      // FIX: pakai named routes agar pushNamedAndRemoveUntil di auth_provider bekerja
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/main_menu': (_) => const MainMenuPage(),
      },
    );
  }
}
