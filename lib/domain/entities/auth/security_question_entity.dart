import 'package:equatable/equatable.dart';

class SecurityQuestionEntity extends Equatable {
  SecurityQuestionEntity({required this.id, required this.question});

  final int id;
  final String question;

  @override
  List<Object?> get props => [
        id,
        question,
      ];
}

class SavePinCodeParamEntity {
  SavePinCodeParamEntity({
    required this.question,
    required this.answer,
    required this.pin,
  });

  final SecurityQuestionEntity question;
  final String answer;
  final String pin;
}

class CheckSecurityQuestionParamEntity {
  CheckSecurityQuestionParamEntity({
    required this.question,
    required this.answer,
  });

  final SecurityQuestionEntity question;
  final String answer;
}

class UpdatePinCodeParamEntity {
  UpdatePinCodeParamEntity({
    required this.confirmPin,
    required this.newPin,
  });

  final String confirmPin;
  final String newPin;
}
