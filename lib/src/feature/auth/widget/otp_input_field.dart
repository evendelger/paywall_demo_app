// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:pinput/pinput.dart';
//

// /// {@template otp_input_field}
// /// Поле ввода кода подтверждения
// /// {@endtemplate}
// class OtpInputField extends StatefulWidget {
//   /// {@macro otp_input_field}
//   const OtpInputField({
//     required this.textEditingController,
//     required this.onCompleted,
//     super.key,
//   });

//   final TextEditingController textEditingController;

//   final ValueChanged<String> onCompleted;

//   @override
//   State<OtpInputField> createState() => _InputCodeState();
// }

// class _InputCodeState extends State<OtpInputField> {
//   static double dimension = 56;

//   PinTheme get _pinTheme => PinTheme(
//     height: dimension,
//     width: dimension,
//     textStyle: AppTypography.bodyMedium,
//     decoration: BoxDecoration(
//       boxShadow: const [],
//       borderRadius: BorderRadius.circular(16),
//       color: AppColors.secondaryBackground,
//     ),
//   );

//   PinTheme get _submittedPinTheme => _pinTheme.copyWith(
//     decoration: BoxDecoration(
//       boxShadow: const [],
//       borderRadius: BorderRadius.circular(15),
//       color: AppColors.secondaryBackground,
//     ),
//   );

//   @override
//   Widget build(BuildContext context) {
//     return Pinput(
//       autofocus: true,
//       closeKeyboardWhenCompleted: false,
//       controller: widget.textEditingController,
//       onClipboardFound: Platform.isIOS
//           ? (value) => widget.textEditingController.text = value
//           : null,
//       hapticFeedbackType: HapticFeedbackType.lightImpact,
//       keyboardType: const TextInputType.numberWithOptions(
//         signed: true,
//         decimal: true,
//       ),
//       onCompleted: widget.onCompleted,
//       defaultPinTheme: _pinTheme,
//       focusedPinTheme: _pinTheme,
//       submittedPinTheme: _submittedPinTheme,
//       inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//     );
//   }
// }
