import '../models/mall_model.dart';

/// Dummy mall data for development and testing
/// These are realistic mall locations in Batam, Indonesia
/// 
/// TODO: Replace with API call when backend integration is complete
/// API endpoint: GET /api/malls
/// Expected response format: List<Map<String, dynamic>> matching MallModel.fromJson()
/// 
/// Note: Coordinates are in the Batam area (lat 1.0-1.2, lng 103.9-104.1)
/// When integrating with backend, parse coordinates from 'alamat_gmaps' field

final List<MallModel> dummyMalls = [
  MallModel(
    id: '1',
    name: 'Mega Mall Batam Centre',
    address: 'Jl. Engku Putri no.1, Batam Centre',
    latitude: 1.1191,
    longitude: 104.0538,
    availableSlots: 45,
  ),
  MallModel(
    id: '2',
    name: 'BCS Mall',
    address: 'Jl. Raja H. Fisabilillah, Batam Center',
    latitude: 1.1304,
    longitude: 104.0534,
    availableSlots: 32,
  ),
  MallModel(
    id: '3',
    name: 'Harbour Bay Mall',
    address: 'Komplek Ruko Harbour Bay, Batam',
    latitude: 1.1368,
    longitude: 104.0245,
    availableSlots: 28,
  ),
  MallModel(
    id: '4',
    name: 'Grand Batam Mall',
    address: 'Jl. Ahmad Yani, Batam Kota',
    latitude: 1.0822,
    longitude: 103.9635,
    availableSlots: 50,
  ),
  MallModel(
    id: '5',
    name: 'Kepri Mall',
    address: 'Jl. Duyung, Sei Jodoh, Batam',
    latitude: 1.1456,
    longitude: 104.0304,
    availableSlots: 18,
  ),
];

/// Get all dummy malls
List<MallModel> getDummyMalls() {
  return List.from(dummyMalls);
}

/// Get a specific mall by ID
MallModel? getDummyMallById(String id) {
  try {
    return dummyMalls.firstWhere((mall) => mall.id == id);
  } catch (e) {
    return null;
  }
}

/// Get malls with available slots
List<MallModel> getDummyMallsWithAvailableSlots() {
  return dummyMalls.where((mall) => mall.availableSlots > 0).toList();
}

/// Get malls sorted by available slots (descending)
List<MallModel> getDummyMallsSortedByAvailability() {
  final sorted = List<MallModel>.from(dummyMalls);
  sorted.sort((a, b) => b.availableSlots.compareTo(a.availableSlots));
  return sorted;
}
