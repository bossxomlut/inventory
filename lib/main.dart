import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

import 'core/persistence/persistence_config.dart';
import 'injection/injection.dart';
import 'resource/index.dart';
import 'route/app_router.dart';

bool get showDevicePreview => false;

/*
* Manual configure environment to load sensitive data
* */
// const Environment env = Environment.TEST;

void main() async {
  ///Ensure flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  ///Ensure localization is initialized
  await Future.wait(<Future<void>>[
    EasyLocalization.ensureInitialized(),
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
  ]);

  ///Configure dependencies for the app
  ///This will be used to inject dependencies
  ///Using [GetIt] package and [injectable] package
  configureDependencies();

  ///Init persistence storage
  await PersistenceConfig.init();

  ///Start load environment
  // await getIt.get<EnvLoader>().load(env);

  ThemeUtils.initThemeMode();

  ///Observer for bloc changes
  Bloc.observer = getIt.get();

  List<Locale> supportedLocales = <Locale>[
    const Locale('en', 'US'),
  ];

  if (showDevicePreview) {
    runApp(
      DevicePreview(
        builder: (BuildContext context) => EasyLocalization(
          supportedLocales: supportedLocales,
          path: 'assets/translations', // <-- change the path of the translation files
          fallbackLocale: supportedLocales.first, child: const MyApp(),
        ),
      ),
    );
  } else {
    runApp(
      EasyLocalization(
        supportedLocales: supportedLocales,
        path: 'assets/translations', // <-- change the path of the translation files
        fallbackLocale: supportedLocales.first, child: const MyApp(),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        ensureScreenSize: true,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) {
          return ValueListenableBuilder(
              valueListenable: ThemeUtils.themeModeNotifier,
              builder: (context, ThemeMode themeMode, _) {
                return ToastificationWrapper(
                  child: MaterialApp.router(
                    routerConfig: appRouter.config(
                      navigatorObservers: () => <NavigatorObserver>[
                        RouteLoggerObserver(),
                      ],
                    ),
                    theme: ThemeUtils.lightTheme,
                    darkTheme: ThemeUtils.darkTheme,
                    themeMode: themeMode,
                    localizationsDelegates: context.localizationDelegates,
                    supportedLocales: context.supportedLocales,
                    locale: context.locale,
                  ),
                );
              });
        });
  }
}
