import 'package:flutter/material.dart';

// Importe todas as pages aqui

import '../pages/cadUser.dart';
// import '../pages/home_page.dart'; // Descomente depois

class AppRoutes {
  // Nomes das rotas (constantes)
  static const String login = '/login';
  static const String cadastro = '/cadastro';
  static const String home = '/home';

  // Mapeamento de rotas
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      cadastro: (context) => CadastroUserPage(),
      // home: (context) => HomePage(), // Adicione depois
    };
  }
}