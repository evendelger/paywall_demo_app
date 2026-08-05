// ignore_for_file: avoid_print

/// Переименование шаблона под новый проект.
///
/// Использование:
/// ```bash
/// dart run tool/rename.dart \
///   --name my_app \
///   --bundle-id com.company.myapp \
///   --app-name "My App" \
///   [--scheme myapp] [--domain myapp.com]
/// ```
///
/// Меняет: имя Dart-пакета и все импорты, название приложения,
/// Android namespace/applicationId/MainActivity, iOS bundle id и
/// отображаемое имя, схему и домен deep links.
library;

import 'dart:io';

void main(List<String> args) {
  final options = _parseArgs(args);
  if (options == null) {
    print(_usage);
    exit(64);
  }

  final root = Directory.current;
  final current = _CurrentValues.read(root);

  print('Переименование:');
  print('  пакет:     ${current.packageName} -> ${options.name}');
  print('  bundle id: ${current.bundleId} -> ${options.bundleId}');
  print('  название:  ${current.appName} -> ${options.appName}');
  print('  схема:     ${current.scheme} -> ${options.scheme}');
  print('  домен:     ${current.domain} -> ${options.domain}');
  print('');

  // 1. Dart-пакет: pubspec + все импорты
  _replaceInFile(File('pubspec.yaml'), {
    RegExp('^name: ${current.packageName}\$', multiLine: true):
        'name: ${options.name}',
    RegExp('^description: .*\$', multiLine: true):
        'description: "${options.appName}"',
  });
  _replaceInDir(
    Directory('lib'),
    {RegExp('package:${current.packageName}/'): 'package:${options.name}/'},
    extensions: {'.dart'},
  );
  _replaceInDir(
    Directory('test'),
    {RegExp('package:${current.packageName}/'): 'package:${options.name}/'},
    extensions: {'.dart'},
  );

  // 2. Название приложения и namespace SharedPreferences
  _replaceInFile(File('lib/src/core/constant/config.dart'), {
    RegExp("appName = '.*'"): "appName = '${options.appName}'",
    RegExp("prefsNamespace = '.*'"): "prefsNamespace = '${options.name}'",
  });
  _replaceInFile(File('lib/src/core/constant/l10n/arb/app_ru.arb'), {
    RegExp('"appName": ".*"'): '"appName": "${options.appName}"',
  });

  // 3. Android
  final packagePath = options.bundleId.replaceAll('.', '/');
  _replaceInDir(
    Directory('android'),
    {
      RegExp(RegExp.escape(current.bundleId)): options.bundleId,
      RegExp('"${RegExp.escape(current.appName)} \\(dev\\)"'):
          '"${options.appName} (dev)"',
      RegExp('"${RegExp.escape(current.appName)}"'): '"${options.appName}"',
      RegExp('android:host="${RegExp.escape(current.domain)}"'):
          'android:host="${options.domain}"',
      RegExp('android:scheme="${RegExp.escape(current.scheme)}"'):
          'android:scheme="${options.scheme}"',
    },
    extensions: {'.kts', '.gradle', '.xml', '.kt'},
  );
  _moveMainActivity(current.bundleId, packagePath);

  // 4. iOS
  _replaceInFile(File('ios/Runner.xcodeproj/project.pbxproj'), {
    RegExp(RegExp.escape(current.bundleId)): options.bundleId,
    RegExp(RegExp.escape(current.appName)): options.appName,
  });
  _replaceInFile(File('ios/Runner/Info.plist'), {
    RegExp('<string>${RegExp.escape(current.appName)}</string>'):
        '<string>${options.appName}</string>',
    RegExp('<string>${RegExp.escape(current.scheme)}</string>'):
        '<string>${options.scheme}</string>',
    RegExp('applinks:${RegExp.escape(current.domain)}'):
        'applinks:${options.domain}',
  });

  print('');
  print('Готово. Дальше:');
  print('  1. flutter pub get');
  print('  2. flutter gen-l10n');
  print('  3. dart run build_runner build -d');
  print('  4. Обновить API_BASE_URL в config/*.json');
  print('  5. Заменить иконку и splash (assets/), затем `make splash`');
}

const _usage = '''
Использование:
  dart run tool/rename.dart --name <dart_package> --bundle-id <com.company.app>
                            --app-name "<App Name>"
                            [--scheme <deeplink_scheme>] [--domain <example.com>]

  --name       имя Dart-пакета (snake_case), например my_app
  --bundle-id  applicationId / PRODUCT_BUNDLE_IDENTIFIER, например com.company.myapp
  --app-name   отображаемое название приложения, например "My App"
  --scheme     схема deep links (по умолчанию — значение --name без подчёркиваний)
  --domain     домен universal/app links (по умолчанию example.com)
''';

class _Options {
  const _Options({
    required this.name,
    required this.bundleId,
    required this.appName,
    required this.scheme,
    required this.domain,
  });

  final String name;
  final String bundleId;
  final String appName;
  final String scheme;
  final String domain;
}

_Options? _parseArgs(List<String> args) {
  final map = <String, String>{};
  for (var i = 0; i < args.length - 1; i += 2) {
    if (!args[i].startsWith('--')) return null;
    map[args[i].substring(2)] = args[i + 1];
  }

  final name = map['name'];
  final bundleId = map['bundle-id'];
  final appName = map['app-name'];
  if (name == null || bundleId == null || appName == null) return null;

  if (!RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name)) {
    print('Имя пакета должно быть в snake_case: $name');
    return null;
  }
  if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9]*(\.[a-zA-Z][a-zA-Z0-9]*)+$')
      .hasMatch(bundleId)) {
    print('Некорректный bundle id: $bundleId');
    return null;
  }

  return _Options(
    name: name,
    bundleId: bundleId,
    appName: appName,
    scheme: map['scheme'] ?? name.replaceAll('_', ''),
    domain: map['domain'] ?? 'example.com',
  );
}

/// Текущие значения, вычитанные из проекта
class _CurrentValues {
  const _CurrentValues({
    required this.packageName,
    required this.bundleId,
    required this.appName,
    required this.scheme,
    required this.domain,
  });

  factory _CurrentValues.read(Directory root) {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final packageName =
        RegExp(r'^name:\s*(\S+)', multiLine: true)
            .firstMatch(pubspec)
            ?.group(1) ??
        (throw StateError('Не удалось прочитать name из pubspec.yaml'));

    final gradle = File('android/app/build.gradle.kts').readAsStringSync();
    final bundleId =
        RegExp(r'applicationId\s*=\s*"([^"]+)"').firstMatch(gradle)?.group(1) ??
        (throw StateError('Не удалось прочитать applicationId'));

    final config = File('lib/src/core/constant/config.dart').readAsStringSync();
    final appName =
        RegExp("appName = '([^']+)'").firstMatch(config)?.group(1) ??
        (throw StateError('Не удалось прочитать Config.appName'));

    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final scheme =
        RegExp(r'android:scheme="(?!http)([^"]+)"')
            .firstMatch(manifest)
            ?.group(1) ??
        'app';
    final domain =
        RegExp(r'android:host="([^"]+)"').firstMatch(manifest)?.group(1) ??
        'example.com';

    return _CurrentValues(
      packageName: packageName,
      bundleId: bundleId,
      appName: appName,
      scheme: scheme,
      domain: domain,
    );
  }

  final String packageName;
  final String bundleId;
  final String appName;
  final String scheme;
  final String domain;
}

void _replaceInFile(File file, Map<RegExp, String> replacements) {
  if (!file.existsSync()) return;

  final original = file.readAsStringSync();
  var content = original;
  for (final entry in replacements.entries) {
    content = content.replaceAll(entry.key, entry.value);
  }

  if (content != original) {
    file.writeAsStringSync(content);
    print('  изменён ${file.path}');
  }
}

void _replaceInDir(
  Directory dir,
  Map<RegExp, String> replacements, {
  required Set<String> extensions,
}) {
  if (!dir.existsSync()) return;

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File) continue;
    if (!extensions.any(entity.path.endsWith)) continue;
    _replaceInFile(entity, replacements);
  }
}

/// Переносит MainActivity.kt в каталог, соответствующий новому bundle id
void _moveMainActivity(String oldBundleId, String newPackagePath) {
  const kotlinRoot = 'android/app/src/main/kotlin';
  final root = Directory(kotlinRoot);
  if (!root.existsSync()) return;

  final activity = root
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('MainActivity.kt'))
      .firstOrNull;
  if (activity == null) return;

  final target = File('$kotlinRoot/$newPackagePath/MainActivity.kt');
  if (activity.path == target.path) return;

  target.parent.createSync(recursive: true);
  target.writeAsStringSync(activity.readAsStringSync());
  activity.deleteSync();
  print('  перенесён ${activity.path} -> ${target.path}');

  // Чистим опустевшие каталоги старого пакета
  final oldRoot = Directory('$kotlinRoot/${oldBundleId.split('.').first}');
  final isEmpty =
      oldRoot.existsSync() &&
      oldRoot.listSync(recursive: true).whereType<File>().isEmpty;
  if (isEmpty) {
    oldRoot.deleteSync(recursive: true);
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
