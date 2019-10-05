import 'package:path/path.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';

import 'package:notodo_app/model/nodo_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  final String itemTableName = "nodoTbl";
  final String itemColumnId = "id";
  final String itemColumnItemName = "itemName";
  final String itemColumnDateCreated = "dateCreated";

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, "notodo_db.db");
    var ourDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return ourDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute(
      "CREATE TABLE $itemTableName(id INTEGER PRIMARY KEY, $itemColumnItemName TEXT, $itemColumnDateCreated TEXT)");
    print("Table Created");
  }

  // Insert

  Future<int> saveItem(NoDoItem item) async {
    var dbClient = await db;
    int res = await dbClient.insert("$itemTableName", item.toMap());
    print(res.toString());
    return res;
  }

  // Get

  Future<List> getItems() async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $itemTableName ORDER BY $itemColumnItemName ASC");
    return result.toList();
  }

  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery(
      "SELECT COUNT(*) FROM $itemTableName"
    ));
  }

  Future<NoDoItem> getItem(int id) async {
    var dbClient = await db;
    var result = await dbClient.rawQuery("SELECT * FROM $itemTableName WHERE id = $id");
    if (result.length == 0) return null;
    return new NoDoItem.fromMap(result.first);
  }

  Future<int> deleteItem(int id) async {
    var dbClient = await db;
    return await dbClient.delete(itemTableName,
        where: "$itemColumnId = ?", whereArgs: [id]);
  }

  Future<int> updateItem(NoDoItem item) async {
    var dbClient = await db;
    return await dbClient.update("$itemTableName", item.toMap(),
        where: "$itemColumnId = ?", whereArgs: [item.id]);
  }

  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }

}