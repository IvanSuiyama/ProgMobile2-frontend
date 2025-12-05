import '../services/api_service.dart';
import '../models/usuario.dart';

class UsuariosService {
  // Listar todos os usuários
  static Future<List<Usuario>> listarUsuarios() async {
    try {
      final response = await ApiService.get('/usuarios/');

      if (response['success'] && response['data'] != null) {
        final List<dynamic> usuariosData = response['data'];
        return usuariosData.map((data) => Usuario.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obter usuário por ID
  static Future<Usuario?> obterUsuarioPorId(int id) async {
    try {
      final response = await ApiService.get('/usuarios/$id');

      if (response['success'] && response['data'] != null) {
        return Usuario.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Obter usuário por email
  static Future<Usuario?> obterUsuarioPorEmail(String email) async {
    try {
      final response = await ApiService.get('/usuarios/email/$email');

      if (response['success'] && response['data'] != null) {
        return Usuario.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Criar usuário
  static Future<Map<String, dynamic>> criarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final response = await ApiService.post(
        '/usuarios/',
        data: {'nome': nome, 'email': email, 'senha': senha},
      );

      if (response['success']) {
        return {
          'success': true,
          'usuario': Usuario.fromJson(response['data']),
          'message': 'Usuário criado com sucesso',
        };
      } else {
        return response;
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Atualizar usuário
  static Future<Map<String, dynamic>> atualizarUsuario({
    required int id,
    required String nome,
    required String email,
    String? senha,
  }) async {
    try {
      final data = {'nome': nome, 'email': email};

      if (senha != null && senha.isNotEmpty) {
        data['senha'] = senha;
      }

      final response = await ApiService.put('/usuarios/$id', data);

      if (response['success']) {
        return {
          'success': true,
          'usuario': Usuario.fromJson(response['data']),
          'message': 'Usuário atualizado com sucesso',
        };
      } else {
        return response;
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Deletar usuário
  static Future<Map<String, dynamic>> deletarUsuario(int id) async {
    try {
      final response = await ApiService.delete('/usuarios/$id');

      if (response['success']) {
        return {'success': true, 'message': 'Usuário deletado com sucesso'};
      } else {
        return response;
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
