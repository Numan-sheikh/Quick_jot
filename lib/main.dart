import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart'; // Assuming this file is in the same directory

// Import your providers and screens
import 'providers/auth_provider.dart';
import 'providers/note_provider.dart';

// Import the SplashScreen
import 'screens/splash/splash_screen.dart'; // <--- Import your splash screen file

void main() async {
  // Ensure Flutter binding is initialized before using plugins like Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Run the app
  runApp(const QuickJotApp());
}

class QuickJotApp extends StatelessWidget {
  const QuickJotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provide your AuthProvider and NoteProvider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QuickJot',
        theme: ThemeData.light(), // Define your light theme
        darkTheme: ThemeData.dark(), // Define your dark theme
        // You can also set a default theme mode if desired
        // themeMode: ThemeMode.system, // or ThemeMode.light, ThemeMode.dark

        // Set the SplashScreen as the initial screen
        home: const SplashScreen(), // <--- Use SplashScreen here
      ),
    );
  }
}
