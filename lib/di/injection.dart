import 'package:app_controller/data/datasources/gamepad_config_local_data_source.dart';
import 'package:app_controller/data/impl/gamepad_config_impl.dart';
import 'package:app_controller/data/local/database_service.dart';
import 'package:app_controller/domain/repository/gamepad_config_repo.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void setUpDI() {
  if (!sl.isRegistered<DatabaseService>()) {
    sl.registerLazySingleton<DatabaseService>(() => DatabaseService());
  }

  if (!sl.isRegistered<GamepadConfigLocalDataSource>()) {
    sl.registerLazySingleton<GamepadConfigLocalDataSource>(
      () => GamepadConfigLocalDataSource(sl<DatabaseService>()),
    );
  }

  if (!sl.isRegistered<GamepadConfigRepo>()) {
    sl.registerLazySingleton<GamepadConfigRepo>(
      () => GamepadConfigImpl(sl<GamepadConfigLocalDataSource>()),
    );
  }
}
