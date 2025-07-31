import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://oitliccfvoebfkqnrcfo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9pdGxpY2Nmdm9lYmZrcW5yY2ZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTI2NTk0MzQsImV4cCI6MjA2ODIzNTQzNH0.SENPZ17x8sizv4lK5YY9dk3ybizL4AxmLLWBoMaY2Ag',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home:
          const AuthScreen(), // Прямое указание AuthScreen как стартовой страницы
      debugShowCheckedModeBanner: false,
    );
  }
}
