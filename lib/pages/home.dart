import 'package:flutter/material.dart';
import '../widgets/visualizaSensores.dart';
import '../widgets/visualizaAlerta.dart';
import 'cadSensores.dart';
import '../widgets/dashboardCard.dart';
import '../widgets/cardUsuario.dart';

class HomePage extends StatefulWidget {
  final String emailUsuario;
  const HomePage({Key? key, required this.emailUsuario}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _abrirCardUsuario() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => CardUsuario(email: widget.emailUsuario),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Estação Meteorológica'),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle, size: 32),
            onPressed: _abrirCardUsuario,
            tooltip: 'Usuário',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card de Sensores com botão de cadastro
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: VisualizaSensores()),
                  SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Cadastrar Sensor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CadastroSensorPage()),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 24),
              // Card do Dashboard
              CardDashboard(),
              SizedBox(height: 24),
              // Card de Alertas
              VisualizaAlerta(),
              SizedBox(height: 24),
              // Botão de usuário (ícone)
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.account_circle, size: 32),
                  label: Text('Ver Usuário'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  onPressed: _abrirCardUsuario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
