import 'package:flutter/material.dart';
import '../models/alerta.dart';
import '../services/alertas_service.dart';

class AlertasCard extends StatefulWidget {
  @override
  _AlertasCardState createState() => _AlertasCardState();
}

class _AlertasCardState extends State<AlertasCard> {
  List<Alerta> alertas = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarAlertas();
  }

  Future<void> _carregarAlertas() async {
    setState(() => carregando = true);

    try {
      final alertasData = await AlertasService.listarAlertas();
      setState(() => alertas = alertasData);
    } catch (e) {
      print('Erro ao carregar alertas: $e');
    } finally {
      setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Alertas Recentes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[700],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.orange),
                  onPressed: _carregarAlertas,
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
            else if (alertas.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle, size: 48, color: Colors.green),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum alerta ativo',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Todos os sensores estão funcionando normalmente',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: alertas
                    .take(3)
                    .length, // Mostrar apenas os 3 mais recentes
                itemBuilder: (context, index) {
                  final alerta = alertas[index];
                  final timeAgo = alerta.data != null
                      ? _formatTimeAgo(alerta.data!)
                      : 'Data desconhecida';

                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        alerta.nome,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[800],
                        ),
                      ),
                      subtitle: Text(
                        timeAgo,
                        style: TextStyle(color: Colors.orange[600]),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.orange[400],
                      ),
                    ),
                  );
                },
              ),

            if (alertas.length > 3)
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Center(
                  child: TextButton(
                    onPressed: () {
                      // Navegar para tela de todos os alertas
                    },
                    child: Text(
                      'Ver todos os alertas (${alertas.length})',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }
}
