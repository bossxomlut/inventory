import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sample_app/provider/index.dart';
import 'package:toastification/toastification.dart';

import 'resources/index.dart';
import 'routes/app_router.dart';
import 'shared_widgets/toast.dart';

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
    // SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]),
  ]);

  ///Start load environment
  // await getIt.get<EnvLoader>().load(env);

  // ThemeUtils.initThemeMode();

  List<Locale> supportedLocales = <Locale>[
    const Locale('vi', 'VN'),
    const Locale('en', 'US'),
  ];

  if (showDevicePreview) {
    runApp(
      DevicePreview(
        builder: (BuildContext context) => ProviderScope(
          child: EasyLocalization(
            supportedLocales: supportedLocales,
            path: 'assets/translations',
            // <-- change the path of the translation files
            fallbackLocale: supportedLocales.first,
            child: const MyApp(),
          ),
        ),
      ),
    );
  } else {
    runApp(
      ProviderScope(
        child: EasyLocalization(
          supportedLocales: supportedLocales,
          path: 'assets/translations', // <-- change the path of the translation files
          fallbackLocale: supportedLocales.first, child: const MyApp(),
        ),
      ),
    );
  }
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != ref.read(isKeyboardVisibleProvider)) {
      ref.read(isKeyboardVisibleProvider.notifier).state = newValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        ensureScreenSize: true,
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, _) {
          return Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final theme = ref.watch(themeProvider);
              return ToastificationWrapper(
                config: ToastificationConfig(
                  alignment: Alignment.topCenter,
                  itemWidth: double.maxFinite,
                  animationDuration: const Duration(milliseconds: 300),
                  applyMediaQueryViewInsets: false,
                  marginBuilder: (BuildContext context, AlignmentGeometry alignment) => EdgeInsets.zero,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.topCenter,
                  children: [
                    MaterialApp.router(
                      title: 'Đơn và kho hàng',
                      routerConfig: appRouter.config(
                        navigatorObservers: () => <NavigatorObserver>[
                          RouteLoggerObserver(),
                        ],
                      ),
                      themeMode: ThemeMode.light,
                      theme: dTheme(context, theme.themeData),
                      darkTheme: dTheme(context, theme.themeData),
                      localizationsDelegates: [
                        ...context.localizationDelegates,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      supportedLocales: context.supportedLocales,
                      locale: context.locale,
                      debugShowCheckedModeBanner: false,
                    ),
                    const RootLoadingWidget(),
                    const RootNotificationWidget(),
                  ],
                ),
              );
            },
          );
        });
  }
}

class RootLoadingWidget extends ConsumerWidget {
  const RootLoadingWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isLoading = ref.watch(isLoadingProvider);
    if (isLoading) {
      return Container(
        color: Colors.black.withOpacity(0.5),
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }
    return const SizedBox();
  }
}

//root notification widget
class RootNotificationWidget extends ConsumerWidget {
  const RootNotificationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      notificationProvider,
      (previous, next) {
        if (next.isShow) {
          switch (next.type!) {
            case NotificationType.success:
              showSuccess(message: next.message!);
            case NotificationType.error:
              showError(message: next.message!);
            case NotificationType.warning:
              showSimpleInfo(message: next.message!);
          }
        }
      },
    );

    return const SizedBox();
  }
}
