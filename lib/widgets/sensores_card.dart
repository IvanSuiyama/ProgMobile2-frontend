import 'package:flutter/material.dart';
import '../models/sensores.dart';
import '../services/sensores_service.dart';
import '../services/valores_sensor_service.dart';
import '../pages/editar_sensor_page.dart';
import '../pages/cadastro_sensor_page.dart';

class SensoresCard extends StatefulWidget {
  final bool showAll;

  const SensoresCard({Key? key, this.showAll = false}) : super(key: key);

  @override
  _SensoresCardState createState() => _SensoresCardState();
}

class _SensoresCardState extends State<SensoresCard> {
  List<Sensor> sensores = [];
  Map<int, Map<String, dynamic>> valoresSensores = {};
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarSensores();
  }

  Future<void> _carregarSensores() async {
    setState(() => carregando = true);

    try {
      final sensoresData = await SensoresService.listarSensores();
      final valoresData = await ValoresSensorService.obterUltimosValoresTodos();

      setState(() {
        sensores = sensoresData;
        valoresSensores = valoresData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar dados: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  Future<void> _deletarSensor(int sensorId, String nome) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Deseja realmente deletar o sensor \"$nome\"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      try {
        final resultado = await SensoresService.deletarSensor(sensorId);

        if (resultado['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                resultado['message'] ?? 'Sensor deletado com sucesso!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _carregarSensores(); // Recarregar lista
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['error'] ?? 'Erro ao deletar sensor'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sensoresExibir = widget.showAll
        ? sensores
        : sensores.take(3).toList();

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sensors, color: Colors.blueAccent, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.showAll ? 'Todos os Sensores' : 'Sensores Recentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                if (!widget.showAll)
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CadastroSensorPage()),
                      );
                      _carregarSensores();
                    },
                    child: Text('Ver Todos'),
                  ),
              ],
            ),
            SizedBox(height: 16),

            if (carregando)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (sensores.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.sensors_off, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum sensor cadastrado',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CadastroSensorPage(),
                            ),
                          );
                          _carregarSensores();
                        },
                        icon: Icon(Icons.add),
                        label: Text('Cadastrar Sensor'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: widget.showAll
                    ? AlwaysScrollableScrollPhysics()
                    : NeverScrollableScrollPhysics(),
                itemCount: sensoresExibir.length,
                itemBuilder: (context, index) {
                  final sensor = sensoresExibir[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getColorForType(sensor.tipo).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _getIconForType(sensor.tipo),
                          color: _getColorForType(sensor.tipo),
                        ),
                      ),
                      title: Text(
                        sensor.nome,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tipo: ${sensor.tipo}'),
                          _buildValorSensor(sensor),
                        ],
                      ),
                      trailing: widget.showAll
                          ? PopupMenuButton<String>(
                              onSelected: (value) async {
                                if (value == 'edit') {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          EditarSensorPage(sensor: sensor),
                                    ),
                                  );
                                  _carregarSensores();
                                } else if (value == 'delete') {
                                  _deletarSensor(sensor.id!, sensor.nome);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blue),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Deletar'),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
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

  IconData _getIconForType(String tipo) {
    final Map<String, IconData> icones = {
      'temperatura': Icons.thermostat,
      'umidade': Icons.water_drop,
      'pressao': Icons.compress,
      'luminosidade': Icons.wb_sunny,
      'velocidade_vento': Icons.air,
    };

    return icones[tipo.toLowerCase()] ?? Icons.sensors;
  }

  Color _getColorForType(String tipo) {
    final Map<String, Color> cores = {
      'temperatura': Colors.red,
      'umidade': Colors.blue,
      'pressao': Colors.green,
      'luminosidade': Colors.orange,
      'velocidade_vento': Colors.purple,
    };

    return cores[tipo.toLowerCase()] ?? Colors.blueAccent;
  }

  Widget _buildValorSensor(Sensor sensor) {
    if (sensor.id == null) {
      return Text('Valor: -- ${sensor.unidade}');
    }

    final valorData = valoresSensores[sensor.id!];

    if (valorData == null || valorData['valor'] == null) {
      return Text(
        'Valor: -- ${sensor.unidade}',
        style: TextStyle(color: Colors.grey),
      );
    }

    final valor = valorData['valor'].toDouble();
    final timestamp = valorData['timestamp'] ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Valor: ${valor.toStringAsFixed(1)} ${sensor.unidade}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _getColorForType(sensor.tipo),
          ),
        ),
        if (timestamp.isNotEmpty)
          Text(
            'Atualizado: ${_formatarTimestamp(timestamp)}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
      ],
    );
  }

  String _formatarTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inMinutes < 1) {
        return 'agora';
      } else if (diff.inMinutes < 60) {
        return '${diff.inMinutes}min atrás';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}h atrás';
      } else {
        return '${diff.inDays}d atrás';
      }
    } catch (e) {
      return 'tempo desconhecido';
    }
  }
}
