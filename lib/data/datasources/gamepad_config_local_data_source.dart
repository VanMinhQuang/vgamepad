import 'package:app_controller/data/local/database_service.dart';
import 'package:app_controller/data/models/button_dto.dart';
import 'package:app_controller/data/models/gamepad_dto.dart';
import 'package:sqflite/sqflite.dart';

class GamepadConfigLocalDataSource {
  final DatabaseService _databaseService;

  const GamepadConfigLocalDataSource(this._databaseService);

  Future<void> saveLayout({
    required GamepadDto layout,
    required List<ButtonDto> buttons,
  }) async {
    final db = await _databaseService.database;
    final layoutId = layout.id;
    if (layoutId == null) return;

    await db.transaction((txn) async {
      await txn.insert(
        DatabaseService.layoutTable,
        layout.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete(
        DatabaseService.buttonTable,
        where: 'layout_id = ?',
        whereArgs: [layoutId],
      );

      final batch = txn.batch();
      for (final button in buttons) {
        batch.insert(
          DatabaseService.buttonTable,
          button.toMap(layoutId: layoutId),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<({GamepadDto layout, List<ButtonDto> buttons})?> getLayout() async {
    final db = await _databaseService.database;
    final layouts = await db.query(
      DatabaseService.layoutTable,
      orderBy: 'id ASC',
      limit: 1,
    );
    if (layouts.isEmpty) return null;

    final layout = GamepadDto.fromMap(layouts.first);
    final layoutId = layout.id;
    if (layoutId == null) return null;

    final buttonRows = await db.query(
      DatabaseService.buttonTable,
      where: 'layout_id = ?',
      whereArgs: [layoutId],
    );

    return (
      layout: layout,
      buttons: buttonRows.map((row) => ButtonDto.fromMap(row)).toList(),
    );
  }

  Future<void> updateLayout({
    required GamepadDto layout,
    required List<ButtonDto> buttons,
  }) {
    return saveLayout(layout: layout, buttons: buttons);
  }
}
