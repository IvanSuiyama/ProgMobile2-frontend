import '../services/api_service.dart';
import '../models/alerta.dart';

class AlertasService {
  // Listar todos os alertas
  static Future<List<Alerta>> listarAlertas() async {
    try {
      final response = await ApiService.get('/alertas/');

      if (response['success'] && response['data'] != null) {
        final List<dynamic> alertasData = response['data'];
        return alertasData.map((data) => Alerta.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obter alerta por ID
  static Future<Alerta?> obterAlertaPorId(int id) async {
    try {
      final response = await ApiService.get('/alertas/$id');

      if (response['success'] && response['data'] != null) {
        return Alerta.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Criar alerta
  static Future<Map<String, dynamic>> criarAlerta({
    required String nome,
  }) async {
    try {
      final response = await ApiService.post('/alertas/', data: {'nome': nome});

      if (response['success']) {
        return {
          'success': true,
          'alerta': Alerta.fromJson(response['data']),
          'message': 'Alerta criado com sucesso',
        };
      } else {
        return response;
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Atualizar alerta
  static Future<Map<String, dynamic>> atualizarAlerta({
    required int id,
    required String nome,
  }) async {
    try {
      final response = await ApiService.put('/alertas/$id', {'nome': nome});

      if (response['success']) {
        return {
          'success': true,
          'alerta': Alerta.fromJson(response['data']),
          'message': 'Alerta atualizado com sucesso',
        };
      } else {
        return response;
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Deletar alerta
  static Future<Map<String, dynamic>> deletarAlerta(int id) async {
    try {
      final response = await ApiService.delete('/alertas/$id');

      if (response['success']) {
        return {'success': true, 'message': 'Alerta deletado com sucesso'};
      } else {
        return response;
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
