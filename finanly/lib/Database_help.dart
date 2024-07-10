import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;
  static final _dbName = 'my_database.db';
  static final _userTable = 'user';
  static final _dataTable = 'data';

  // User table columns
  static final columnId = '_id';
  static final columnName = 'name';

  // Data table columns
  static final columnDataId = '_id';
  static final columnUserId = 'user_id';
  static final columnLike = 'like_data';
  static final columnFavorite = 'favorite_data';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_userTable (
        $columnId INTEGER PRIMARY KEY,
        $columnName TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE $_dataTable (
        $columnDataId INTEGER PRIMARY KEY,
        $columnUserId INTEGER,
        $columnLike TEXT,
        $columnFavorite TEXT,
        FOREIGN KEY ($columnUserId) REFERENCES $_userTable($columnId)
      )
    ''');
  }

  // Insert user if not exists, or return existing user's id
  Future<int> insertUserIfNotExists(String name) async {
    Database db = await instance.database;

    // Check if the user already exists
    List<Map<String, dynamic>> users = await db.query(
      _userTable,
      where: '$columnName = ?',
      whereArgs: [name],
    );

    if (users.isNotEmpty) {
      // User already exists, return existing user's id
      return users.first[columnId];
    } else {
      // User does not exist, insert new user and return new user's id
      return await db.insert(_userTable, {columnName: name});
    }
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getUsers() async {
    Database db = await instance.database;
    return await db.query(_userTable);
  }

  // Insert data associated with a user
  Future<bool> insertData(int userId, String like, String favorite) async {
    Database db = await instance.database;

    // Check if the data already exists
    List<Map<String, dynamic>> existingData = await db.query(
      _dataTable,
      where: '$columnUserId = ? AND ($columnLike = ? OR $columnFavorite = ?)',
      whereArgs: [userId, like, favorite],
    );

    if (existingData.isNotEmpty) {
      // Data already exists, update with empty values
      await db.update(
        _dataTable,
        {columnLike: '', columnFavorite: ''},
        where: '$columnUserId = ? AND ($columnLike = ? OR $columnFavorite = ?)',
        whereArgs: [userId, like, favorite],
      );
      return false;
    } else {
      // Data does not exist, insert new data
      await db.insert(_dataTable, {
        columnUserId: userId,
        columnLike: like,
        columnFavorite: favorite,
      });
      return true;
    }
  }


  // Get all data associated with a user
  Future<List<Map<String, dynamic>>> getDataForUser(int userId) async {
    Database db = await instance.database;
    return await db.query(_dataTable,
        where: '$columnUserId = ?',
        whereArgs: [userId]);
  }

  // Close database
  Future close() async {
    Database db = await instance.database;
    db.close();
  }
}
