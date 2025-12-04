import 'package:flutter/material.dart';
import '../services/alerta_monitor_service.dart';

class MonitoramentoInfoCard extends StatefulWidget {
  const MonitoramentoInfoCard({Key? key}) : super(key: key);

  @override
  State<MonitoramentoInfoCard> createState() => _MonitoramentoInfoCardState();
}

class _MonitoramentoInfoCardState extends State<MonitoramentoInfoCard> {
  List<String> alertasDetectados = [];
  bool carregando = false;

  @override
  void initState() {
    super.initState();
    _verificarCondicoes();
  }

  Future<void> _verificarCondicoes() async {
    setState(() => carregando = true);

    try {
      final alertas = await AlertaMonitorService.verificarCondicoesManual();
      setState(() => alertasDetectados = alertas);
    } catch (e) {
      print('Erro ao verificar condições: $e');
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAtivo = AlertaMonitorService.isMonitorandoAtivo;
    final totalAlertas = AlertaMonitorService.totalAlertasCriados;

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isAtivo ? Colors.green[100] : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAtivo
                        ? Icons.monitor_heart
                        : Icons.monitor_heart_outlined,
                    color: isAtivo ? Colors.green[700] : Colors.grey[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sistema de Monitoramento',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isAtivo ? Colors.green[700] : Colors.grey[700],
                        ),
                      ),
                      Text(
                        isAtivo
                            ? 'Monitoramento Ativo'
                            : 'Monitoramento Inativo',
                        style: TextStyle(
                          color: isAtivo ? Colors.green[600] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue[600]),
                  onPressed: _verificarCondicoes,
                ),
              ],
            ),
            SizedBox(height: 16),

            // Status e informações
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAtivo ? Colors.green[50] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAtivo ? Colors.green[200]! : Colors.grey[300]!,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        'Status',
                        isAtivo ? 'ATIVO' : 'INATIVO',
                        isAtivo ? Icons.check_circle : Icons.pause_circle,
                        isAtivo ? Colors.green : Colors.grey,
                      ),
                      _buildInfoItem(
                        'Alertas Criados',
                        totalAlertas.toString(),
                        Icons.warning_amber,
                        Colors.orange,
                      ),
                      _buildInfoItem(
                        'Intervalo',
                        '30s',
                        Icons.timer,
                        Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Condições de monitoramento
            Text(
              'Condições Monitoradas:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCondicaoItem(
                    '🌡️ Temperatura',
                    'Alerta se ≥ 70°C',
                    Colors.red,
                  ),
                  SizedBox(height: 8),
                  _buildCondicaoItem(
                    '💧 Umidade',
                    'Alerta se ≤ 10%',
                    Colors.orange,
                  ),
                ],
              ),
            ),

            // Verificação atual
            if (carregando) ...[
              SizedBox(height: 16),
              Center(child: CircularProgressIndicator()),
            ] else if (alertasDetectados.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Condições Críticas Detectadas:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              SizedBox(height: 8),
              ...alertasDetectados
                  .map(
                    (alerta) => Container(
                      margin: EdgeInsets.symmetric(vertical: 2),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red[600], size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              alerta,
                              style: TextStyle(
                                color: Colors.red[800],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ] else ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Todos os sensores dentro dos parâmetros normais',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildCondicaoItem(String titulo, String descricao, Color cor) {
    return Row(
      children: [
        Text(
          titulo,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        Spacer(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: cor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cor.withOpacity(0.3)),
          ),
          child: Text(
            descricao,
            style: TextStyle(
              fontSize: 12,
              color: cor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
