import 'package:drift/drift.dart';

/// Таблица пользователей
@DataClassName('UserEntry')
class Users extends Table {
  // идентификатор в локальной БД
  IntColumn get id => integer().nullable().autoIncrement()();

  /// идентификатор на бэке
  IntColumn get userId => integer()();

  TextColumn get name => text()();

  TextColumn get phone => text()();

  TextColumn get avatar => text().nullable()();

  /// Полная информация модели
  TextColumn get jsonData => text().nullable()();
}
