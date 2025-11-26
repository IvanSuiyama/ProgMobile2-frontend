import 'package:flutter/material.dart';
import '../auth/authService.dart';
import '../pages/editUsuario.dart';

class CardUsuario extends StatefulWidget {
  final String email;
  const CardUsuario({required this.email, Key? key}) : super(key: key);

  @override
  State<CardUsuario> createState() => _CardUsuarioState();
}

class _CardUsuarioState extends State<CardUsuario> {
  Map<String, dynamic>? usuario;
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    setState(() => carregando = true);
    usuario = await AuthService.obterUsuarioPorEmail(widget.email);
    setState(() => carregando = false);
  }

  void _editarUsuario() async {
    if (usuario == null) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditUsuarioPage(
          usuarioId: usuario!['id'],
          nomeInicial: usuario!['nome'] ?? '',
          emailInicial: usuario!['email'] ?? '',
        ),
      ),
    );
    _carregarUsuario();
  }

  void _deletarUsuario() async {
    if (usuario == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Atenção!'),
        content: Text(
          'Deseja realmente deletar o usuário? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Deletar'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final resultado = await AuthService.deletarUsuario(usuario!['id']);
      if (resultado['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuário deletado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        // Aqui você pode redirecionar para login ou outra tela
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['error'] ?? 'Erro ao deletar usuário'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: carregando
            ? Center(child: CircularProgressIndicator())
            : usuario == null
            ? Text(
                'Usuário não encontrado.',
                style: TextStyle(color: Colors.red),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações do Usuário',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('ID: ${usuario!['id'] ?? ''}'),
                  Text('Nome: ${usuario!['nome'] ?? ''}'),
                  Text('Email: ${usuario!['email'] ?? ''}'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _editarUsuario,
                        icon: Icon(Icons.edit),
                        label: Text('Editar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _deletarUsuario,
                        icon: Icon(Icons.delete),
                        label: Text('Deletar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
