import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/index.dart';
import '../../../data/auth/pin_code_repository.dart';
import '../../index.dart';

final pinCodeRepositoryProvider = Provider<PinCodeRepository>(
  (ref) => PinCodeRepositoryImpl(ref.read(securityStorageProvider)),
);

abstract class PinCodeRepository {
  Future<bool> get isSetPinCode;

  Future<String> getPinCode();

  Future<void> savePinCode(SecurityQuestionEntity securityQuestionEntity, String answer, String pin);

  Future<void> updatePinCode(String confirmPin, String newPin);

  Future<bool> checkSecurityQuestion(SecurityQuestionEntity question, String answer);

  List<SecurityQuestionEntity> get securityQuestions;

  Future<void> login(String pin);

  void logout();

  void listenPinCodeChange(Function(String? pin) callback);

  void removePinCodeListener();
}
