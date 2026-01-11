import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/mall_model.dart';

/// Service untuk fetch data mall dari API backend
/// 
/// Mengambil data mall aktif dari endpoint /api/mall (protected)
/// Memerlukan autentikasi dengan Bearer token
class MallService {
  final String baseUrl;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  MallService({required this.baseUrl});
  
  /// Fetch all active malls from API
  /// 
  /// Requires authentication - sends Bearer token in Authorization header
  /// Returns List<MallModel> dengan data mall yang status='active'
  /// Throws Exception jika request gagal atau token tidak tersedia
  Future<List<MallModel>> fetchMalls() async {
    try {
      // Get auth token from secure storage
      final token = await _storage.read(key: 'auth_token');
      
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please login first.');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/mall'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final mallsData = jsonData['data'] as List<dynamic>;
          
          return mallsData
              .map((json) => MallModel.fromJson(json))
              .where((mall) => mall.validate()) // Filter invalid data
              .toList();
        } else {
          throw Exception('API returned success: false');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Token expired or invalid.');
      } else {
        throw Exception('Failed to load malls: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching malls: $e');
    }
  }
}
