import 'dart:async';

import 'package:flutter/material.dart';

/// {@template otp_timer}
/// Отсчет времени отправки кода
/// {@endtemplate}
class OtpTimer extends StatefulWidget {
  /// {@macro otp_timer}

  const OtpTimer({
    required this.onOtpSent,
    required this.buttonText,
    required this.timerText,
    super.key,
    this.seconds = 60,
  });

  final VoidCallback onOtpSent;

  final String buttonText;

  final int seconds;

  final String Function(int sec) timerText;

  @override
  State<OtpTimer> createState() => _OtpTimerState();
}

class _OtpTimerState extends State<OtpTimer> {
  @override
  void initState() {
    super.initState();

    startTimer();
  }

  Timer? _timer;

  late int _start = widget.seconds;

  void startTimer() {
    _start = widget.seconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _sendOTP() {
    widget.onOtpSent();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: _start == 0 ? _sendOTP : null,
      style: TextButton.styleFrom(),
      child: _start == 0
          ? Text(widget.buttonText)
          : Text(widget.timerText(_start)),
    );
  }
}
