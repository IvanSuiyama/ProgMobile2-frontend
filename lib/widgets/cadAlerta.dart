import 'package:flutter/material.dart';
import '../auth/authService.dart';

class CadAlerta extends StatefulWidget {
  final double temperatura;
  final double umidade;
  const CadAlerta({required this.temperatura, required this.umidade, Key? key})
    : super(key: key);

  @override
  State<CadAlerta> createState() => _CadAlertaState();
}

class _CadAlertaState extends State<CadAlerta> {
  bool alertaCriado = false;
  String? mensagemAlerta;

  @override
  void didUpdateWidget(covariant CadAlerta oldWidget) {
    super.didUpdateWidget(oldWidget);
    _verificarCondicoes();
  }

  @override
  void initState() {
    super.initState();
    _verificarCondicoes();
  }

  Future<void> _verificarCondicoes() async {
    if (!alertaCriado) {
      if (widget.temperatura >= 60.0) {
        await _criarAlerta('Temperatura crítica: ${widget.temperatura}°C');
      } else if (widget.umidade <= 10.0) {
        await _criarAlerta('Umidade crítica: ${widget.umidade}%');
      }
    }
  }

  Future<void> _criarAlerta(String nome) async {
    final resultado = await AlertaService.criarAlerta(nome);
    if (resultado['success'] == true) {
      setState(() {
        alertaCriado = true;
        mensagemAlerta = 'Alerta criado: $nome';
      });
    } else {
      setState(() {
        mensagemAlerta = resultado['error'] ?? 'Erro ao criar alerta';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return mensagemAlerta != null
        ? Card(
            margin: EdgeInsets.all(16),
            color: Colors.red[100],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      mensagemAlerta!,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : SizedBox.shrink();
  }
}

class AlertaService {
  static const String baseUrl = "http://SEU_SERVIDOR/alertas";

  static Future<Map<String, dynamic>> criarAlerta(String nome) async {
    try {
      final response = await AuthService.postRequest("$baseUrl/", {
        "nome": nome,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "alerta": response.data};
      } else {
        return {
          "success": false,
          "error": response.data != null && response.data["detail"] != null
              ? response.data["detail"]
              : "Erro ao criar alerta",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Erro de conexão"};
    }
  }
}
