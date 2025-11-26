import 'package:flutter/material.dart';
import '../auth/authService.dart';

class CadastroSensorPage extends StatefulWidget {
  @override
  _CadastroSensorPageState createState() => _CadastroSensorPageState();
}

class _CadastroSensorPageState extends State<CadastroSensorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _tipoController = TextEditingController();
  final _valorController = TextEditingController();
  final _unidadeController = TextEditingController();
  bool _carregando = false;

  void _cadastrarSensor() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    final nome = _nomeController.text.trim();
    final tipo = _tipoController.text.trim();
    final valor = double.tryParse(_valorController.text.trim()) ?? 0.0;
    final unidade = _unidadeController.text.trim();

    final resultado = await SensoresService.cadastrarSensor(
      nome,
      tipo,
      valor,
      unidade,
    );

    if (resultado['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sensor cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['error'] ?? 'Erro ao cadastrar sensor'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Sensor')),
      body: _carregando
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(labelText: 'Nome'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o nome' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _tipoController,
                      decoration: InputDecoration(labelText: 'Tipo'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o tipo' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _valorController,
                      decoration: InputDecoration(labelText: 'Valor'),
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o valor' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _unidadeController,
                      decoration: InputDecoration(labelText: 'Unidade'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe a unidade' : null,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _cadastrarSensor,
                      child: Text('Cadastrar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class SensoresService {
  static const String baseUrl = "http://SEU_SERVIDOR/sensores";

  static Future<Map<String, dynamic>> cadastrarSensor(
    String nome,
    String tipo,
    double valor,
    String unidade,
  ) async {
    try {
      final response = await AuthService.postRequest("$baseUrl/", {
        "nome": nome,
        "tipo": tipo,
        "valor": valor,
        "unidade": unidade,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return {"success": true, "sensor": data};
      } else {
        final data = response.data;
        return {
          "success": false,
          "error": data != null && data["detail"] != null
              ? data["detail"]
              : "Erro ao cadastrar",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Erro de conexão"};
    }
  }
}
