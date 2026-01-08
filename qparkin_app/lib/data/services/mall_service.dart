import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mall_model.dart';

/// Service untuk fetch data mall dari API backend
/// 
/// Mengambil data mall aktif dari endpoint /api/mall
/// dan mengkonversi response JSON ke List<MallModel>
class MallService {
  final String baseUrl;
  
  MallService({required this.baseUrl});
  
  /// Fetch all active malls from API
  /// 
  /// Returns List<MallModel> dengan data mall yang status='active'
  /// Throws Exception jika request gagal
  Future<List<MallModel>> fetchMalls() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/mall'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
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
      } else {
        throw Exception('Failed to load malls: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching malls: $e');
    }
  }
}
