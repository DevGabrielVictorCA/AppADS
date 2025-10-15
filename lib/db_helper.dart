import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'meu_app.db');
    return await openDatabase(
      path,
      version: 7, // versao atualizada para garantir upgrade
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela usuarios
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

    // Tabela entregas com todas as colunas existentes
    await db.execute('''
      CREATE TABLE entregas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        produto TEXT,
        destino TEXT,
        receptor TEXT,
        receptorEmail TEXT DEFAULT '',
        entregador TEXT,
        entregadorEmail TEXT DEFAULT '',
        dataEntrega TEXT,
        status TEXT,
        concluida INTEGER,
        motivos TEXT DEFAULT '',
        descricao TEXT DEFAULT ''
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint("Atualizando banco da versão $oldVersion para $newVersion");
    if (oldVersion < 7) {
      final columns = await db.rawQuery("PRAGMA table_info(entregas)");
      final existing = columns.map((c) => c['name'].toString()).toList();

      if (!existing.contains('entregadorEmail')) {
        await db.execute("ALTER TABLE entregas ADD COLUMN entregadorEmail TEXT DEFAULT ''");
      }
      if (!existing.contains('receptorEmail')) {
        await db.execute("ALTER TABLE entregas ADD COLUMN receptorEmail TEXT DEFAULT ''");
      }
      if (!existing.contains('motivos')) {
        await db.execute("ALTER TABLE entregas ADD COLUMN motivos TEXT DEFAULT ''");
      }
      if (!existing.contains('descricao')) {
        await db.execute("ALTER TABLE entregas ADD COLUMN descricao TEXT DEFAULT ''");
      }
    }
  }

  // ===================== USUÁRIOS =====================
  Future<int> inserirUsuario(String nome, String email, String senha, String tipoUsuario,
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

  Future<int> updateUsuario(int id, String nome, String email, String senha,
      String tipoUsuario,
      {String? telefone, String? endereco}) async {
    final db = await database;

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

  Future<Map<String, Object?>?> autenticarUsuario(String email, String senha) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, Object?>?> getUsuarioById(int id) async {
    final db = await database;
    final result = await db.query('usuarios', where: 'id = ?', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> deleteUsuario(int id) async {
    final db = await database;
    return await db.delete('usuarios', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Entregador>> getEntregadores() async {
    final db = await database;
    final result = await db.query('usuarios', where: 'tipoUsuario = ?', whereArgs: ['Entregador']);
    return result.map((e) => Entregador.fromMap(e)).toList();
  }

  Future<List<Receptor>> getReceptores() async {
    final db = await database;
    final result = await db.query('usuarios', where: 'tipoUsuario = ?', whereArgs: ['Receptor']);
    return result.map((e) => Receptor.fromMap(e)).toList();
  }

  // ===================== ENTREGAS =====================
  Future<int> insertEntrega(Entrega entrega) async {
    final db = await database;
    return await db.insert('entregas', entrega.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateEntrega(Entrega e) async {
    final db = await database;
    return await db.update('entregas', e.toMap(), where: 'id = ?', whereArgs: [e.id]);
  }

  Future<int> deleteEntrega(int id) async {
    final db = await database;
    return await db.delete('entregas', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Entrega>> getEntregas() async {
    final db = await database;
    final result = await db.query('entregas');
    return result.map((e) => Entrega.fromMap(e)).toList();
  }

  Future<List<Entrega>> getEntregasPorEntregador(String email) async {
    final db = await database;
    final result = await db.query('entregas', where: 'entregadorEmail = ?', whereArgs: [email]);
    return result.map((e) => Entrega.fromMap(e)).toList();
  }

  Future<List<Entrega>> getEntregasPorReceptor(String email) async {
    final db = await database;
    final result = await db.query('entregas', where: 'receptorEmail = ?', whereArgs: [email]);
    return result.map((e) => Entrega.fromMap(e)).toList();
  }

  // ===================== REPORTAR PROBLEMA =====================
  Future<void> reportarProblema(Entrega entrega, String motivos, String descricao) async {
    debugPrint("Problema reportado para entrega #${entrega.id}");
    debugPrint("Motivos: $motivos");
    debugPrint("Descrição: $descricao");

    entrega.status = "Problema reportado";
    entrega.motivos = motivos;
    entrega.descricao = descricao;
    await updateEntrega(entrega);
  }

  // ===================== OUTROS MÉTODOS =====================
  Future<void> limparTudo() async {
    final db = await database;
    await db.delete('usuarios');
    await db.delete('entregas');
  }

  Future<void> inserirUsuariosPadrao() async {
    final db = await database;

    const senhaPadrao = '123456';
    const numero = 'NUMERODERA';

    final usuariosPadrao = [
      {
        'nome': 'Gestor',
        'email': '$numero@admin.com',
        'senha': senhaPadrao,
        'tipoUsuario': 'Gestor',
      },
      {
        'nome': 'Entregador',
        'email': '$numero@entregador.com',
        'senha': senhaPadrao,
        'tipoUsuario': 'Entregador',
      },
      {
        'nome': 'Receptor',
        'email': '$numero@cliente.com',
        'senha': senhaPadrao,
        'tipoUsuario': 'Receptor',
      },
    ];

    for (var user in usuariosPadrao) {
      final existe = await db.query(
        'usuarios',
        where: 'email = ?',
        whereArgs: [user['email']],
      );

      if (existe.isEmpty) {
        await db.insert('usuarios', user);
        debugPrint('✅ Usuário padrão criado: ${user['email']}');
      }
    }
  }
}
