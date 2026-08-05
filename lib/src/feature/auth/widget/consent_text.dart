// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import 'package:paywall_demo/src/feature/settings/scope/settings_scope.dart';

// /// {@template consent_text}
// /// Виджет согласия с правилами (с чекбоксом)
// /// {@endtemplate}
// class ConsentText extends StatelessWidget {
//   /// {@macro consent_text}
//   const ConsentText({
//     required this.isChecked,
//     required this.onChanged,
//     super.key,
//   });

//   /// Состояние чекбокса
//   final bool isChecked;

//   /// Колбек при изменении состояния
//   final ValueChanged<bool?> onChanged;

//   @override
//   Widget build(BuildContext context) {
//     final loc = context.l10n;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             height: 24,
//             width: 24,
//             child: Checkbox(
//               value: isChecked,
//               onChanged: (value) {
//                 if (value ?? false) {
//                   HapticFeedback.selectionClick();
//                 }
//                 return onChanged(value);
//               },
//               materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//               activeColor: AppColors.brand,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(4),
//               ),
//               side: BorderSide(
//                 color: AppColors.tetriary.withValues(alpha: 0.5),
//                 width: 1.5,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(
//                 top: 2,
//               ),
//               child: Text.rich(
//                 TextSpan(
//                   children: SettingsScope.parseConsentText(
//                     context,
//                     loc.consentText,
//                   ),
//                 ),
//                 textAlign: TextAlign.start,
//                 style: const TextStyle(
//                   fontFamily: 'Roboto',
//                   fontWeight: FontWeight.normal,
//                   color: AppColors.tetriary,
//                   height: 1.4,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
