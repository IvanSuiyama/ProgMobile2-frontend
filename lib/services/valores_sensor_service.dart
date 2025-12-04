import '../services/api_service.dart';

class ValoresSensorService {
  // Criar valor para sensor
  static Future<Map<String, dynamic>> criarValor({
    required int idSensor,
    required double valor,
  }) async {
    try {
      final response = await ApiService.post(
        '/valores/$idSensor?valor=$valor',
        {},
      );

      if (response['success']) {
        return {
          'success': true,
          'data': response['data'],
          'message': 'Valor criado com sucesso',
        };
      } else {
        return response;
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Listar valores de um sensor
  static Future<List<Map<String, dynamic>>> listarValoresSensor(
    int idSensor, {
    int limit = 100,
  }) async {
    try {
      final response = await ApiService.get('/valores/$idSensor?limit=$limit');

      if (response['success'] && response['data'] != null) {
        final List<dynamic> valoresData = response['data'];
        return valoresData.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obter último valor de um sensor
  static Future<Map<String, dynamic>?> obterUltimoValor(int idSensor) async {
    try {
      final response = await ApiService.get('/valores/$idSensor/ultimo');

      if (response['success'] && response['data'] != null) {
        return response['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Obter últimos valores de todos os sensores
  static Future<Map<int, Map<String, dynamic>>>
  obterUltimosValoresTodos() async {
    try {
      final response = await ApiService.get('/valores/ultimos-todos');

      if (response['success'] && response['data'] != null) {
        final Map<String, dynamic> data = response['data'];
        Map<int, Map<String, dynamic>> resultado = {};

        data.forEach((key, value) {
          resultado[int.parse(key)] = value;
        });

        return resultado;
      }
      return {};
    } catch (e) {
      print('Erro ao obter últimos valores de todos os sensores: $e');
      return {};
    }
  }

  // Listar todos os valores
  static Future<List<Map<String, dynamic>>> listarTodosValores({
    int limit = 1000,
  }) async {
    try {
      final response = await ApiService.get('/valores/?limit=$limit');

      if (response['success'] && response['data'] != null) {
        final List<dynamic> valoresData = response['data'];
        return valoresData.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Obter estatísticas de um sensor
  static Future<Map<String, dynamic>?> obterEstatisticasSensor(
    int idSensor,
  ) async {
    try {
      final response = await ApiService.get('/valores/$idSensor/estatisticas');

      if (response['success'] && response['data'] != null) {
        return response['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Deletar valor específico
  static Future<Map<String, dynamic>> deletarValor(int idValor) async {
    try {
      final response = await ApiService.delete('/valores/valor/$idValor');

      if (response['success']) {
        return {'success': true, 'message': 'Valor deletado com sucesso'};
      } else {
        return response;
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Limpar valores antigos de um sensor
  static Future<Map<String, dynamic>> limparValoresAntigos(
    int idSensor, {
    int manterUltimos = 1000,
  }) async {
    try {
      final response = await ApiService.delete(
        '/valores/$idSensor/limpeza?manter_ultimos=$manterUltimos',
      );

      if (response['success']) {
        return {
          'success': true,
          'message': 'Valores antigos removidos com sucesso',
          'data': response['data'],
        };
      } else {
        return response;
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
