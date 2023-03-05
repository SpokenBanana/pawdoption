import 'package:petadopt/animals.dart';
import 'package:sqflite/sqflite.dart';

class LikedDb {
  late Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE Liked(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          protoString TEXT NOT NULL)
      ''');
    });
  }

  Future<List<Animal>> getAll() async {
    List<Map<String, dynamic>> maps =
        await db.query('Liked', columns: ['id', 'protoString']);
    if (maps.length > 0) {
      return maps.map((m) => Animal.fromMap(m)).toList();
    }
    return [];
  }

  Future insert(Animal liked) async {
    int id = await db.insert('Liked', liked.toMap());
    liked.dbId = id;
  }

  Future delete(Animal pet) async {
    return await db.delete('Liked', where: 'id = ?', whereArgs: [pet.dbId]);
  }

  Future update(Animal liked) async {
    await db.update('Liked', liked.toMap(),
        where: 'id = ?', whereArgs: [liked.dbId]);
  }
}
