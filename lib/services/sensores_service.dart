import '../services/api_service.dart';
import '../models/sensores.dart';

class SensoresService {
  // Criar sensor
  static Future<Map<String, dynamic>> criarSensor({
    required String nome,
    required String tipo,
    required String unidade,
  }) async {
    try {
      final queryParams = {'nome': nome, 'tipo': tipo, 'unidade': unidade};

      final response = await ApiService.post(
        '/sensores/',
        queryParams: queryParams,
      );

      if (response['success'] && response['data'] != null) {
        return {
          'success': true,
          'sensor': Sensor.fromJson(response['data']),
          'message': 'Sensor criado com sucesso',
        };
      } else {
        return {'success': false, 'error': 'Erro ao criar sensor'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Listar todos os sensores
  static Future<List<Sensor>> listarSensores() async {
    try {
      final response = await ApiService.get('/sensores/');

      if (response['success'] && response['data'] != null) {
        final List<dynamic> sensoresData = response['data'];
        return sensoresData.map((data) => Sensor.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obter sensor por ID
  static Future<Sensor?> obterSensorPorId(int id) async {
    try {
      final response = await ApiService.get('/sensores/$id');

      if (response['success'] && response['data'] != null) {
        return Sensor.fromJson(response['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Atualizar sensor
  static Future<Map<String, dynamic>> atualizarSensor({
    required int id,
    required String nome,
    required String tipo,
    required String unidade,
  }) async {
    try {
      final response = await ApiService.put('/sensores/$id', {
        'nome': nome,
        'tipo': tipo,
        'unidade': unidade,
      });

      if (response['success']) {
        return {
          'success': true,
          'sensor': Sensor.fromJson(response['data']),
          'message': 'Sensor atualizado com sucesso',
        };
      } else {
        return response;
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Deletar sensor
  static Future<Map<String, dynamic>> deletarSensor(int id) async {
    try {
      final response = await ApiService.delete('/sensores/$id');

      if (response['success']) {
        return {'success': true, 'message': 'Sensor deletado com sucesso'};
      } else {
        return response;
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Listar sensores por tipo
  static Future<List<Sensor>> listarSensoresPorTipo(String tipo) async {
    try {
      final response = await ApiService.get('/sensores/tipo/$tipo');

      if (response['success'] && response['data'] != null) {
        final List<dynamic> sensoresData = response['data'];
        return sensoresData.map((data) => Sensor.fromJson(data)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
