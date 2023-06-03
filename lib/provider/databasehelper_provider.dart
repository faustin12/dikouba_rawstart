import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final _databaseVersion = 5;
  static final _databaseName = "dikouba_mobile_saver_v$_databaseVersion.db";

  static final TABLE_USER= 'user';

  // Columns definition
  static final COLUMN_USER_PHONE = 'phone';
  static final COLUMN_USER_NBREFOLLOWING = 'nbre_following';
  static final COLUMN_USER_PASSWORD = 'password';
  static final COLUMN_USER_IDUSERS = 'id_users';
  static final COLUMN_USER_PHOTOURL = 'photo_url';
  static final COLUMN_USER_EMAILVERIFIED = 'email_verified';
  static final COLUMN_USER_CREATEDAT = 'created_at';
  static final COLUMN_USER_UPDATEAT = 'updated_at';
  static final COLUMN_USER_EMAIL = 'email';
  static final COLUMN_USER_EXPIREDATE = 'expire_date';
  static final COLUMN_USER_PASSWORDHASH = 'password_hash';
  static final COLUMN_USER_NAME = 'name';
  static final COLUMN_USER_NBREFOLLOWERS = 'nbre_followers';
  static final COLUMN_USER_UID = 'uid';
  static final COLUMN_USER_IDANNONCER = 'id_annoncers';
  static final COLUMN_USER_ANNONCER_COMPAGNY = 'annoncer_compagny';
  static final COLUMN_USER_ANNONCER_CREATEDAT = 'annoncer_created_at';
  static final COLUMN_USER_ANNONCER_UPDATEAT = 'annoncer_updated_at';
  static final COLUMN_USER_ANNONCER_PICTUREPATH = 'annoncer_picture_path';
  static final COLUMN_USER_ANNONCER_COVERPICTUREPATH = 'annoncer_cover_picture_path';
  static final COLUMN_USER_ANNONCER_CHECKOUTPHONE = 'annoncer_checkout_phone_number';

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    print("_initDatabase hidatabase");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {

    await db.execute('''
          CREATE TABLE $TABLE_USER (
            ${COLUMN_USER_CREATEDAT} TEXT,
            ${COLUMN_USER_UPDATEAT} TEXT,
            ${COLUMN_USER_EMAIL} TEXT,
            ${COLUMN_USER_EMAILVERIFIED} TEXT,
            ${COLUMN_USER_EXPIREDATE} TEXT,
            ${COLUMN_USER_IDUSERS} TEXT,
            ${COLUMN_USER_NAME} TEXT,
            ${COLUMN_USER_NBREFOLLOWERS} TEXT,
            ${COLUMN_USER_NBREFOLLOWING} TEXT,
            ${COLUMN_USER_PASSWORD} TEXT,
            ${COLUMN_USER_PASSWORDHASH} TEXT,
            ${COLUMN_USER_PHONE} TEXT,
            ${COLUMN_USER_PHOTOURL} TEXT,
            ${COLUMN_USER_UID} TEXT,
            ${COLUMN_USER_IDANNONCER} TEXT,
            ${COLUMN_USER_ANNONCER_CHECKOUTPHONE} TEXT,
            ${COLUMN_USER_ANNONCER_COMPAGNY} TEXT,
            ${COLUMN_USER_ANNONCER_UPDATEAT} TEXT,
            ${COLUMN_USER_ANNONCER_CREATEDAT} TEXT,
            ${COLUMN_USER_ANNONCER_COVERPICTUREPATH} TEXT,
            ${COLUMN_USER_ANNONCER_PICTUREPATH} TEXT
          )
          ''');
  }

  // inserted row._
  Future<int> insert_user(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.insert(TABLE_USER, row);
  }

  // inserted row._
  Future<int> update_user(Map<String, dynamic> row) async {
    Database? db = await instance.database;
    return await db!.update(TABLE_USER, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns._
  Future<List<Map<String, dynamic>>> query_user() async {
    Database? db = await instance.database;
    return await db!.query(TABLE_USER);
  }
  Future<int> delete_user() async {
    Database? db = await instance.database;
    return await db!.delete(TABLE_USER);
  }
}
