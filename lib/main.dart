import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_application/theme_provider.dart';

import 'firebase_options.dart'; // Generated Firebase config
import 'pages/auth/auth.dart'; // AuthService // ThemeProvider class
import 'pages/weather_home_page.dart';
import 'screen/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific config
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const WeatherApp(),
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final baseTheme = ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: themeProvider.isDarkTheme
          ? const Color(0xFF1A1B23)
          : Colors.white,
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
          fontSize: 80,
        ),
        bodyMedium: TextStyle(
          color: themeProvider.isDarkTheme ? Colors.white70 : Colors.black87,
          fontSize: 16,
        ),
        titleMedium: TextStyle(
          color: themeProvider.isDarkTheme ? Colors.white : Colors.black,
          fontSize: 18,
        ),
      ),
      iconTheme: IconThemeData(
        color: themeProvider.isDarkTheme ? Colors.white70 : Colors.black87,
      ),
    );

    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: baseTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        return const WeatherHomePage();
      },
    );
  }
}
