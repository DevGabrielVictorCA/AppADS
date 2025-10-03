import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contact.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDb();
    return _db!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), "contacts.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE contacts (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            phone TEXT,
            email TEXT
          )
        ''');
      },
    );
  }

  Future<int> insertContact(Contact contact) async {
    var dbClient = await db;
    return await dbClient.insert('contacts', contact.toMap());
  }

  Future<List<Contact>> getContacts() async {
    var dbClient = await db;
    List<Map<String, dynamic>> maps = await dbClient.query('contacts');
    return maps.map((c) => Contact.fromMap(c)).toList();
  }

  Future<int> updateContact(Contact contact) async {
    var dbClient = await db;
    return await dbClient.update(
      'contacts',
      contact.toMap(),
      where: "id = ?",
      whereArgs: [contact.id],
    );
  }

  Future<int> deleteContact(int id) async {
    var dbClient = await db;
    return await dbClient.delete(
      'contacts',
      where: "id = ?",
      whereArgs: [id],
    );
  }
}
