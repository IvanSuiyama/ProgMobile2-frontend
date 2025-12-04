import 'package:flutter/material.dart';
import '../widgets/sensores_card.dart';
import '../widgets/dashboard_chart_card.dart';
import '../widgets/alertas_card.dart';
import '../widgets/usuario_card.dart';
import '../widgets/monitoramento_info_card.dart';
import '../routes/app_route.dart';
import '../services/alerta_monitor_service.dart';

class HomePage extends StatefulWidget {
  final String emailUsuario;

  const HomePage({Key? key, required this.emailUsuario}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Iniciar monitoramento automático de alertas
    AlertaMonitorService.iniciarMonitoramento(intervalSeconds: 30);
  }

  @override
  void dispose() {
    // Parar monitoramento ao sair da tela
    AlertaMonitorService.pararMonitoramento();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showUserProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => UsuarioCard(email: widget.emailUsuario),
    );
  }

  void _toggleMonitoramento() {
    setState(() {
      if (AlertaMonitorService.isMonitorandoAtivo) {
        AlertaMonitorService.pararMonitoramento();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🛑 Monitoramento de alertas parado'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        AlertaMonitorService.iniciarMonitoramento(intervalSeconds: 30);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🚨 Monitoramento de alertas iniciado'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sair'),
          content: Text('Deseja realmente sair do app?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Sair'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Estação Meteorológica',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        actions: [
          // Indicador de monitoramento ativo
          Container(
            margin: EdgeInsets.only(right: 8),
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AlertaMonitorService.isMonitorandoAtivo
                      ? Colors.green[600]
                      : Colors.red[600],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AlertaMonitorService.isMonitorandoAtivo
                          ? Icons.monitor_heart
                          : Icons.monitor_heart_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      AlertaMonitorService.isMonitorandoAtivo ? 'ON' : 'OFF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.account_circle, size: 32, color: Colors.white),
            onPressed: _showUserProfile,
            tooltip: 'Perfil',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'toggle_monitor') {
                _toggleMonitoramento();
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_monitor',
                child: Row(
                  children: [
                    Icon(
                      AlertaMonitorService.isMonitorandoAtivo
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      color: AlertaMonitorService.isMonitorandoAtivo
                          ? Colors.orange
                          : Colors.green,
                    ),
                    SizedBox(width: 8),
                    Text(
                      AlertaMonitorService.isMonitorandoAtivo
                          ? 'Parar Monitoramento'
                          : 'Iniciar Monitoramento',
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sair'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [_buildHomeTab(), _buildSensoresTab(), _buildUsuariosTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Sensores'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Usuários'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue[700]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Monitore seus sensores em tempo real',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.wb_sunny, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        widget.emailUsuario,
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Monitoramento de Alertas
          MonitoramentoInfoCard(),
          SizedBox(height: 20),

          // Dashboard Chart
          DashboardChartCard(),
          SizedBox(height: 20),

          // Recent Sensors
          SensoresCard(),
          SizedBox(height: 20),

          // Recent Alerts
          AlertasCard(),
        ],
      ),
    );
  }

  Widget _buildSensoresTab() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Gerenciar Sensores',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.cadastroSensor);
                },
                icon: Icon(Icons.add),
                label: Text('Novo Sensor'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: SensoresCard(showAll: true)),
      ],
    );
  }

  Widget _buildUsuariosTab() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Gerenciar Usuários',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.cadastroUsuario);
                },
                icon: Icon(Icons.person_add),
                label: Text('Novo Usuário'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: UsuarioCard(email: widget.emailUsuario, showAll: true)),
      ],
    );
  }
}
