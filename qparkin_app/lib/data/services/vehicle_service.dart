import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vehicle_model.dart';

/// Service for managing vehicle-related API calls
class VehicleService {
  final String baseUrl;
  final String? authToken;

  VehicleService({
    required this.baseUrl,
    this.authToken,
  });

  /// Fetch all vehicles registered by the authenticated user
  Future<List<VehicleModel>> fetchVehicles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/vehicles'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> vehiclesJson = data['data'] ?? [];
        return vehiclesJson
            .map((json) => VehicleModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch vehicles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching vehicles: $e');
    }
  }

  /// Add a new vehicle
  Future<VehicleModel> addVehicle({
    required String platNomor,
    required String jenisKendaraan,
    required String merk,
    required String tipe,
    String? warna,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/vehicles'),
        headers: {
          'Content-Type': 'application/json',
          if (authToken != null) 'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'plat_nomor': platNomor,
          'jenis_kendaraan': jenisKendaraan,
          'merk': merk,
          'tipe': tipe,
          'warna': warna,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return VehicleModel.fromJson(data['data']);
      } else {
        throw Exception('Failed to add vehicle: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding vehicle: $e');
    }
  }
}
