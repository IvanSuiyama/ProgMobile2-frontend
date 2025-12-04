import 'package:flutter/material.dart';
import '../services/sensores_service.dart';

class CadastroSensorPage extends StatefulWidget {
  @override
  _CadastroSensorPageState createState() => _CadastroSensorPageState();
}

class _CadastroSensorPageState extends State<CadastroSensorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _unidadeController = TextEditingController();

  String _tipoSelecionado = 'temperatura';
  bool _carregando = false;

  final List<Map<String, dynamic>> _tiposSensor = [
    {
      'valor': 'temperatura',
      'label': 'Temperatura',
      'icon': Icons.thermostat,
      'color': Colors.red,
    },
    {
      'valor': 'umidade',
      'label': 'Umidade',
      'icon': Icons.water_drop,
      'color': Colors.blue,
    },
    {
      'valor': 'pressao',
      'label': 'Pressão',
      'icon': Icons.compress,
      'color': Colors.green,
    },
    {
      'valor': 'luminosidade',
      'label': 'Luminosidade',
      'icon': Icons.wb_sunny,
      'color': Colors.orange,
    },
    {
      'valor': 'velocidade_vento',
      'label': 'Velocidade do Vento',
      'icon': Icons.air,
      'color': Colors.purple,
    },
  ];

  Future<void> _cadastrarSensor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final resultado = await SensoresService.criarSensor(
        nome: _nomeController.text.trim(),
        tipo: _tipoSelecionado,
        unidade: _unidadeController.text.trim(),
      );

      if (resultado['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              resultado['message'] ?? 'Sensor cadastrado com sucesso!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['error'] ?? 'Erro ao cadastrar sensor'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text('Cadastro de Sensor'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),

              // Ícone
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.sensors, size: 50, color: Colors.white),
              ),
              SizedBox(height: 32),

              // Campo Nome
              TextFormField(
                controller: _nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome do Sensor',
                  hintText: 'Ex: Sensor Jardim',
                  prefixIcon: Icon(Icons.label, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite o nome do sensor';
                  }
                  if (value.trim().length < 3) {
                    return 'Nome deve ter pelo menos 3 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Seleção de Tipo
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tipo de Sensor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _tiposSensor.map((tipo) {
                        final isSelected = _tipoSelecionado == tipo['valor'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _tipoSelecionado = tipo['valor'];
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? tipo['color'].withOpacity(0.1)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? tipo['color']
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  tipo['icon'],
                                  color: isSelected
                                      ? tipo['color']
                                      : Colors.grey[600],
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  tipo['label'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? tipo['color']
                                        : Colors.grey[700],
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Campo Unidade
              TextFormField(
                controller: _unidadeController,
                decoration: InputDecoration(
                  labelText: 'Unidade',
                  hintText: 'Ex: °C, %, hPa, lux, m/s',
                  prefixIcon: Icon(Icons.scale, color: Colors.blueAccent),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite a unidade';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),

              // Botão Cadastrar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _cadastrarSensor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _carregando
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Cadastrar Sensor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _unidadeController.dispose();
    super.dispose();
  }
}
