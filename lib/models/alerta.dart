class Alerta {
  final int? id;
  final String nome;
  final DateTime? data;

  Alerta({this.id, required this.nome, this.data});

  factory Alerta.fromJson(Map<String, dynamic> json) {
    return Alerta(
      id: json['id'],
      nome: json['nome'] ?? '',
      data: json['data'] != null ? DateTime.tryParse(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      if (data != null) 'data': data!.toIso8601String(),
    };
  }
}
