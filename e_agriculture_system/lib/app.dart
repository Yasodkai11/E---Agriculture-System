import 'package:e_agriculture_system/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_strings.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/language_provider.dart';
import 'presentation/providers/notification_provider.dart';
import 'routes/route_generator.dart';
import 'routes/app_routes.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'utils/payment_monitor.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
  
  // Public static method to get the current navigator key
  static GlobalKey<NavigatorState>? get currentNavigatorKey => _AppState.currentNavigatorKey;
}

class _AppState extends State<App> with WidgetsBindingObserver {
  late PaymentMonitor _paymentMonitor;
  late final GlobalKey<NavigatorState> _navigatorKey;
  
  // Static reference to the current navigator key
  static GlobalKey<NavigatorState>? _currentNavigatorKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Initialize navigator key
    _navigatorKey = GlobalKey<NavigatorState>();
    _currentNavigatorKey = _navigatorKey;
    
    // Initialize payment monitoring
    _paymentMonitor = PaymentMonitor();
    _paymentMonitor.startMonitoring();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _paymentMonitor.dispose();
    _currentNavigatorKey = null;
    super.dispose();
  }
  
  // Static method to get the current navigator key
  static GlobalKey<NavigatorState>? get currentNavigatorKey => _currentNavigatorKey;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Pause/resume payment monitoring based on app lifecycle
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _paymentMonitor.stopMonitoring();
        break;
      case AppLifecycleState.resumed:
        _paymentMonitor.startMonitoring();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            try {
              return AuthProvider();
            } catch (e) {
              // Log error for debugging but don't use print in production
              debugPrint('Error creating AuthProvider: $e');
              // Return a basic provider if Firebase fails
              return AuthProvider();
            }
          },
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            locale: languageProvider.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('si', 'LK'),
            ],
            initialRoute: AppRoutes.splash,
            onGenerateRoute: (settings) {
              // Log route generation for debugging
              print('🔧 Generating route for: ${settings.name}');
              
              // Handle special cases first
              if (settings.name == null || settings.name!.isEmpty || settings.name == '/') {
                print('🔄 Redirecting root route to splash');
                return MaterialPageRoute(
                  builder: (_) => const SplashScreen(),
                  settings: const RouteSettings(name: AppRoutes.splash),
                );
              }
              
              // Generate the route normally
              return RouteGenerator.generateRoute(settings);
            },
            onUnknownRoute: (settings) {
              // Log unknown route for debugging
              print('🌐 Unknown route in onUnknownRoute: ${settings.name}');
              
              // Handle unknown routes by redirecting to splash
              return MaterialPageRoute(
                builder: (_) => const SplashScreen(),
                settings: const RouteSettings(name: AppRoutes.splash),
              );
            },
            // Handle web navigation better
            navigatorKey: _navigatorKey,
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(1.0), // Prevent text scaling issues
                ),
                child: child!,
              );
            },
            // Add route observer for debugging
            navigatorObservers: [
              RouteObserver<ModalRoute<dynamic>>(),
            ],
          );
        },
      ),
    );
  }
}
