import 'package:flutter/material.dart';

class CadastroUsuarioForm extends StatefulWidget {
  final Function(String nome, String email, String senha) onCadastrar;

  const CadastroUsuarioForm({
    Key? key,
    required this.onCadastrar,
  }) : super(key: key);

  @override
  _CadastroUsuarioFormState createState() => _CadastroUsuarioFormState();
}

class _CadastroUsuarioFormState extends State<CadastroUsuarioForm> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _senhaVisivel = false;
  bool _confirmarSenhaVisivel = false;

  void _cadastrar() {
    if (_formKey.currentState!.validate()) {
      // Só chama a API se o formulário for válido
      widget.onCadastrar(
        _nomeController.text.trim(),
        _emailController.text.trim(),
        _senhaController.text,
      );
    }
  }

  String? _validarNome(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu nome';
    }
    if (value.length < 2) {
      return 'Nome deve ter pelo menos 2 caracteres';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite seu email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Digite um email válido';
    }
    return null;
  }

  String? _validarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, digite uma senha';
    }
    if (value.length < 6) {
      return 'Senha deve ter pelo menos 6 caracteres';
    }
    return null;
  }

  String? _validarConfirmarSenha(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme sua senha';
    }
    if (value != _senhaController.text) {
      return 'Senhas não coincidem';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo Nome
          TextFormField(
            controller: _nomeController,
            decoration: InputDecoration(
              labelText: 'Nome completo',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: _validarNome,
          ),
          SizedBox(height: 16),
          
          // Campo Email
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: _validarEmail,
          ),
          SizedBox(height: 16),
          
          // Campo Senha
          TextFormField(
            controller: _senhaController,
            decoration: InputDecoration(
              labelText: 'Senha',
              prefixIcon: Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _senhaVisivel ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _senhaVisivel = !_senhaVisivel;
                  });
                },
              ),
              border: OutlineInputBorder(),
            ),
            obscureText: !_senhaVisivel,
            validator: _validarSenha,
          ),
          SizedBox(height: 16),
          
          // Campo Confirmar Senha
          TextFormField(
            controller: _confirmarSenhaController,
            decoration: InputDecoration(
              labelText: 'Confirmar Senha',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _confirmarSenhaVisivel ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _confirmarSenhaVisivel = !_confirmarSenhaVisivel;
                  });
                },
              ),
              border: OutlineInputBorder(),
            ),
            obscureText: !_confirmarSenhaVisivel,
            validator: _validarConfirmarSenha,
          ),
          SizedBox(height: 24),
          
          // Botão Cadastrar
          ElevatedButton(
            onPressed: _cadastrar,
            child: Text('Cadastrar', style: TextStyle(fontSize: 16)),
            style: ElevatedButton.styleFrom(
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}