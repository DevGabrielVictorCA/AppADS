import 'package:flutter/foundation.dart'; // para debugPrint
import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'models.dart';

class EntregasProvider extends ChangeNotifier {
  final DBHelper _dbHelper = DBHelper();

  List<Entrega> _entregas = [];

  List<Entrega> get entregas => _entregas;

  // --- CARREGAR ENTREGAS ---
  Future<void> carregarEntregas() async {
    _entregas = await _dbHelper.getEntregas();
    notifyListeners();
  }

  Future<void> carregarEntregasDoEntregador(String email) async {
    _entregas = await _dbHelper.getEntregasPorEntregador(email);
    notifyListeners();
  }

  Future<void> carregarEntregasDoReceptor(String email) async {
    _entregas = await _dbHelper.getEntregasPorReceptor(email);
    notifyListeners();
  }

  // --- ADICIONAR / ATUALIZAR / DELETAR ---
  Future<void> adicionarEntrega(Entrega e) async {
    await _dbHelper.insertEntrega(e);
    _entregas.add(e);
    notifyListeners();
  }

  Future<void> atualizarEntrega(Entrega e) async {
    await _dbHelper.updateEntrega(e);
    final index = _entregas.indexWhere((ent) => ent.id == e.id);
    if (index != -1) {
      _entregas[index] = e;
      notifyListeners();
    }
  }

  Future<void> atualizarStatus(Entrega e, String novoStatus) async {
    e.status = novoStatus;
    if (novoStatus == "Concluída") e.concluida = true;
    await _dbHelper.updateEntrega(e);
    final index = _entregas.indexWhere((ent) => ent.id == e.id);
    if (index != -1) {
      _entregas[index] = e;
      notifyListeners();
    }
  }

  Future<void> deletarEntrega(int id) async {
    await _dbHelper.deleteEntrega(id);
    _entregas.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // --- FILTROS ---
  List<Entrega> entregasDoEntregador(String email) {
    return _entregas.where((e) => e.entregadorEmail == email).toList();
  }

  List<Entrega> entregasDoReceptor(String email) {
    return _entregas.where((e) => e.receptorEmail == email).toList();
  }

  // --- REPORTAR PROBLEMA ---
  Future<void> reportarProblema({
    required Entrega entrega,
    required List<String> motivos,
    required String descricao,
  }) async {
    entrega.status = "Problema reportado";
    entrega.motivos = motivos.join(", ");
    entrega.descricao = descricao;
    await _dbHelper.updateEntrega(entrega);

    debugPrint("Problema reportado para entrega #${entrega.id}");
    debugPrint("Motivos: ${entrega.motivos}");
    debugPrint("Descrição: ${entrega.descricao}");

    notifyListeners();
  }
}
