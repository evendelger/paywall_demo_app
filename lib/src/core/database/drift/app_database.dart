import 'package:drift/drift.dart';
import 'package:paywall_demo/src/core/database/drift/connection/open_connection_io.dart'
    as connection;
import 'package:paywall_demo/src/feature/user/database/dao/user_dao.dart';
import 'package:paywall_demo/src/feature/user/database/table/users.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Users], daos: [UserDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase({required String name}) : super(connection.openConnection(name));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {},
    beforeOpen: (details) async {
      // Включение поддержки внешних ключей
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
