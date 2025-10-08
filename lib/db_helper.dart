import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'contact.dart';
import 'entrega.dart';

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
    String path = join(await getDatabasesPath(), "app.db");
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

        await db.execute('''
          CREATE TABLE entregas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            produto TEXT,
            destino TEXT,
            receptor TEXT,
            entregador TEXT,
            dataEntrega TEXT,
            status TEXT,
            concluida INTEGER
          )
        ''');
      },
    );
  }

  // ------------------ CONTACTS ------------------

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

  // ------------------ ENTREGAS ------------------

  Future<int> insertEntrega(Entrega e) async {
    var dbClient = await db;
    return await dbClient.insert('entregas', e.toMap());
  }

  Future<List<Entrega>> getEntregas() async {
    var dbClient = await db;
    final maps = await dbClient.query('entregas');
    return maps.map((e) => Entrega.fromMap(e)).toList();
  }

  Future<int> updateEntrega(Entrega e) async {
    var dbClient = await db;
    return await dbClient.update(
      'entregas',
      e.toMap(),
      where: 'id = ?',
      whereArgs: [e.id],
    );
  }

  Future<int> deleteEntrega(int id) async {
    var dbClient = await db;
    return await dbClient.delete(
      'entregas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
