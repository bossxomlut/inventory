import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/utils/env.dart';
import 'injection/injection.dart';
import 'route/app_router.dart';

/*
* Manual configure environment to load sensitive data
* */
const Environment env = Environment.TEST;

void main() async {
  ///Ensure flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  ///Ensure localization is initialized
  await EasyLocalization.ensureInitialized();

  ///Configure dependencies for the app
  ///This will be used to inject dependencies
  ///Using [GetIt] package and [injectable] package
  configureDependencies();

  ///Start load environment
  await getIt.get<EnvLoader>().load(env);

  ///Observer for bloc changes
  Bloc.observer = getIt.get();

  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('de', 'DE'),
      ],
      path: 'assets/translations',
      // <-- change the path of the translation files
      fallbackLocale: Locale('en', 'US'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter.config(
        navigatorObservers: () => <NavigatorObserver>[
          RouteLoggerObserver(),
        ],
      ),
      title: 'Flutter Demo',
      theme: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
