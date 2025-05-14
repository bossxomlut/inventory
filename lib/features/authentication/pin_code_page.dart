import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/index.dart';
import '../../domain/repositories/pin_code_repository.dart';
import '../../provider/index.dart';
import '../../routes/app_router.dart';
import '../../shared_widgets/index.dart';
import 'widget/number_pad.dart';
import 'widget/pin_code.dart';

const int maxPinLength = 4;

final GlobalKey<NumberPadState> _numberPadKey = GlobalKey<NumberPadState>();

@RoutePage()
class PinCodePage extends HookConsumerWidget {
  const PinCodePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.appTheme;
    final pinCode = useState('');
    final isError = useState(false);
    final isSetPinCode = useState(false);
    //check setPinCode

    useEffect(() {
      final pinCodeRepository = ref.read(pinCodeRepositoryProvider);
      pinCodeRepository.isSetPinCode.then((value) {
        isSetPinCode.value = value;
      });
      return null;
    }, []);

    //debounce
    final pinCodeDebounce = useDebounced(pinCode.value, Duration(milliseconds: 300));

    useEffect(() {
      if (pinCodeDebounce?.length == maxPinLength) {
        final pinCodeRepository = ref.read(pinCodeRepositoryProvider);

        if (!isSetPinCode.value) {
          // Nếu chưa thiết lập mã PIN, gọi hàm thiết lập mã PIN
          pinCodeRepository
              .savePinCode(
                  SecurityQuestionEntity(
                    id: 1,
                    question: 'Please don not care this model',
                  ),
                  '',
                  pinCodeDebounce!)
              .whenComplete(
            () {
              appRouter.popForced();
            },
          );

          return;
        }

        isError.value = false;

        // Xử lý mã PIN

        pinCodeRepository.login(pinCodeDebounce!).then((_) {
          // Xử lý thành công
          appRouter.goHome();
        }).catchError((error) {
          // Xử lý lỗi
          pinCode.value = '';
          _numberPadKey.currentState?.resetPad();
          isError.value = true;
        });
      }
      return null;
    }, [pinCodeDebounce]);

    if (!isSetPinCode.value) {
      return Scaffold(
        body: Column(
          children: [
            Expanded(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Set Pin-Code', style: theme.headingSemibold20Default),
                    const Gap(40),
                    // Hiển thị các ô tròn mã PIN
                    PinCodeWidget(pinCode.value),
                    SizedBox(
                      height: 20,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: !isError.value
                            ? Text('')
                            : LText(
                                LKey.wrongPinCode,
                                style: theme.textRegular12Inverse,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Bàn phím số
            NumberPad(
              key: _numberPadKey,
              onChanged: (String value) {
                pinCode.value = value;
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LText(LKey.enterPinCode, style: theme.headingSemibold20Default),
                  const Gap(40),
                  // Hiển thị các ô tròn mã PIN
                  PinCodeWidget(pinCode.value),
                  SizedBox(
                    height: 40,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: !isError.value
                          ? Text('')
                          : LText(
                              LKey.wrongPinCode,
                              style: theme.textRegular12Inverse,
                            ),
                    ),
                  ),
                  const Gap(16),
                  // Link Quên mật khẩu
                  // InkWell(
                  //   onTap: () {
                  //     // appRouter.push(ForgotPinCodeRoute());
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(8.0),
                  //     child: LText(
                  //       LKey.forgotPinCode,
                  //       // style: theme.textTheme.titleSmall?.copyWith(
                  //       //   color: theme.colorScheme.secondary,
                  //       // ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          // Bàn phím số
          NumberPad(
            key: _numberPadKey,
            onChanged: (String value) {
              pinCode.value = value;
            },
          ),
        ],
      ),
    );
  }
}
