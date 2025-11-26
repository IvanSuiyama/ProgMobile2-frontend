import 'package:flutter/material.dart';
import 'routes/app_route.dart'; // Importe o arquivo de rotas

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estação Meteorológica',
      
      // Rota inicial
      initialRoute: AppRoutes.login,
      
      // Todas as rotas definidas no arquivo separado
      routes: AppRoutes.getRoutes(),
      
      debugShowCheckedModeBanner: false,
    );
  }
}