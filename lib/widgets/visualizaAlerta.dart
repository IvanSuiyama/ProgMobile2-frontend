import 'package:flutter/material.dart';
import '../auth/authService.dart';

class VisualizaAlerta extends StatefulWidget {
  const VisualizaAlerta({Key? key}) : super(key: key);

  @override
  State<VisualizaAlerta> createState() => _VisualizaAlertaState();
}

class _VisualizaAlertaState extends State<VisualizaAlerta> {
  List<dynamic> alertas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAlertas();
  }

  Future<void> _carregarAlertas() async {
    setState(() => carregando = true);
    alertas = await AlertaService.listarAlertas();
    setState(() => carregando = false);
  }

  void _excluirAlerta(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Excluir Alerta'),
        content: Text('Deseja realmente excluir este alerta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Excluir'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final resultado = await AlertaService.deletarAlerta(id);
      if (resultado['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Alerta excluído com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _carregarAlertas();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['error'] ?? 'Erro ao excluir alerta'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              'Alertas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 12),
            carregando
                ? Center(child: CircularProgressIndicator())
                : alertas.isEmpty
                ? Text(
                    'Nenhum alerta cadastrado.',
                    style: TextStyle(color: Colors.grey[600]),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: alertas.length,
                    itemBuilder: (context, index) {
                      final alerta = alertas[index];
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.warning, color: Colors.red),
                          title: Text(
                            alerta['nome'] ?? '',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _excluirAlerta(alerta['id']),
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

class AlertaService {
  static const String baseUrl = "http://SEU_SERVIDOR/alertas";

  static Future<List<dynamic>> listarAlertas() async {
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

  static Future<Map<String, dynamic>> deletarAlerta(int id) async {
    try {
      final response = await AuthService.deleteRequest("$baseUrl/$id");
      if (response.statusCode == 200) {
        return {"success": true};
      } else {
        return {
          "success": false,
          "error": response.data != null && response.data["detail"] != null
              ? response.data["detail"]
              : "Erro ao excluir",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Erro de conexão"};
    }
  }
}
