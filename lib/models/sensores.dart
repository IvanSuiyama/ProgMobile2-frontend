class Sensor {
  final int? id;
  final String nome;
  final String tipo;
  final String unidade;

  Sensor({
    this.id,
    required this.nome,
    required this.tipo,
    required this.unidade,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'],
      nome: json['nome'] ?? '',
      tipo: json['tipo'] ?? '',
      unidade: json['unidade'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'tipo': tipo,
      'unidade': unidade,
    };
  }
}
