import 'package:flutter/material.dart';
import '../auth/authService.dart';

class VisualizaSensores extends StatefulWidget {
  @override
  _VisualizaSensoresState createState() => _VisualizaSensoresState();
}

class _VisualizaSensoresState extends State<VisualizaSensores> {
  List<dynamic> sensores = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarSensores();
  }

  Future<void> _carregarSensores() async {
    setState(() => carregando = true);
    sensores = await SensoresService.listarSensores();
    setState(() => carregando = false);
  }

  void _editarSensor(dynamic sensor) async {
    final nomeController = TextEditingController(text: sensor['nome'] ?? '');
    final tipoController = TextEditingController(text: sensor['tipo'] ?? '');
    final valorController = TextEditingController(
      text: sensor['valor']?.toString() ?? '',
    );
    final unidadeController = TextEditingController(
      text: sensor['unidade'] ?? '',
    );

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Sensor'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nomeController,
                  decoration: InputDecoration(labelText: 'Nome'),
                ),
                TextField(
                  controller: tipoController,
                  decoration: InputDecoration(labelText: 'Tipo'),
                ),
                TextField(
                  controller: valorController,
                  decoration: InputDecoration(labelText: 'Valor'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: unidadeController,
                  decoration: InputDecoration(labelText: 'Unidade'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final resultado = await SensoresService.atualizarSensor(
                  sensor['id'],
                  nomeController.text.trim(),
                  tipoController.text.trim(),
                  double.tryParse(valorController.text.trim()),
                  unidadeController.text.trim(),
                );
                Navigator.pop(context);
                if (resultado['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sensor atualizado!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _carregarSensores();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        resultado['error'] ?? 'Erro ao atualizar sensor',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _deletarSensor(int id) async {
    final resultado = await SensoresService.deletarSensor(id);
    if (resultado['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sensor deletado!'),
          backgroundColor: Colors.green,
        ),
      );
      _carregarSensores();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['error'] ?? 'Erro ao deletar sensor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sensores',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 12),
            carregando
                ? Center(child: CircularProgressIndicator())
                : sensores.isEmpty
                ? Text(
                    'Nenhum sensor cadastrado.',
                    style: TextStyle(color: Colors.grey[600]),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: sensores.length,
                    itemBuilder: (context, index) {
                      final sensor = sensores[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          title: Text(
                            sensor['nome'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Tipo: ${sensor['tipo'] ?? ''} | Valor: ${sensor['valor'] ?? ''} ${sensor['unidade'] ?? ''}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editarSensor(sensor),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deletarSensor(sensor['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class SensoresService {
  static Future<Map<String, dynamic>> atualizarSensor(
    int id,
    String nome,
    String tipo,
    double? valor,
    String unidade,
  ) async {
    try {
      final body = {
        if (nome.isNotEmpty) 'nome': nome,
        if (tipo.isNotEmpty) 'tipo': tipo,
        if (valor != null) 'valor': valor,
        if (unidade.isNotEmpty) 'unidade': unidade,
      };
      final response = await AuthService.putRequest("$baseUrl/$id", body);
      if (response.statusCode == 200) {
        return {"success": true, "sensor": response.data};
      } else {
        return {
          "success": false,
          "error": response.data != null && response.data["detail"] != null
              ? response.data["detail"]
              : "Erro ao atualizar",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Erro de conexão"};
    }
  }

  static const String baseUrl = "http://SEU_SERVIDOR/sensores";

  static Future<List<dynamic>> listarSensores() async {
    try {
      final response = await AuthService.getRequest("$baseUrl/");
      if (response.statusCode == 200 && response.data != null) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> deletarSensor(int id) async {
    try {
      final response = await AuthService.deleteRequest("$baseUrl/$id");
      if (response.statusCode == 200) {
        return {"success": true};
      } else {
        return {
          "success": false,
          "error": response.data != null && response.data["detail"] != null
              ? response.data["detail"]
              : "Erro ao deletar",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Erro de conexão"};
    }
  }
}
