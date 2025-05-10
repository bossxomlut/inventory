// import 'package:flutter/material.dart';
// import 'package:gap/gap.dart';
//
// import '../../core/utils/app_remote_config.dart';
// import '../../injection/injection.dart';
// import '../../resource/icon_path.dart';
// import '../index.dart';
//
// class SupportIcon extends StatelessWidget {
//   const SupportIcon({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       onPressed: () {
//         final RemoteAppConfigService remoteAppConfigService = getIt.get<RemoteAppConfigService>();
//
//         ShowWebConfigUtils(remoteAppConfigService.supportContact).show(context);
//       },
//       icon: const AppIcon(
//         IconPath.supportAgent,
//         width: 24,
//         height: 24,
//       ),
//     );
//   }
// }
//
// class ContactSupportButton extends StatelessWidget {
//   const ContactSupportButton({super.key, this.buttonType = ButtonType.ghost});
//
//   final ButtonType buttonType;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = context.appTheme;
//     return AppButton(
//       type: buttonType,
//       size: ButtonSize.medium,
//       onPressed: () {
//         final RemoteAppConfigService remoteAppConfigService = getIt.get<RemoteAppConfigService>();
//
//         ShowWebConfigUtils(remoteAppConfigService.supportContact).show(context);
//       },
//       title: LKey.personalProtectionContactCustomerSupport.tr(),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           AppIcon(
//             IconPath.supportAgent,
//             width: 24,
//             height: 24,
//             color: buttonType.getTextColor(context, false),
//           ),
//           const Gap(8),
//           LText(
//             LKey.personalProtectionContactCustomerSupport,
//             style: theme.buttonSemibold15.copyWith(
//               color: buttonType.getTextColor(context, false),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
