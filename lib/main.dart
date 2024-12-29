import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'font_size_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FontSizeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return MaterialApp(
      title: 'Terawang App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F4F4),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF4F4F4),
        ),
        textTheme: GoogleFonts.manropeTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge:
              TextStyle(fontSize: fontSizeProvider.titleSize), // Title
          bodyMedium:
              TextStyle(fontSize: fontSizeProvider.bodySize), // Body Text
          titleMedium:
              TextStyle(fontSize: fontSizeProvider.subtitleSize), // Subtitle
        ),
      ),
      home: HomeScreen(),
    );
  }
}
