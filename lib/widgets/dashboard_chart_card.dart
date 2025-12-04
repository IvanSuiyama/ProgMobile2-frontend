import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensores.dart';
import '../services/sensores_service.dart';
import '../services/valores_sensor_service.dart';

class DashboardChartCard extends StatefulWidget {
  @override
  _DashboardChartCardState createState() => _DashboardChartCardState();
}

class _DashboardChartCardState extends State<DashboardChartCard> {
  List<Sensor> sensores = [];
  Map<int, double> valoresSensores = {};
  bool carregando = true;
  String tipoSelecionado = 'Todos';
  List<String> tiposDisponiveis = ['Todos'];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => carregando = true);

    try {
      final sensoresData = await SensoresService.listarSensores();
      final valoresData = await ValoresSensorService.obterUltimosValoresTodos();

      setState(() {
        sensores = sensoresData;

        // Processar valores dos sensores
        valoresSensores = {};
        valoresData.forEach((sensorId, valorInfo) {
          if (valorInfo['valor'] != null) {
            valoresSensores[sensorId] = valorInfo['valor'].toDouble();
          }
        });
        // Extrair tipos únicos
        final tipos = sensores.map((s) => s.tipo).toSet().toList();
        tiposDisponiveis = ['Todos', ...tipos];
      });
    } catch (e) {
      print('Erro ao carregar sensores: $e');
    } finally {
      setState(() => carregando = false);
    }
  }

  List<Sensor> get sensoresFiltrados {
    if (tipoSelecionado == 'Todos') {
      return sensores;
    }
    return sensores.where((s) => s.tipo == tipoSelecionado).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blueAccent, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dashboard de Sensores',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                // Dropdown para filtrar por tipo
                DropdownButton<String>(
                  value: tipoSelecionado,
                  onChanged: (String? newValue) {
                    setState(() {
                      tipoSelecionado = newValue!;
                    });
                  },
                  items: tiposDisponiveis.map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),

            if (carregando)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (sensoresFiltrados.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.sensors_off, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum sensor encontrado',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: [
                  // Gráfico de barras
                  Container(
                    height: 300,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxValue() * 1.2,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              if (groupIndex < sensoresFiltrados.length) {
                                final sensor = sensoresFiltrados[groupIndex];
                                final valor = valoresSensores[sensor.id] ?? 0.0;
                                return BarTooltipItem(
                                  '${sensor.nome}\\n${valor.toStringAsFixed(1)} ${sensor.unidade}',
                                  TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final index = value.toInt();
                                if (index >= 0 &&
                                    index < sensoresFiltrados.length) {
                                  final sensor = sensoresFiltrados[index];
                                  return Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      sensor.nome.length > 8
                                          ? '${sensor.nome.substring(0, 8)}...'
                                          : sensor.nome,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return Text('');
                              },
                              reservedSize: 30,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: _getMaxValue() / 5,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              },
                              reservedSize: 40,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _buildBarGroups(),
                        gridData: FlGridData(
                          show: true,
                          drawHorizontalLine: true,
                          drawVerticalLine: false,
                          horizontalInterval: _getMaxValue() / 5,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300],
                              strokeWidth: 1,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // Legenda com informações dos sensores
                  _buildLegenda(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return sensoresFiltrados.asMap().entries.map((entry) {
      final index = entry.key;
      final sensor = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: valoresSensores[sensor.id] ?? 0.0,
            color: _getColorForType(sensor.tipo),
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildLegenda() {
    final tiposUnicos = sensoresFiltrados.map((s) => s.tipo).toSet().toList();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: tiposUnicos.map((tipo) {
        final sensoresTipo = sensoresFiltrados
            .where((s) => s.tipo == tipo)
            .length;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getColorForType(tipo).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _getColorForType(tipo)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getColorForType(tipo),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '$tipo ($sensoresTipo)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getColorForType(tipo),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  double _getMaxValue() {
    if (valoresSensores.isEmpty) return 100.0;
    final maxValor = valoresSensores.values.reduce((a, b) => a > b ? a : b);
    return maxValor * 1.1; // 10% a mais para folga no gráfico
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
}
