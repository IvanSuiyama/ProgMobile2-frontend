import 'package:flutter/material.dart';
import '../auth/authService.dart';

class EditUsuarioPage extends StatefulWidget {
  final int usuarioId;
  final String nomeInicial;
  final String emailInicial;

  EditUsuarioPage({
    required this.usuarioId,
    required this.nomeInicial,
    required this.emailInicial,
  });

  @override
  _EditUsuarioPageState createState() => _EditUsuarioPageState();
}

class _EditUsuarioPageState extends State<EditUsuarioPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  final _senhaController = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.nomeInicial);
    _emailController = TextEditingController(text: widget.emailInicial);
  }

  void _editarUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.isNotEmpty
        ? _senhaController.text
        : null;

    final resultado = await AuthService.atualizarUsuario(
      widget.usuarioId,
      nome,
      email,
      senha,
    );

    if (resultado['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Usuário atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resultado['error'] ?? 'Erro ao atualizar usuário'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() => _carregando = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Editar Usuário')),
      body: _carregando
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(labelText: 'Nome'),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o nome' : null,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe o email';
                        if (!v.contains('@')) return 'Email inválido';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _senhaController,
                      decoration: InputDecoration(
                        labelText: 'Nova Senha (opcional)',
                      ),
                      obscureText: true,
                      validator: (v) {
                        if (v != null && v.isNotEmpty && v.length < 6) {
                          return 'Senha deve ter pelo menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _editarUsuario,
                      child: Text('Salvar Alterações'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
