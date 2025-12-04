import 'dart:async';
import '../models/sensores.dart';
import '../services/sensores_service.dart';
import '../services/valores_sensor_service.dart';
import '../services/alertas_service.dart';

class AlertaMonitorService {
  static const double TEMPERATURA_LIMITE_ALTA = 70.0;
  static const double UMIDADE_LIMITE_BAIXA = 10.0;

  static Timer? _timer;
  static bool _monitorandoAtivo = false;
  static List<String> _alertasJaCriados = [];

  /// Inicia o monitoramento automático de condições de alerta
  static void iniciarMonitoramento({int intervalSeconds = 60}) {
    if (_monitorandoAtivo) {
      print('Monitoramento já está ativo');
      return;
    }

    _monitorandoAtivo = true;
    print(
      '🚨 Monitoramento de alertas iniciado - Intervalo: ${intervalSeconds}s',
    );

    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) {
      _verificarCondicoesAlerta();
    });
  }

  /// Para o monitoramento automático
  static void pararMonitoramento() {
    if (!_monitorandoAtivo) {
      print('Monitoramento não está ativo');
      return;
    }

    _timer?.cancel();
    _timer = null;
    _monitorandoAtivo = false;
    _alertasJaCriados.clear();
    print('🛑 Monitoramento de alertas parado');
  }

  /// Verifica as condições dos sensores e cria alertas se necessário
  static Future<void> _verificarCondicoesAlerta() async {
    try {
      final sensores = await SensoresService.listarSensores();

      for (final sensor in sensores) {
        await _verificarSensorIndividual(sensor);
      }
    } catch (e) {
      print('Erro ao verificar condições de alerta: $e');
    }
  }

  /// Verifica um sensor individual e cria alerta se necessário
  static Future<void> _verificarSensorIndividual(Sensor sensor) async {
    if (sensor.id == null) return;

    try {
      final ultimoValor = await ValoresSensorService.obterUltimoValor(
        sensor.id!,
      );

      if (ultimoValor == null || ultimoValor['valor'] == null) {
        return;
      }

      final valor = ultimoValor['valor'].toDouble();
      String? tipoAlerta;
      String nomeAlerta = '';

      // Verificar temperatura alta
      if (sensor.tipo.toLowerCase() == 'temperatura' &&
          valor >= TEMPERATURA_LIMITE_ALTA) {
        tipoAlerta = 'temperatura_alta';
        nomeAlerta =
            '🔥 ALERTA: Temperatura crítica! ${valor}°C (Sensor: ${sensor.nome})';
      }
      // Verificar umidade baixa
      else if (sensor.tipo.toLowerCase() == 'umidade' &&
          valor <= UMIDADE_LIMITE_BAIXA) {
        tipoAlerta = 'umidade_baixa';
        nomeAlerta =
            '💧 ALERTA: Umidade crítica! ${valor}% (Sensor: ${sensor.nome})';
      }

      if (tipoAlerta != null) {
        String chaveAlerta = '${tipoAlerta}_${sensor.id}';

        if (!_alertasJaCriados.contains(chaveAlerta)) {
          await _criarAlertaAutomatico(nomeAlerta);
          _alertasJaCriados.add(chaveAlerta);
          print('🚨 Alerta criado: $nomeAlerta');
        }
      } else {
        // Remover alerta se condição voltou ao normal
        _alertasJaCriados.removeWhere(
          (alerta) => alerta.contains('_${sensor.id}'),
        );
      }
    } catch (e) {
      print('Erro ao verificar sensor ${sensor.nome}: $e');
    }
  }

  /// Cria um alerta automaticamente
  static Future<void> _criarAlertaAutomatico(String nomeAlerta) async {
    try {
      final resultado = await AlertasService.criarAlerta(nome: nomeAlerta);

      if (resultado['success']) {
        print('✅ Alerta criado com sucesso: $nomeAlerta');
      } else {
        print('❌ Erro ao criar alerta: ${resultado['error']}');
      }
    } catch (e) {
      print('❌ Erro ao criar alerta automático: $e');
    }
  }

  /// Verifica manualmente as condições (para uso em widgets)
  static Future<List<String>> verificarCondicoesManual() async {
    List<String> alertasDetectados = [];

    try {
      final sensores = await SensoresService.listarSensores();
      final valores = await ValoresSensorService.obterUltimosValoresTodos();

      for (final sensor in sensores) {
        if (sensor.id == null) continue;

        final valorData = valores[sensor.id!];
        if (valorData == null || valorData['valor'] == null) continue;

        final valor = valorData['valor'].toDouble();

        if (sensor.tipo.toLowerCase() == 'temperatura' &&
            valor >= TEMPERATURA_LIMITE_ALTA) {
          alertasDetectados.add('🔥 ${sensor.nome}: ${valor}°C (crítico)');
        }

        if (sensor.tipo.toLowerCase() == 'umidade' &&
            valor <= UMIDADE_LIMITE_BAIXA) {
          alertasDetectados.add('💧 ${sensor.nome}: ${valor}% (crítico)');
        }
      }
    } catch (e) {
      print('Erro na verificação manual: $e');
    }

    return alertasDetectados;
  }

  /// Retorna o status atual do monitoramento
  static bool get isMonitorandoAtivo => _monitorandoAtivo;

  /// Retorna quantos alertas únicos já foram criados
  static int get totalAlertasCriados => _alertasJaCriados.length;

  /// Configura novos limites para os alertas
  static void configurarLimites({
    double? temperaturaLimite,
    double? umidadeLimite,
  }) {
    // Para implementação futura - permitir configuração dinâmica dos limites
    print('Configuração de limites personalizados ainda não implementada');
    print(
      'Limites atuais: Temperatura ≥ ${TEMPERATURA_LIMITE_ALTA}°C, Umidade ≤ ${UMIDADE_LIMITE_BAIXA}%',
    );
  }
}
