import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DBHelper {
  static Database? _db;

  // Retorna a instância do banco de dados
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  // Inicializa o banco
  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'meu_app.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Criação das tabelas
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        email TEXT UNIQUE,
        senha TEXT,
        tipoUsuario TEXT,
        phone TEXT,
        address TEXT
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
  }

  // Atualização do banco
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 4) {
      // Adiciona colunas phone e address se ainda não existirem
      try {
        await db.execute("ALTER TABLE usuarios ADD COLUMN phone TEXT DEFAULT ''");
      } catch (_) {}
      try {
        await db.execute("ALTER TABLE usuarios ADD COLUMN address TEXT DEFAULT ''");
      } catch (_) {}
    }
  }

  // ===================== USUÁRIOS =====================

  // Inserir novo usuário
  Future<int> inserirUsuario(
      String nome, String email, String senha, String tipoUsuario,
      {String? telefone, String? endereco}) async {
    final db = await database;
    return await db.insert(
      'usuarios',
      {
        'nome': nome,
        'email': email,
        'senha': senha,
        'tipoUsuario': tipoUsuario,
        'phone': telefone ?? '',
        'address': endereco ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Atualizar usuário existente
  Future<int> updateUsuario(int id, String nome, String email, String senha,
      String tipoUsuario,
      {String? telefone, String? endereco}) async {
    final db = await database;

    // Mantém a senha atual se não foi informada
    if (senha.isEmpty) {
      final usuarioAtual = await getUsuarioById(id);
      if (usuarioAtual != null) {
        senha = usuarioAtual['senha']?.toString() ?? '';
      }
    }

    return await db.update(
      'usuarios',
      {
        'nome': nome,
        'email': email,
        'senha': senha,
        'tipoUsuario': tipoUsuario,
        'phone': telefone ?? '',
        'address': endereco ?? '',
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Autenticar usuário
  Future<Map<String, Object?>?> autenticarUsuario(
      String email, String senha) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Buscar usuário pelo ID
  Future<Map<String, Object?>?> getUsuarioById(int id) async {
    final db = await database;
    final result = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  // Deletar usuário
  Future<int> deleteUsuario(int id) async {
    final db = await database;
    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  // Listar todos os entregadores
  Future<List<Entregador>> getEntregadores() async {
    final db = await database;
    final result =
    await db.query('usuarios', where: 'tipoUsuario = ?', whereArgs: ['Entregador']);
    return result.map((e) => Entregador.fromMap(e)).toList();
  }

  // Listar todos os receptores
  Future<List<Receptor>> getReceptores() async {
    final db = await database;
    final result =
    await db.query('usuarios', where: 'tipoUsuario = ?', whereArgs: ['Receptor']);
    return result.map((e) => Receptor.fromMap(e)).toList();
  }

  // ===================== ENTREGAS =====================

  // Inserir entrega
  Future<int> insertEntrega(Entrega e) async {
    final db = await database;
    return await db.insert('entregas', e.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Atualizar entrega
  Future<int> updateEntrega(Entrega e) async {
    final db = await database;
    return await db.update('entregas', e.toMap(),
        where: 'id = ?', whereArgs: [e.id]);
  }

  // Deletar entrega
  Future<int> deleteEntrega(int id) async {
    final db = await database;
    return await db.delete('entregas', where: 'id = ?', whereArgs: [id]);
  }

  // Listar entregas
  Future<List<Entrega>> getEntregas() async {
    final db = await database;
    final result = await db.query('entregas');
    return result.map((e) => Entrega.fromMap(e)).toList();
  }

  // ===================== OUTROS =====================

  // Limpar tudo (usuários e entregas)
  Future<void> limparTudo() async {
    final db = await database;
    await db.delete('usuarios');
    await db.delete('entregas');
  }
}
