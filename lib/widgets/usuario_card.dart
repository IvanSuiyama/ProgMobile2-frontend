import 'package:flutter/material.dart';
import '../models/usuario.dart';
import '../services/usuarios_service.dart';
import '../pages/editar_usuario_page.dart';

class UsuarioCard extends StatefulWidget {
  final String email;
  final bool showAll;

  const UsuarioCard({Key? key, required this.email, this.showAll = false})
    : super(key: key);

  @override
  _UsuarioCardState createState() => _UsuarioCardState();
}

class _UsuarioCardState extends State<UsuarioCard> {
  Usuario? usuarioAtual;
  List<Usuario> todosUsuarios = [];
  bool carregando = true;

  @override
  void initState() {
    super.initState();
    if (widget.showAll) {
      _carregarTodosUsuarios();
    } else {
      _carregarUsuarioAtual();
    }
  }

  Future<void> _carregarUsuarioAtual() async {
    setState(() => carregando = true);

    try {
      final usuario = await UsuariosService.obterUsuarioPorEmail(widget.email);
      setState(() => usuarioAtual = usuario);
    } catch (e) {
      print('Erro ao carregar usuário: $e');
    } finally {
      setState(() => carregando = false);
    }
  }

  Future<void> _carregarTodosUsuarios() async {
    setState(() => carregando = true);

    try {
      final usuarios = await UsuariosService.listarUsuarios();
      setState(() => todosUsuarios = usuarios);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar usuários: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => carregando = false);
    }
  }

  Future<void> _deletarUsuario(int usuarioId, String nome) async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Deseja realmente deletar o usuário \"$nome\"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmacao == true) {
      try {
        final resultado = await UsuariosService.deletarUsuario(usuarioId);

        if (resultado['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                resultado['message'] ?? 'Usuário deletado com sucesso!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _carregarTodosUsuarios(); // Recarregar lista
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['error'] ?? 'Erro ao deletar usuário'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAll) {
      return _buildTodosUsuarios();
    } else {
      return _buildUsuarioAtual();
    }
  }

  Widget _buildUsuarioAtual() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 24),

          if (carregando)
            CircularProgressIndicator()
          else if (usuarioAtual == null)
            Column(
              children: [
                Icon(Icons.error, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text('Usuário não encontrado'),
              ],
            )
          else
            Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blueAccent,
                  child: Text(
                    usuarioAtual!.nome.isNotEmpty
                        ? usuarioAtual!.nome[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Nome
                Text(
                  usuarioAtual!.nome,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 8),

                // Email
                Text(
                  usuarioAtual!.email,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 32),

                // Botões de ação
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditarUsuarioPage(usuario: usuarioAtual!),
                            ),
                          );
                          _carregarUsuarioAtual();
                        },
                        icon: Icon(Icons.edit),
                        label: Text('Editar Perfil'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTodosUsuarios() {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.blueAccent, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Usuários do Sistema',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blueAccent),
                  onPressed: _carregarTodosUsuarios,
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
            else if (todosUsuarios.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum usuário encontrado',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: todosUsuarios.length,
                  itemBuilder: (context, index) {
                    final usuario = todosUsuarios[index];
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            usuario.nome.isNotEmpty
                                ? usuario.nome[0].toUpperCase()
                                : 'U',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          usuario.nome,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(usuario.email),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            if (value == 'edit') {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EditarUsuarioPage(usuario: usuario),
                                ),
                              );
                              _carregarTodosUsuarios();
                            } else if (value == 'delete') {
                              _deletarUsuario(usuario.id!, usuario.nome);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text('Editar'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Deletar'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
