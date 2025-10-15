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
  String entregadorEmail;
  String receptorEmail;
  String dataEntrega;
  String status;
  bool concluida;

  // Campos de problema
  String motivos;
  String descricao;

  Entrega({
    this.id,
    required this.produto,
    required this.destino,
    required this.receptor,
    required this.entregador,
    required this.entregadorEmail,
    required this.receptorEmail,
    required this.dataEntrega,
    required this.status,
    this.concluida = false,
    this.motivos = '',
    this.descricao = '',
  });

  Entrega copyWith({
    int? id,
    String? produto,
    String? destino,
    String? receptor,
    String? entregador,
    String? entregadorEmail,
    String? receptorEmail,
    String? dataEntrega,
    String? status,
    bool? concluida,
    String? motivos,
    String? descricao,
  }) {
    return Entrega(
      id: id ?? this.id,
      produto: produto ?? this.produto,
      destino: destino ?? this.destino,
      receptor: receptor ?? this.receptor,
      entregador: entregador ?? this.entregador,
      entregadorEmail: entregadorEmail ?? this.entregadorEmail,
      receptorEmail: receptorEmail ?? this.receptorEmail,
      dataEntrega: dataEntrega ?? this.dataEntrega,
      status: status ?? this.status,
      concluida: concluida ?? this.concluida,
      motivos: motivos ?? this.motivos,
      descricao: descricao ?? this.descricao,
    );
  }

  factory Entrega.fromMap(Map<String, Object?> map) {
    return Entrega(
      id: map['id'] as int?,
      produto: map['produto']?.toString() ?? '',
      destino: map['destino']?.toString() ?? '',
      receptor: map['receptor']?.toString() ?? '',
      entregador: map['entregador']?.toString() ?? '',
      entregadorEmail: map['entregadorEmail']?.toString() ?? '',
      receptorEmail: map['receptorEmail']?.toString() ?? '',
      dataEntrega: map['dataEntrega']?.toString() ?? '',
      status: map['status']?.toString() ?? '',
      concluida: (map['concluida'] as int?) == 1,
      motivos: map['motivos']?.toString() ?? '',
      descricao: map['descricao']?.toString() ?? '',
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'produto': produto,
    'destino': destino,
    'receptor': receptor,
    'entregador': entregador,
    'entregadorEmail': entregadorEmail,
    'receptorEmail': receptorEmail,
    'dataEntrega': dataEntrega,
    'status': status,
    'concluida': concluida ? 1 : 0,
    'motivos': motivos,
    'descricao': descricao,
  };
}
