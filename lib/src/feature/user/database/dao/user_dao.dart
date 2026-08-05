import 'dart:async';

import 'package:drift/drift.dart';
import 'package:paywall_demo/src/core/database/database.dart';
import 'package:paywall_demo/src/feature/user/data/mappers/user_db_mapper.dart';
import 'package:paywall_demo/src/feature/user/database/table/users.dart';
import 'package:paywall_demo/src/feature/user/model/user.dart';

part 'user_dao.g.dart';

abstract class IUserDao {
  Stream<User?> get user;

  FutureOr<User?> getUser();

  Future<void> upsertUser(User user);

  Future<void> removeAll();
}

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase>
    with _$UserDaoMixin
    implements IUserDao {
  UserDao(super.attachedDatabase);

  @override
  Future<void> upsertUser(User data) async {
    await into(users).insertOnConflictUpdate(data.toDb());
  }

  @override
  Stream<User?> get user => select(users).watchSingleOrNull().map((db) {
    if (db == null) return null;
    return db.toDomain();
  });

  @override
  Future<User?> getUser() async {
    final userDb = await select(users).getSingleOrNull();

    return userDb?.toDomain();
  }

  @override
  Future<void> removeAll() => delete(users).go();
}
