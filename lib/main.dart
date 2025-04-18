import 'package:flutter/material.dart';
import 'package:pathagar/views/screens/TermsOfServiceScreen.dart';
import 'package:pathagar/views/screens/home_page.dart';
import 'package:pathagar/views/screens/onboardingscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ThemeController/ThemeController.dart';
import 'controllers/book/book_download_service.dart';
import 'controllers/book/book_preferences.dart';
import 'controllers/book/book_repository.dart';
import 'controllers/book/book_storage_service.dart';
import 'controllers/book_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final prefs = await SharedPreferences.getInstance();
    final repository = BookRepository();
    final storageService = BookStorageService(prefs);
    final downloadService = BookDownloadService(storageService);
    final preferences = BookPreferences(prefs);
    final themeController = ThemeController(prefs: prefs);
    final bookController = BookController(
      repository: repository,
      downloadService: downloadService,
      storageService: storageService,
      preferences: preferences,
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => bookController),
          ChangeNotifierProvider(create: (_) => themeController),
        ],
        child: const Pathagar(),
      ),
    );
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Initialization failed: $e',
                style: const TextStyle(color: Colors.red)),
          ),
        ),
      ),
    );
  }
}

class Pathagar extends StatelessWidget {
  const Pathagar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Free eBooks',
          theme: themeController.currentTheme,
          home: const AppInitializer(),
        );
      },
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: _checkFirstLaunch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 20),
                  Text('Initialization error: ${snapshot.error}',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => main(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final hasCompletedOnboarding = snapshot.data?['onboarding'] ?? false;
        final hasAcceptedTerms = snapshot.data?['terms'] ?? false;

        if (!hasCompletedOnboarding) {
          return const OnboardingScreen();
        } else if (!hasAcceptedTerms) {
          return const TermsOfServiceScreen();
        } else {
          return const HomePage();
        }
      },
    );
  }

  Future<Map<String, bool>> _checkFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'onboarding': prefs.getBool('hasCompletedOnboarding') ?? false,
        'terms': prefs.getBool('hasAcceptedTerms') ?? false,
      };
    } catch (e) {
      throw Exception('Failed to check first launch: $e');
    }
  }
}