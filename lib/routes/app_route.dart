import 'package:flutter/material.dart';

// Importe todas as pages aqui
import '../pages/login_page.dart';
import '../pages/home_page.dart';
import '../pages/cadastro_usuario_page.dart';
import '../pages/cadastro_sensor_page.dart';
import '../pages/editar_sensor_page.dart';
import '../pages/editar_usuario_page.dart';
import '../models/sensores.dart';
import '../models/usuario.dart';

class AppRoutes {
  // Nomes das rotas (constantes)
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String home = '/home';
  static const String cadastroUsuario = '/cadastro-usuario';
  static const String cadastroSensor = '/cadastro-sensor';
  static const String editarSensor = '/editar-sensor';
  static const String editarUsuario = '/editar-usuario';

  // Mapeamento de rotas
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => LoginPage(),
      cadastro: (context) => CadastroUsuarioPage(),
      home: (context) => HomePage(emailUsuario: ''),
      cadastroUsuario: (context) => CadastroUsuarioPage(),
      cadastroSensor: (context) => CadastroSensorPage(),
    };
  }

  // Rotas com argumentos (não podem ser mapeadas diretamente)
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case editarSensor:
        // Espera um objeto Sensor como argumento
        final sensor = settings.arguments as Sensor?;
        if (sensor != null) {
          return MaterialPageRoute(
            builder: (context) => EditarSensorPage(sensor: sensor),
          );
        }
        break;

      case editarUsuario:
        // Espera um objeto Usuario como argumento
        final usuario = settings.arguments as Usuario?;
        if (usuario != null) {
          return MaterialPageRoute(
            builder: (context) => EditarUsuarioPage(usuario: usuario),
          );
        }
        break;
    }

    // Se não encontrar a rota ou não tiver argumentos adequados, retorna null
    return null;
  }
}
