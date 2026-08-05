import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paywall_demo/src/core/extension/extension.dart';
import 'package:paywall_demo/src/core/widget/widget.dart';
import 'package:paywall_demo/src/feature/settings/bloc/settings_bloc.dart';
import 'package:paywall_demo/src/feature/settings/enum/theme_type.dart';
import 'package:paywall_demo/src/feature/settings/model/app_device_info.dart';
import 'package:paywall_demo/src/feature/settings/model/settings_data.dart';
import 'package:pub_semver/pub_semver.dart';

AppThemeType _theme(SettingsState state) => state.data.themeType;

// ThemeMode _themeToThemeMode(AppThemeType theme) => switch (theme) {
//   AppThemeType.light => ThemeMode.light,
//   AppThemeType.dark => ThemeMode.dark,
//   AppThemeType.system => ThemeMode.system,
// };

class SettingsScope extends StatelessWidget {
  const SettingsScope({required this.child, super.key});
  final Widget child;

  static const BlocScope<SettingsEvent, SettingsState, SettingsBloc> _scope =
      BlocScope();

  // --- Data --- //

  static ScopeData<Version?> get appVersionOf => _scope.select(
    (state) => state.data.appVersion,
  );

  static ScopeData<AppDeviceInfo?> get appInfoOf => _scope.select(
    (state) => state.data.appInfo,
  );

  static ScopeData<AppConfig?> get appConfigOf => _scope.select(
    (state) => state.data.config,
  );

  static ScopeData<AppThemeType> get appThemeOf => _scope.select(_theme);

  static ScopeData<int> get entryCountOf => _scope.select(
    (state) => state.data.entryCount,
  );

  static ScopeData<bool> get openedIsFirstTimeOf => _scope.select(
    (state) => state.data.entryCount == 0,
  );

  // --- Methods --- //

  static UnaryScopeMethod<AppThemeType> get setTheme => _scope.unary(
    (context, theme) => SettingsEvent.setTheme(themeType: theme),
  );

  static Future<void> openUpdateDialog(
    BuildContext context, {
    bool forceUpdate = false,
  }) async {
    // final localized = context.l10n;
    // final title = forceUpdate
    //     ? localized.updateDialogMandatoryTitle
    //     : localized.updateDialogSimpleTitle;
    // final subTitle = forceUpdate
    //     ? localized.updateDialogMandatorySubtitle
    //     : localized.updateDialogSimpleSubtitle;
    // final buttonTitle = forceUpdate
    //     ? localized.updateDialogMandatoryButton
    //     : localized.updateDialogSimpleButtonPrimary;

    return;

    // return AppRouter.rootNavigatorKey.currentContext?.showModalDialog<void>(
    //   title: title,
    //   isDismissible: !forceUpdate,
    //   subTitle: subTitle,
    //   acceptLabel: buttonTitle,
    //   onAccept: () => UrlLauncher.openUrl(Config.storeUrl),
    // );
  }

  @override
  Widget build(BuildContext context) => BlocProvider<SettingsBloc>(
    create: (context) =>
        SettingsBloc(settingsRepository: context.repository.settings)
          ..add(const SettingsEvent.incrementEntryCount())
          ..add(const SettingsEvent.getData()),
    child: child,
  );
}
