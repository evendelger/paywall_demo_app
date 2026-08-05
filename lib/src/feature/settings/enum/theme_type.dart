enum AppThemeType {
  light,
  dark,
  system;

  static AppThemeType fromString(String source) =>
      AppThemeType.values.byName(source);
}
