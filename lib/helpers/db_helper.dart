import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'cart.db'),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE cart(id INT PRIMARY KEY,name TEXT,style TEXT,'
            'price REAL,volume REAL,stock INT,rating REAL,checkins INT,'
            'abv REAL,imageUrl TEXT,userRating REAL,quantity INT)');
      },
      version: 1,
    );
  }

  static Future<void> insert(String table, Map<String, Object?> data) async {
    final db = await DBHelper.database();
    db.insert(
      table,
      data,
      conflictAlgorithm: sql.ConflictAlgorithm.replace,
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DBHelper.database();
    return db.query(table);
  }

  static Future<void> removeItem(String table, int productId) async {
    final db = await DBHelper.database();
    db.delete(table, where: 'id=$productId');
  }

  static Future<void> clear(String table) async {
    final db = await DBHelper.database();
    sql.deleteDatabase(db.path);
  }
}
