import 'dart:convert';

import 'package:flutter/widgets.dart';

ImageProvider? convertToImage(String? base64Value) {
  if (base64Value != null) {
    final bytes = base64.decode(base64Value);
    return MemoryImage(bytes);
  }
  return null;
}
