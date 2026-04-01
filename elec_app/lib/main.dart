import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'utils/theme.dart';
import 'utils/localization.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/client_login_screen.dart';
import 'screens/auth/electrician_login_screen.dart';
import 'screens/auth/client_register_screen.dart';
import 'screens/auth/electrician_register_screen.dart';
import 'screens/client/client_home_screen.dart';
import 'screens/electrician/electrician_home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: Selector<AppProvider, AppLanguage>(
        selector: (_, provider) => provider.language,
        builder: (context, language, _) {
          final l10n = AppLocalizer.fromLanguage(language);

          return MaterialApp(
            title: l10n.tr('خدمات الكهرباء', 'Services electriques'),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            builder: (context, child) {
              return Directionality(
                textDirection: l10n.direction,
                child: child ?? const SizedBox.shrink(),
              );
            },
            initialRoute: '/',
            routes: {
              '/': (context) => const WelcomeScreen(),
              '/client-login': (context) => const ClientLoginScreen(),
              '/electrician-login': (context) => const ElectricianLoginScreen(),
              '/client-register': (context) => const ClientRegisterScreen(),
              '/electrician-register':
                  (context) => const ElectricianRegisterScreen(),
              '/client-home': (context) => const ClientHomeScreen(),
              '/electrician-home': (context) => const ElectricianHomeScreen(),
            },
          );
        },
      ),
    );
  }
}
