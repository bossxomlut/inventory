import 'package:flutter/material.dart';

import '../../core/utils/app_remote_config.dart';
import '../../injection/injection.dart';
import '../../route/app_router.dart';
import '../../route/app_router.gr.dart';
import '../../widget/index.dart';
import '../utils/index.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with StateTemplate<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt.get<RemoteAppConfigLoader>().load().whenComplete(() {
        if (getIt.get<RemoteAppConfigService>().isLockedApp) {
          try {
            showDialog(
              context: appRouter.navigatorKey.currentContext!,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return PopScope(canPop: false, child: Container());
              },
            );
          } catch (e) {}
        }
      });

      navigationHandler();
    });
  }

  void navigationHandler() {
    appRouter.replace(LoginRoute());
    return;
    appRouter.goHome();
  }

  @override
  Widget buildBody(BuildContext context) {
    // return ScannerPage(
    //   onBarcodeScanned: (barcode) {},
    // );

    return Stack(
      children: [
        Center(
          child: AppImage.asset(url: 'assets/image/logo.png', width: 200, height: 200),
        ),
        LoadingWidget(),
      ],
    );
  }
}
