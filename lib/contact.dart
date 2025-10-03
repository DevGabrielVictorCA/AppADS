class Contact {
  int? id;
  String name;
  String phone;
  String email;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  // Converter para Map (SQLite usa isso)
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'phone': phone,
      'email': email,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Criar a partir de Map (quando busca do banco)
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
    );
  }
}
