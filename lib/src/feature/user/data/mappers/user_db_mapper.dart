import 'dart:convert';

import 'package:paywall_demo/src/core/database/database.dart';
import 'package:paywall_demo/src/core/utils/logger.dart';
import 'package:paywall_demo/src/feature/user/model/user.dart';

extension UserDbMapper on User {
  UserEntry toDb() {
    return UserEntry(
      id: 0,
      userId: id,
      name: name,
      phone: phone,
      avatar: avatar,
      // Сериализуем ВСЮ модель в JSON
      jsonData: jsonEncode(toJson()),
    );
  }
}

extension UserEntryMapper on UserEntry {
  User toDomain() {
    if (jsonData != null && jsonData!.isNotEmpty) {
      try {
        final data = jsonDecode(jsonData!) as Map<String, dynamic>;
        return User.fromJson(data);
      } on Object catch (e) {
        mainTalker.error(e);
        // Если JSON битый, логируем и идем в Fallback
      }
    }

    // Fallback: если JSON почему-то пуст, собираем из колонок
    return User(
      id: userId,
      name: name,
      phone: phone,
      avatar: avatar,
      // Остальные поля в fallback будут null,
    );
  }
}
