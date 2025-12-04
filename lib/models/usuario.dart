class Usuario {
  final int? id;
  final String nome;
  final String email;
  final String? senha; // Opcional para exibição

  Usuario({this.id, required this.nome, required this.email, this.senha});

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nome: json['nome'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'email': email,
      if (senha != null) 'senha': senha,
    };
  }
}
