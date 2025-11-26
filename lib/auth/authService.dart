import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiBaseUrl = "http://192.168.15.14:8000";

class AuthService {
  // Deletar usuário
  static Future<Map<String, dynamic>> deletarUsuario(int usuarioId) async {
    try {
      final response = await deleteRequest("$baseUrl/$usuarioId");
      if (response.statusCode == 200) {
        return {
          "success": true,
          "message": response.data != null ? response.data["message"] : null,
        };
      } else {
        return {
          "success": false,
          "error": response.data != null && response.data["detail"] != null
              ? response.data["detail"]
              : "Erro ao deletar",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Erro de conexão"};
    }
  }

  // Atualizar usuário
  static Future<Map<String, dynamic>> atualizarUsuario(
    int usuarioId,
    String nome,
    String email,
    String? senha,
  ) async {
    try {
      final body = {
        if (nome.isNotEmpty) 'nome': nome,
        if (email.isNotEmpty) 'email': email,
        if (senha != null && senha.isNotEmpty) 'senha': senha,
      };
      final response = await putRequest("$baseUrl/$usuarioId", body);
      if (response.statusCode == 200) {
        return {"success": true, "usuario": response.data};
      } else {
        return {
          "success": false,
          "error": response.data != null && response.data["detail"] != null
              ? response.data["detail"]
              : "Erro ao atualizar",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Erro de conexão"};
    }
  }

  // Utilitário para PUT
  static Future<_HttpResponse> putRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return _HttpResponse(response.statusCode, jsonDecode(response.body));
    } catch (e) {
      return _HttpResponse(500, null);
    }
  }

  // Utilitário para GET
  static Future<_HttpResponse> getRequest(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );
      return _HttpResponse(response.statusCode, jsonDecode(response.body));
    } catch (e) {
      return _HttpResponse(500, null);
    }
  }

  // Utilitário para POST
  static Future<_HttpResponse> postRequest(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      return _HttpResponse(response.statusCode, jsonDecode(response.body));
    } catch (e) {
      return _HttpResponse(500, null);
    }
  }

  // Utilitário para DELETE
  static Future<_HttpResponse> deleteRequest(String url) async {
    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      );
      return _HttpResponse(
        response.statusCode,
        response.body.isNotEmpty ? jsonDecode(response.body) : null,
      );
    } catch (e) {
      return _HttpResponse(500, null);
    }
  }

  static String get baseUrl => "$apiBaseUrl/usuarios";

  // Login do usuário
  static Future<Map<String, dynamic>> login(String email, String senha) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "senha": senha}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "usuario": data};
      } else {
        final data = jsonDecode(response.body);
        return {"success": false, "error": data["detail"] ?? "Erro no login"};
      }
    } catch (e) {
      return {"success": false, "error": "Erro de conexão"};
    }
  }

  // Cadastro de usuário
  static Future<Map<String, dynamic>> cadastrarUsuario(
    String nome,
    String email,
    String senha,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${baseUrl}/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"nome": nome, "email": email, "senha": senha}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {"success": true, "usuario": data};
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "error": data["detail"] ?? "Erro ao cadastrar",
        };
      }
    } catch (e) {
      return {"success": false, "error": "Erro de conexão"};
    }
  }

  // Verificar se email existe
  static Future<bool> verificarEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}/verificar-email/$email"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["existe"] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Buscar usuário por email
  static Future<Map<String, dynamic>?> obterUsuarioPorEmail(
    String email,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}/email/$email"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Buscar usuário por ID
  static Future<Map<String, dynamic>?> obterUsuarioPorId(int id) async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}/$id"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Listar todos os usuários
  static Future<List<dynamic>> listarUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}/"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Buscar usuários por nome
  static Future<List<dynamic>> buscarUsuariosPorNome(String nome) async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}/buscar/$nome"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Estatísticas dos usuários
  static Future<Map<String, dynamic>?> estatisticasUsuarios() async {
    try {
      final response = await http.get(
        Uri.parse("${baseUrl}/stats/estatisticas"),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class _HttpResponse {
  final int statusCode;
  final dynamic data;
  _HttpResponse(this.statusCode, this.data);
}
