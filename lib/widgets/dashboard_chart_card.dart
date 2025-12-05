import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensores.dart';
import '../services/sensores_service.dart';
import '../services/valores_sensor_service.dart';

class DashboardChartCard extends StatefulWidget {
  @override
  _DashboardChartCardState createState() => _DashboardChartCardState();
}

class _DashboardChartCardState extends State<DashboardChartCard>
    with TickerProviderStateMixin {
  List<Sensor> sensores = [];
  Map<int, double> valoresSensores = {};
  Map<int, List<Map<String, dynamic>>> historicoSensores = {};
  bool carregando = true;
  String tipoSelecionado = 'Todos';
  List<String> tiposDisponiveis = ['Todos'];
  String periodoSelecionado = 'Tempo Real';
  List<String> periodosDisponiveis = [
    'Tempo Real',
    'Diário',
    'Mensal',
    'Anual',
  ];
  DateTime dataInicio = DateTime.now().subtract(Duration(days: 1));
  DateTime dataFim = DateTime.now();

  // Propriedades para animação e interatividade
  late AnimationController _animationController;
  late Animation<double> _animation;
  int? _touchedLineIndex;
  double _animationProgress = 0.0;

  // Cores dinâmicas para melhor visualização
  static const List<Color> _dynamicColors = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFFEF4444), // Red
    Color(0xFFEC4899), // Pink
    Color(0xFF3B82F6), // Blue
  ];

  @override
  void initState() {
    super.initState();

    // Configuração da animação
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _animation.addListener(() {
      setState(() {
        _animationProgress = _animation.value;
      });
    });

    _carregarDados();
    // Refresh apenas manual através do botão
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _carregarDados() async {
    setState(() => carregando = true);

    try {
      final sensoresData = await SensoresService.listarSensores();

      // Definir período baseado na seleção
      _definirPeriodo();

      // Carregar todos os valores para o período selecionado
      final todosValores = await ValoresSensorService.listarTodosValores(
        limit: _getLimitePorPeriodo(),
      );

      // Organizar os últimos valores e histórico por sensor
      Map<int, double> ultimosValoresPorSensor = {};
      Map<int, List<Map<String, dynamic>>> historicoTemporal = {};

      // Preservar dados históricos existentes
      for (var entry in historicoSensores.entries) {
        historicoTemporal[entry.key] = List.from(entry.value);
      }

      for (var valor in todosValores) {
        int sensorId = valor['id_sensor'];
        double valorSensor = valor['valor'].toDouble();
        DateTime timestamp = DateTime.parse(valor['timestamp']);

        // Filtrar por período selecionado
        if (timestamp.isAfter(dataInicio) && timestamp.isBefore(dataFim)) {
          // Inicializar lista se não existir
          if (!historicoTemporal.containsKey(sensorId)) {
            historicoTemporal[sensorId] = [];
          }

          // Verificar se este timestamp já existe para evitar duplicatas
          final jaExiste = historicoTemporal[sensorId]!.any((ponto) {
            final pontoTime = ponto['timestamp'] as DateTime;
            return pontoTime.millisecondsSinceEpoch ==
                timestamp.millisecondsSinceEpoch;
          });

          // Só adicionar se for um novo ponto
          if (!jaExiste) {
            historicoTemporal[sensorId]!.add({
              'valor': valorSensor,
              'timestamp': timestamp,
            });
          }
        }

        // Sempre atualizar com o valor mais recente
        ultimosValoresPorSensor[sensorId] = valorSensor;
      }

      // Ordenar histórico por timestamp e manter pontos baseado no período
      final maxPontos = _getMaxPontosPorPeriodo();
      historicoTemporal.forEach((sensorId, dados) {
        dados.sort(
          (a, b) => (a['timestamp'] as DateTime).compareTo(
            b['timestamp'] as DateTime,
          ),
        );
        // Manter todos os dados dentro do período, sem cortar o histórico
        // Só limitar se realmente exceder muito para performance
        if (dados.length > maxPontos * 2) {
          historicoTemporal[sensorId] = dados.sublist(dados.length - maxPontos);
        }
      });

      setState(() {
        sensores = sensoresData;
        valoresSensores = ultimosValoresPorSensor;
        historicoSensores = historicoTemporal;

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
                // Chip para filtrar por tipo
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: tipoSelecionado,
                      isDense: true,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
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
                          child: Text(value, style: TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Segmented buttons para período (mais moderno)
                Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: periodosDisponiveis.map((periodo) {
                      final isSelected = periodoSelecionado == periodo;
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              periodoSelecionado = periodo;
                            });
                            _carregarDados();
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              periodo,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 8),
                // Botão de refresh
                IconButton(
                  onPressed: carregando ? null : _carregarDados,
                  icon: Icon(
                    Icons.refresh,
                    color: carregando ? Colors.grey : Colors.blueAccent,
                  ),
                  tooltip: 'Atualizar dados',
                ),
              ],
            ),
            SizedBox(height: 12),
            // Indicador do período atual
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Text(
                _getDescricaoPeriodo(),
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
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
                  // Gráfico de linha dinâmico
                  Container(
                    height: 400,
                    padding: EdgeInsets.all(16),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          drawHorizontalLine: true,
                          horizontalInterval: math.max(_getMaxValue() / 4, 1.0),
                          verticalInterval: math.max(
                            _getTimeInterval() *
                                2, // Mais espaçado para acomodar mais pontos
                            120000.0, // Intervalo mínimo de 2 minutos
                          ),
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!,
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!,
                              strokeWidth: 0.5,
                            );
                          },
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
                              reservedSize: 40,
                              interval: _getTimeInterval(),
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final timestamp =
                                    DateTime.fromMillisecondsSinceEpoch(
                                      value.toInt(),
                                    );
                                return Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    _formatarDataEixo(timestamp),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              interval: _getMaxValue() / 5,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  value.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 10,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        minX: _getMinTime(),
                        maxX: _getMaxTime(),
                        minY: 0,
                        maxY: _getMaxValue() * 1.1,
                        lineBarsData: _buildLineChartData(),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: true,
                          touchCallback:
                              (
                                FlTouchEvent event,
                                LineTouchResponse? touchResponse,
                              ) {
                                setState(() {
                                  if (touchResponse != null &&
                                      touchResponse.lineBarSpots != null) {
                                    _touchedLineIndex = touchResponse
                                        .lineBarSpots!
                                        .first
                                        .barIndex;
                                  } else {
                                    _touchedLineIndex = null;
                                  }
                                });
                              },
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipColor: (touchedSpot) => _getColorForType(
                              sensoresFiltrados[touchedSpot.barIndex].tipo,
                            ).withOpacity(0.95),
                            tooltipBorder: BorderSide.none,
                            tooltipPadding: EdgeInsets.all(12),
                            tooltipMargin: 8,
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                final sensor =
                                    sensoresFiltrados[barSpot.barIndex];
                                final timestamp =
                                    DateTime.fromMillisecondsSinceEpoch(
                                      barSpot.x.toInt(),
                                    );
                                return LineTooltipItem(
                                  '📊 ${sensor.nome}\\n💡 ${barSpot.y.toStringAsFixed(2)} ${sensor.unidade}\\n🕒 ${_formatarDataTooltip(timestamp)}',
                                  TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black26,
                                        offset: Offset(1, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                );
                              }).toList();
                            },
                          ),
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

  List<LineChartBarData> _buildLineChartData() {
    return sensoresFiltrados.asMap().entries.map((entry) {
      final sensor = entry.value;
      final historico = historicoSensores[sensor.id] ?? [];

      List<FlSpot> spots = historico.map((ponto) {
        final timestamp = ponto['timestamp'] as DateTime;
        final valor = ponto['valor'] as double;
        return FlSpot(timestamp.millisecondsSinceEpoch.toDouble(), valor);
      }).toList();

      // Se não há histórico, adicionar pelo menos o último valor
      if (spots.isEmpty && valoresSensores.containsKey(sensor.id)) {
        spots.add(
          FlSpot(
            DateTime.now().millisecondsSinceEpoch.toDouble(),
            valoresSensores[sensor.id]!,
          ),
        );
      }

      // Garantir que sempre temos pontos no início e fim do período
      final minTime = dataInicio.millisecondsSinceEpoch.toDouble();
      final maxTime = dataFim.millisecondsSinceEpoch.toDouble();

      // Se não há dados no início do período, adicionar ponto com valor 0
      final temPontoNoInicio = spots.any(
        (spot) => (spot.x - minTime).abs() < 60000,
      ); // 1 minuto de tolerância
      if (!temPontoNoInicio) {
        spots.insert(0, FlSpot(minTime, 0));
      }

      // Se há dados mas nenhum no final do período, adicionar o último valor conhecido
      final temPontoNoFinal = spots.any(
        (spot) => (spot.x - maxTime).abs() < 60000,
      );
      if (!temPontoNoFinal && spots.isNotEmpty) {
        final ultimoValor = spots.last.y;
        spots.add(FlSpot(maxTime, ultimoValor));
      }

      // Ordenar spots por timestamp (eixo X)
      spots.sort((a, b) => a.x.compareTo(b.x));

      // Remover apenas duplicatas exatas (mesmo timestamp E mesmo valor)
      // para preservar variações nos dados
      Map<String, FlSpot> pontosUnicos = {};
      for (var spot in spots) {
        final key = '${spot.x.toInt()}';
        // Se já existe um ponto neste timestamp, manter o mais recente
        if (!pontosUnicos.containsKey(key) || pontosUnicos[key]!.y != spot.y) {
          pontosUnicos[key] = spot;
        }
      }
      spots = pontosUnicos.values.toList();
      spots.sort((a, b) => a.x.compareTo(b.x));

      // Se ainda não há dados suficientes, criar uma linha base
      if (spots.isEmpty) {
        // Criar linha com valor 0 do início ao fim do período
        spots = [FlSpot(minTime, 0), FlSpot(maxTime, 0)];
      } else if (spots.length == 1) {
        // Se há apenas um ponto, estender do início ao fim
        final valorUnico = spots.first.y;
        spots = [FlSpot(minTime, 0), spots.first, FlSpot(maxTime, valorUnico)];
      }

      final sensorIndex = entry.key;
      final isSelected = _touchedLineIndex == sensorIndex;

      return LineChartBarData(
        spots: spots,
        isCurved: true, // Linhas curvas para visual mais suave
        color: _getColorForType(sensor.tipo),
        barWidth: isSelected ? 4 : 2.5,
        isStrokeCapRound: true,
        gradient: LinearGradient(
          colors: [
            _getColorForType(sensor.tipo),
            _getColorForType(sensor.tipo).withOpacity(0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        dotData: FlDotData(
          show: true, // Sempre mostrar as bolinhas
          getDotPainter: (spot, percent, barData, index) {
            // Calcular a idade do ponto para dar diferentes visuais
            final agora = DateTime.now().millisecondsSinceEpoch.toDouble();
            final idadePonto = agora - spot.x;
            final isRecente = idadePonto < (5 * 60 * 1000); // Últimos 5 minutos

            return FlDotCirclePainter(
              radius: isSelected
                  ? 7
                  : (isRecente ? 5 : 4), // Pontos recentes maiores
              color: isRecente
                  ? _getColorForType(sensor.tipo)
                  : _getColorForType(
                      sensor.tipo,
                    ).withOpacity(0.8), // Pontos antigos mais transparentes
              strokeWidth: isRecente ? 3 : 2,
              strokeColor: isRecente ? Colors.white : Colors.grey[300]!,
            );
          },
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              _getColorForType(
                sensor.tipo,
              ).withOpacity(0.3 * _animationProgress),
              _getColorForType(
                sensor.tipo,
              ).withOpacity(0.05 * _animationProgress),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        shadow: Shadow(
          color: _getColorForType(sensor.tipo).withOpacity(0.4),
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      );
    }).toList();
  }

  double _getMinTime() {
    // Sempre usar o início do período definido para que o gráfico comece do zero
    return dataInicio.millisecondsSinceEpoch.toDouble();
  }

  double _getMaxTime() {
    // Sempre usar o final do período definido para que o gráfico se estenda até o fim
    return dataFim.millisecondsSinceEpoch.toDouble();
  }

  double _getTimeInterval() {
    final range = _getMaxTime() - _getMinTime();

    // Calcular intervalo baseado no período selecionado para melhor distribuição
    switch (periodoSelecionado) {
      case 'Tempo Real':
        return range / 10; // 10 divisões para os últimos 10 minutos
      case 'Diário':
        return range / 12; // 12 divisões (2 horas cada)
      case 'Mensal':
        return range / 15; // 15 divisões (2 dias cada)
      case 'Anual':
        return range / 12; // 12 divisões (1 mês cada)
      default:
        return range / 8; // 8 divisões padrão
    }
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
    // Usar hash do tipo para garantir cor consistente e dinâmica
    final hash = tipo.toLowerCase().hashCode;
    return _dynamicColors[hash.abs() % _dynamicColors.length];
  }

  void _definirPeriodo() {
    final agora = DateTime.now();

    switch (periodoSelecionado) {
      case 'Tempo Real':
        dataInicio = agora.subtract(
          Duration(minutes: 10),
        ); // Últimos 10 minutos
        dataFim = agora;
        break;
      case 'Diário':
        dataInicio = DateTime(agora.year, agora.month, agora.day);
        dataFim = agora;
        break;
      case 'Mensal':
        dataInicio = DateTime(agora.year, agora.month, 1);
        dataFim = agora;
        break;
      case 'Anual':
        dataInicio = DateTime(agora.year, 1, 1);
        dataFim = agora;
        break;
    }
  }

  int _getLimitePorPeriodo() {
    switch (periodoSelecionado) {
      case 'Tempo Real':
        return 200; // Dados dos últimos 10 minutos
      case 'Diário':
        return 500; // ~1 valor por minuto nas últimas 8 horas
      case 'Mensal':
        return 2000; // ~1 valor por hora no último mês
      case 'Anual':
        return 5000; // ~1 valor por dia no último ano
      default:
        return 200;
    }
  }

  int _getMaxPontosPorPeriodo() {
    switch (periodoSelecionado) {
      case 'Tempo Real':
        return 500; // Mostrar muito mais pontos para ver todo o histórico
      case 'Diário':
        return 1000;
      case 'Mensal':
        return 2000;
      case 'Anual':
        return 5000;
      default:
        return 500;
    }
  }

  String _getDescricaoPeriodo() {
    final agora = DateTime.now();

    switch (periodoSelecionado) {
      case 'Diário':
        return 'Dados de hoje (${agora.day.toString().padLeft(2, '0')}/${agora.month.toString().padLeft(2, '0')}/${agora.year})';
      case 'Mensal':
        final nomesMeses = [
          '',
          'Janeiro',
          'Fevereiro',
          'Março',
          'Abril',
          'Maio',
          'Junho',
          'Julho',
          'Agosto',
          'Setembro',
          'Outubro',
          'Novembro',
          'Dezembro',
        ];
        return 'Dados de ${nomesMeses[agora.month]} ${agora.year}';
      case 'Anual':
        return 'Dados do ano ${agora.year}';
      default:
        return '';
    }
  }

  String _formatarDataEixo(DateTime timestamp) {
    switch (periodoSelecionado) {
      case 'Tempo Real':
        return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
      case 'Diário':
        return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
      case 'Mensal':
        return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}';
      case 'Anual':
        final nomesMeses = [
          '',
          'Jan',
          'Fev',
          'Mar',
          'Abr',
          'Mai',
          'Jun',
          'Jul',
          'Ago',
          'Set',
          'Out',
          'Nov',
          'Dez',
        ];
        return '${nomesMeses[timestamp.month]}';
      default:
        return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    }
  }

  String _formatarDataTooltip(DateTime timestamp) {
    switch (periodoSelecionado) {
      case 'Diário':
        return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}h';
      case 'Mensal':
        return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')} às ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}h';
      case 'Anual':
        final nomesMeses = [
          '',
          'Jan',
          'Fev',
          'Mar',
          'Abr',
          'Mai',
          'Jun',
          'Jul',
          'Ago',
          'Set',
          'Out',
          'Nov',
          'Dez',
        ];
        return '${timestamp.day}/${nomesMeses[timestamp.month]}/${timestamp.year}';
      default:
        return '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}h';
    }
  }
}
