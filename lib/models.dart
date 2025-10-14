// models.dart

class Entregador {
  int? id;
  String name;
  String phone;
  String email;
  String address;

  Entregador({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory Entregador.fromMap(Map<String, Object?> map) {
    return Entregador(
      id: map['id'] as int?,
      name: map['nome']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'nome': name,
    'phone': phone,
    'email': email,
    'address': address,
  };
}

class Receptor {
  int? id;
  String name;
  String phone;
  String email;
  String address;

  Receptor({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory Receptor.fromMap(Map<String, Object?> map) {
    return Receptor(
      id: map['id'] as int?,
      name: map['nome']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'nome': name,
    'phone': phone,
    'email': email,
    'address': address,
  };
}

class Entrega {
  int? id;
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
    this.concluida = false,
  });

  factory Entrega.fromMap(Map<String, Object?> map) {
    return Entrega(
      id: map['id'] as int?,
      produto: map['produto']?.toString() ?? '',
      destino: map['destino']?.toString() ?? '',
      receptor: map['receptor']?.toString() ?? '',
      entregador: map['entregador']?.toString() ?? '',
      dataEntrega: map['dataEntrega']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      concluida: (map['concluida'] as int?) == 1,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'produto': produto,
    'destino': destino,
    'receptor': receptor,
    'entregador': entregador,
    'dataEntrega': dataEntrega,
    'status': status,
    'concluida': concluida ? 1 : 0,
  };
}
