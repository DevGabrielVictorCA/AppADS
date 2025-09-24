import 'package:flutter/material.dart';

class EntregasProvider extends ChangeNotifier {
  List<Map<String, String>> _entregas = [
    {
      "endereco": "Rua A, 123",
      "destinatario": "João Silva",
      "horario": "10:00",
      "status": "Pendente",
    },
    {
      "endereco": "Av. B, 456",
      "destinatario": "Maria Souza",
      "horario": "11:30",
      "status": "Concluída",
    },
    {
      "endereco": "Rua C, 789",
      "destinatario": "Carlos Pereira",
      "horario": "14:00",
      "status": "Atrasada",
    },
  ];

  List<Map<String, String>> get entregas => _entregas;

  void adicionarEntrega(Map<String, String> novaEntrega) {
    _entregas.add(novaEntrega);
    notifyListeners();
  }

  void atualizarStatus(int index, String status) {
    _entregas[index]['status'] = status;
    notifyListeners();
  }
}
