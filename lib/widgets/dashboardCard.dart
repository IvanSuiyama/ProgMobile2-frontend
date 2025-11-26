import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/visualizaSensores.dart';

class CardDashboard extends StatefulWidget {
  const CardDashboard({super.key});

  @override
  State<CardDashboard> createState() => _CardDashboardState();
}

class SensorData {
  final String sensor;
  final double valor;
  final DateTime data;

  SensorData(this.sensor, this.valor, this.data);
}

class _CardDashboardState extends State<CardDashboard> {
  List<SensorData> dados = [];
  bool carregando = true;

  int anoSelecionado = DateTime.now().year;
  int mesSelecionado = DateTime.now().month;
  int diaSelecionado = DateTime.now().day;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => carregando = true);
    final sensores = await SensoresService.listarSensores();
    dados = sensores.map<SensorData>((s) {
      DateTime? data;
      if (s['data'] != null) {
        try {
          data = DateTime.parse(s['data']);
        } catch (_) {
          data = DateTime.now();
        }
      } else {
        data = DateTime.now();
      }
      return SensorData(
        s['tipo'] ?? s['nome'] ?? 'Sensor',
        (s['valor'] is num) ? s['valor'].toDouble() : 0.0,
        data,
      );
    }).toList();
    setState(() => carregando = false);
  }

  List<SensorData> filtrar() {
    return dados
        .where(
          (d) =>
              d.data.year == anoSelecionado &&
              d.data.month == mesSelecionado &&
              d.data.day == diaSelecionado,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtrado = filtrar();
    final nomes = filtrado.map((e) => e.sensor).toList();
    final valores = filtrado.map((e) => e.valor).toList();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Gráfico de Sensores",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // ------------------------------
            // FILTROS
            // ------------------------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<int>(
                  value: anoSelecionado,
                  items: [2024, 2025]
                      .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                      .toList(),
                  onChanged: (v) => setState(() => anoSelecionado = v!),
                ),
                DropdownButton<int>(
                  value: mesSelecionado,
                  items: List.generate(
                    12,
                    (i) =>
                        DropdownMenuItem(value: i + 1, child: Text("${i + 1}")),
                  ),
                  onChanged: (v) => setState(() => mesSelecionado = v!),
                ),
                DropdownButton<int>(
                  value: diaSelecionado,
                  items: List.generate(
                    31,
                    (i) =>
                        DropdownMenuItem(value: i + 1, child: Text("${i + 1}")),
                  ),
                  onChanged: (v) => setState(() => diaSelecionado = v!),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ------------------------------
            // GRÁFICO
            // ------------------------------
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final idx = value.toInt();
                          if (idx < nomes.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 8),
                              child: Text(
                                nomes[idx],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    for (int i = 0; i < valores.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: valores[i],
                            color: Colors.blueAccent,
                            width: 22,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                        showingTooltipIndicators: [0],
                      ),
                  ],
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
