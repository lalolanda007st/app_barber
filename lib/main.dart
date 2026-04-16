import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'services/barber_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const BarberVisionApp());
}

class BarberVisionApp extends StatelessWidget {
  const BarberVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BarberProvider()),
      ],
      child: MaterialApp(
        title: 'BarberVision',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFD4A853),
            secondary: Color(0xFFB8860B),
            surface: Color(0xFF1A1A1A),
            background: Color(0xFF0D0D0D),
            onPrimary: Color(0xFF0D0D0D),
            onSurface: Color(0xFFF5F0E8),
          ),
          scaffoldBackgroundColor: const Color(0xFF0D0D0D),
          textTheme: GoogleFonts.playfairDisplayTextTheme(
            ThemeData.dark().textTheme,
          ).copyWith(
            bodyLarge: GoogleFonts.lato(color: const Color(0xFFF5F0E8)),
            bodyMedium: GoogleFonts.lato(color: const Color(0xFFCCBFA8)),
            bodySmall: GoogleFonts.lato(color: const Color(0xFF998877)),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
