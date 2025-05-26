import 'package:flutter/material.dart';
import 'package:night_walkers_app/screens/homescreen.dart';
import 'package:night_walkers_app/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Global error widget for user-friendly error messages
  ErrorWidget.builder = (FlutterErrorDetails details) {
    bool inDebug = false;
    assert(() {
      inDebug = true;
      return true;
    }());
    // In debug, show the default error
    if (inDebug) { 
      return ErrorWidget(details.exception);
    }
    // In release, show a friendly message
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 64),
            SizedBox(height: 16),
            Text(
              'Something went wrong. Please restart the app.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  };
  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('showOnboarding') ?? true;
  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Night Walkers App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // Named routes para kuno easier navigation
      routes: {
        '/': (context) => Semantics(
              label: 'Night Walkers Home Screen',
              child: const HomeScreen(),
            ),
        '/onboarding': (context) => const OnboardingScreen(),
       
       
      },
      initialRoute: showOnboarding ? '/onboarding' : '/',
      // Responsive design gyat: wrap home in LayoutBuilder to adjust layout based on screen size
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            
            final scale = constraints.maxWidth < 400 ? 0.9 : 1.0;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            );
          },
        );
      },
     
    );
  }
}
