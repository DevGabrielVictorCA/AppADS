class Entrega {
  int? id; // corrigido para int?
  String produto;
  String destino;
  String receptor;
  String entregador;
  String dataEntrega;
  String status;
  bool concluida;

  Entrega({
    this.id,
    required this.produto,
    required this.destino,
    required this.receptor,
    required this.entregador,
    required this.dataEntrega,
    required this.status,
    required this.concluida,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'produto': produto,
      'destino': destino,
      'receptor': receptor,
      'entregador': entregador,
      'dataEntrega': dataEntrega,
      'status': status,
      'concluida': concluida ? 1 : 0, // SQLite não tem bool
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  factory Entrega.fromMap(Map<String, dynamic> map) {
    return Entrega(
      id: map['id'],
      produto: map['produto'],
      destino: map['destino'],
      receptor: map['receptor'],
      entregador: map['entregador'],
      dataEntrega: map['dataEntrega'],
      status: map['status'],
      concluida: map['concluida'] == 1,
    );
  }
}
