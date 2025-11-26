import 'package:flutter/material.dart';
import '../widgets/formulario_cad_user.dart';
import '../auth/authService.dart'; // Importe o AuthService

class CadastroUserPage extends StatefulWidget {
  @override
  _CadastroUserPageState createState() => _CadastroUserPageState();
}

class _CadastroUserPageState extends State<CadastroUserPage> {
  bool _carregando = false;

  void _cadastrarUsuario(String nome, String email, String senha) async {
    setState(() {
      _carregando = true;
    });

    final resultado = await AuthService.cadastrarUsuario(nome, email, senha);

    if (resultado['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['error'] ?? 'Erro ao cadastrar usuário'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Usuário'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _carregando
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cadastrando usuário...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    'Criar Nova Conta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Preencha os dados abaixo para se cadastrar',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  CadastroUsuarioForm(onCadastrar: _cadastrarUsuario),
                ],
              ),
            ),
    );
  }
}
