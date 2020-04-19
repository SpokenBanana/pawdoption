import 'package:petadopt/animals.dart';
import 'package:petadopt/protos/animals.pb.dart';
import 'package:sqflite/sqflite.dart';

class Liked {
  String apiId;
  Animal pet;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'apiId': pet.info.apiId,
      'protoString': pet.info.writeToJson(),
    };
    return map;
  }

  Liked.fromMap(Map<String, dynamic> map) {
    apiId = map['apiId'];
    pet = Animal.fromString(map['protoString']);
  }
}

class LikedDb {
  Database db;

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
    List<Map> maps = await db.query('Liked', columns: ['id', 'protoString']);
    if (maps.length > 0) {
      return maps.map((map) => Animal.fromMap(map)).toList();
    }
    return null;
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
