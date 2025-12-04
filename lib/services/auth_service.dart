import '../services/api_service.dart';
import '../models/usuario.dart';

class AuthService {
  // Verificar se email existe no banco (auth simples)
  static Future<Map<String, dynamic>> login(String email) async {
    try {
      final response = await ApiService.get('/usuarios/email/$email');

      if (response['success'] && response['data'] != null) {
        final usuario = Usuario.fromJson(response['data']);
        return {
          'success': true,
          'usuario': usuario,
          'message': 'Login realizado com sucesso',
        };
      } else {
        return {'success': false, 'error': 'Email não encontrado no sistema'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Verificar se existe usuário logado (simulado com SharedPreferences futuramente)
  static bool isLoggedIn() {
    // Por enquanto sempre false, implementar SharedPreferences depois
    return false;
  }

  static void logout() {
    // Limpar dados de login
  }
}
