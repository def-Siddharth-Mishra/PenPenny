import 'package:hive/hive.dart';
import 'package:penpenny/domain/entities/app_settings.dart';

part 'app_settings_hive_model.g.dart';

@HiveType(typeId: 3)
class AppSettingsHiveModel extends HiveObject {
  @HiveField(0)
  String? username;

  @HiveField(1)
  int themeColor;

  @HiveField(2)
  String? currency;

  @HiveField(3)
  int themeMode; // 0: system, 1: light, 2: dark

  AppSettingsHiveModel({
    this.username,
    this.themeColor = 0xFF4CAF50,
    this.currency,
    this.themeMode = 0,
  });

  factory AppSettingsHiveModel.fromEntity(AppSettings settings) {
    int themeModeValue;
    switch (settings.themeMode) {
      case AppThemeMode.system:
        themeModeValue = 0;
        break;
      case AppThemeMode.light:
        themeModeValue = 1;
        break;
      case AppThemeMode.dark:
        themeModeValue = 2;
        break;
    }

    return AppSettingsHiveModel(
      username: settings.username,
      themeColor: settings.themeColor,
      currency: settings.currency,
      themeMode: themeModeValue,
    );
  }

  AppSettings toEntity() {
    AppThemeMode themeModeValue;
    switch (themeMode) {
      case 0:
        themeModeValue = AppThemeMode.system;
        break;
      case 1:
        themeModeValue = AppThemeMode.light;
        break;
      case 2:
        themeModeValue = AppThemeMode.dark;
        break;
      default:
        themeModeValue = AppThemeMode.system;
    }

    return AppSettings(
      username: username,
      themeColor: themeColor,
      currency: currency,
      themeMode: themeModeValue,
    );
  }
}