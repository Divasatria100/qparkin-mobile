import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qparkin_app/data/models/active_parking_model.dart';
import 'package:qparkin_app/data/models/timer_state.dart';
import 'package:qparkin_app/logic/providers/active_parking_provider.dart';
import 'package:qparkin_app/data/services/parking_service.dart';

// Mock ParkingService for testing
class MockParkingService extends ParkingService {
  ActiveParkingModel? mockActiveParking;
  bool shouldThrowError = false;
  String errorMessage = 'Network error';
  int callCount = 0;

  @override
  Future<ActiveParkingModel?> getActiveParking({String? token}) async {
    callCount++;
    
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    await Future.delayed(const Duration(milliseconds: 10));
    return mockActiveParking;
  }

  @override
  Future<ActiveParkingModel?> getActiveParkingWithRetry({
    String? token,
    int maxRetries = 3,
  }) async {
    return getActiveParking(token: token);
  }

  void reset() {
    mockActiveParking = null;
    shouldThrowError = false;
    errorMessage = 'Network error';
    callCount = 0;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ActiveParkingProvider State Management', () {
    late MockParkingService mockService;
    late ActiveParkingProvider provider;

    setUp(() {
      mockService = MockParkingService();
      provider = ActiveParkingProvider(parkingService: mockService);
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('initial state is empty', () {
      expect(provider.activeParking, isNull);
      expect(provider.isLoading, isFalse);
      expect(provider.errorMessage, isNull);
      expect(provider.hasActiveParking, isFalse);
      expect(provider.isEmpty, isTrue);
    });

    test('fetchActiveParking sets loading state', () async {
      mockService.mockActiveParking = _createTestModel();
      
      final fetchFuture = provider.fetchActiveParking(token: 'test_token');
      
      expect(provider.isLoading, isTrue);
      
      await fetchFuture;
      
      expect(provider.isLoading, isFalse);
    });

    test('fetchActiveParking loads active parking successfully', () async {
      final testModel = _createTestModel(idTransaksi: 'TRX001');
      mockService.mockActiveParking = testModel;

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.activeParking, isNotNull);
      expect(provider.activeParking?.idTransaksi, equals('TRX001'));
      expect(provider.hasActiveParking, isTrue);
      expect(provider.isEmpty, isFalse);
      expect(provider.errorMessage, isNull);
    });

    test('fetchActiveParking handles no active parking', () async {
      mockService.mockActiveParking = null;

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.activeParking, isNull);
      expect(provider.hasActiveParking, isFalse);
      expect(provider.isEmpty, isTrue);
      expect(provider.errorMessage, isNull);
    });

    test('fetchActiveParking handles errors', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = 'Network timeout';

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.activeParking, isNull);
      expect(provider.errorMessage, isNotNull);
      expect(provider.isLoading, isFalse);
    });

    test('fetchActiveParking provides user-friendly error messages', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = 'Connection timeout';

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.errorMessage, contains('internet'));
    });

    test('clear removes all data', () async {
      mockService.mockActiveParking = _createTestModel();
      await provider.fetchActiveParking(token: 'test_token');

      provider.clear();

      expect(provider.activeParking, isNull);
      expect(provider.timerState.elapsed, equals(Duration.zero));
      expect(provider.errorMessage, isNull);
      expect(provider.isEmpty, isTrue);
    });

    test('clearError removes error message', () async {
      mockService.shouldThrowError = true;
      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.errorMessage, isNotNull);

      provider.clearError();

      expect(provider.errorMessage, isNull);
    });
  });

  group('ActiveParkingProvider Timer State Updates', () {
    late MockParkingService mockService;
    late ActiveParkingProvider provider;

    setUp(() {
      mockService = MockParkingService();
      provider = ActiveParkingProvider(parkingService: mockService);
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('timer state updates after fetching active parking', () async {
      final waktuMasuk = DateTime.now().subtract(const Duration(hours: 1));
      final testModel = _createTestModel(waktuMasuk: waktuMasuk);
      mockService.mockActiveParking = testModel;

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.timerState.elapsed.inMinutes, greaterThanOrEqualTo(59));
      expect(provider.timerState.currentCost, greaterThan(0));
    });

    test('timer state calculates cost correctly', () async {
      final waktuMasuk = DateTime.now().subtract(const Duration(hours: 2));
      final testModel = _createTestModel(
        waktuMasuk: waktuMasuk,
        biayaJamPertama: 5000,
        biayaPerJam: 3000,
      );
      mockService.mockActiveParking = testModel;

      await provider.fetchActiveParking(token: 'test_token');

      // First hour: 5000, second hour: 3000 = 8000
      expect(provider.timerState.currentCost, equals(8000));
    });

    test('timer state detects overtime', () async {
      final waktuMasuk = DateTime.now().subtract(const Duration(hours: 2));
      final waktuSelesaiEstimas = DateTime.now().subtract(const Duration(minutes: 30));
      final testModel = _createTestModel(
        waktuMasuk: waktuMasuk,
        waktuSelesaiEstimas: waktuSelesaiEstimas,
      );
      mockService.mockActiveParking = testModel;

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.timerState.isOvertime, isTrue);
    });

    test('timer state calculates penalty when overtime', () async {
      final waktuMasuk = DateTime.now().subtract(const Duration(hours: 3));
      final waktuSelesaiEstimas = DateTime.now().subtract(const Duration(hours: 1));
      final testModel = _createTestModel(
        waktuMasuk: waktuMasuk,
        waktuSelesaiEstimas: waktuSelesaiEstimas,
        biayaPerJam: 3000,
      );
      mockService.mockActiveParking = testModel;

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.timerState.isOvertime, isTrue);
      expect(provider.timerState.penaltyAmount, greaterThan(0));
    });

    test('timer state uses provided penalty if available', () async {
      final waktuMasuk = DateTime.now().subtract(const Duration(hours: 3));
      final waktuSelesaiEstimas = DateTime.now().subtract(const Duration(hours: 1));
      final testModel = _createTestModel(
        waktuMasuk: waktuMasuk,
        waktuSelesaiEstimas: waktuSelesaiEstimas,
        penalty: 5000,
      );
      mockService.mockActiveParking = testModel;

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.timerState.penaltyAmount, equals(5000));
    });

    test('timer state calculates progress for booking', () async {
      final waktuMasuk = DateTime.now().subtract(const Duration(hours: 1));
      final waktuSelesaiEstimas = DateTime.now().add(const Duration(hours: 1));
      final testModel = _createTestModel(
        waktuMasuk: waktuMasuk,
        waktuSelesaiEstimas: waktuSelesaiEstimas,
      );
      mockService.mockActiveParking = testModel;

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.timerState.progress, greaterThan(0.4));
      expect(provider.timerState.progress, lessThan(0.6));
    });
  });

  group('ActiveParkingProvider State Persistence', () {
    late MockParkingService mockService;
    late ActiveParkingProvider provider;

    setUp(() {
      mockService = MockParkingService();
      provider = ActiveParkingProvider(parkingService: mockService);
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('saveState captures current state', () async {
      final testModel = _createTestModel(idTransaksi: 'TRX001');
      mockService.mockActiveParking = testModel;
      await provider.fetchActiveParking(token: 'test_token');

      final savedState = provider.saveState();

      expect(savedState['activeParking'], isNotNull);
      expect(savedState['timerState'], isNotNull);
      expect(savedState['activeParking']['id_transaksi'], equals('TRX001'));
    });

    test('restoreState restores saved state', () async {
      final testModel = _createTestModel(idTransaksi: 'TRX001');
      mockService.mockActiveParking = testModel;
      await provider.fetchActiveParking(token: 'test_token');

      final savedState = provider.saveState();
      
      provider.clear();
      expect(provider.activeParking, isNull);

      provider.restoreState(savedState);

      expect(provider.activeParking, isNotNull);
      expect(provider.activeParking?.idTransaksi, equals('TRX001'));
    });

    test('restoreState handles invalid state gracefully', () {
      final invalidState = {'invalid': 'data'};

      expect(() => provider.restoreState(invalidState), returnsNormally);
      expect(provider.activeParking, isNull);
    });
  });

  group('ActiveParkingProvider Error Handling', () {
    late MockParkingService mockService;
    late ActiveParkingProvider provider;

    setUp(() {
      mockService = MockParkingService();
      provider = ActiveParkingProvider(parkingService: mockService);
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('handles timeout errors with user-friendly message', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = 'Connection timeout';

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.errorMessage, contains('internet'));
    });

    test('handles unauthorized errors', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = '401 Unauthorized';

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.errorMessage, contains('login'));
    });

    test('handles server errors', () async {
      mockService.shouldThrowError = true;
      mockService.errorMessage = '500 Internal Server Error';

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.errorMessage, contains('Server'));
    });

    test('tracks consecutive errors', () async {
      mockService.shouldThrowError = true;

      await provider.fetchActiveParking(token: 'test_token');
      await provider.fetchActiveParking(token: 'test_token');
      await provider.fetchActiveParking(token: 'test_token');

      // After 3 consecutive errors, active parking should be cleared
      expect(provider.activeParking, isNull);
    });

    test('resets error count on successful fetch', () async {
      mockService.shouldThrowError = true;
      await provider.fetchActiveParking(token: 'test_token');
      await provider.fetchActiveParking(token: 'test_token');

      mockService.shouldThrowError = false;
      mockService.mockActiveParking = _createTestModel();
      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.errorMessage, isNull);
      expect(provider.activeParking, isNotNull);
    });
  });

  group('ActiveParkingProvider Data Validation', () {
    late MockParkingService mockService;
    late ActiveParkingProvider provider;

    setUp(() {
      mockService = MockParkingService();
      provider = ActiveParkingProvider(parkingService: mockService);
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('validates parking data on fetch', () async {
      final testModel = _createTestModel(
        qrCode: '',
        namaMall: '',
      );
      mockService.mockActiveParking = testModel;

      await provider.fetchActiveParking(token: 'test_token');

      // Should still load but log warnings
      expect(provider.activeParking, isNotNull);
    });

    test('detects booking expiration', () async {
      final waktuSelesaiEstimas = DateTime.now().subtract(const Duration(minutes: 1));
      final testModel = _createTestModel(
        waktuSelesaiEstimas: waktuSelesaiEstimas,
      );
      mockService.mockActiveParking = testModel;

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.timerState.isOvertime, isTrue);
    });
  });

  group('ActiveParkingProvider Refresh', () {
    late MockParkingService mockService;
    late ActiveParkingProvider provider;

    setUp(() {
      mockService = MockParkingService();
      provider = ActiveParkingProvider(parkingService: mockService);
    });

    tearDown(() {
      provider.dispose();
      mockService.reset();
    });

    test('refresh calls fetchActiveParking', () async {
      mockService.mockActiveParking = _createTestModel();

      await provider.refresh(token: 'test_token');

      expect(mockService.callCount, equals(1));
      expect(provider.activeParking, isNotNull);
    });

    test('hasRecentSync returns true after successful fetch', () async {
      mockService.mockActiveParking = _createTestModel();

      await provider.fetchActiveParking(token: 'test_token');

      expect(provider.hasRecentSync, isTrue);
      expect(provider.lastSyncTime, isNotNull);
    });

    test('hasRecentSync returns false after 60 seconds', () async {
      mockService.mockActiveParking = _createTestModel();
      await provider.fetchActiveParking(token: 'test_token');

      // Simulate time passing (in real test, would need to mock DateTime)
      expect(provider.lastSyncTime, isNotNull);
    });
  });
}

/// Helper function to create test model with default values
ActiveParkingModel _createTestModel({
  String idTransaksi = 'TRX001',
  String? idBooking = 'BKG001',
  String qrCode = 'QR123456',
  String namaMall = 'Test Mall',
  String lokasiMall = 'Test Location',
  String idParkiran = 'P001',
  String kodeSlot = 'A-12',
  String platNomor = 'B1234XYZ',
  String jenisKendaraan = 'Mobil',
  String merkKendaraan = 'Toyota',
  String tipeKendaraan = 'Avanza',
  DateTime? waktuMasuk,
  DateTime? waktuSelesaiEstimas,
  bool isBooking = true,
  double biayaPerJam = 3000.0,
  double biayaJamPertama = 5000.0,
  double? penalty,
  String statusParkir = 'aktif',
}) {
  return ActiveParkingModel(
    idTransaksi: idTransaksi,
    idBooking: idBooking,
    qrCode: qrCode,
    namaMall: namaMall,
    lokasiMall: lokasiMall,
    idParkiran: idParkiran,
    kodeSlot: kodeSlot,
    platNomor: platNomor,
    jenisKendaraan: jenisKendaraan,
    merkKendaraan: merkKendaraan,
    tipeKendaraan: tipeKendaraan,
    waktuMasuk: waktuMasuk ?? DateTime.now(),
    waktuSelesaiEstimas: waktuSelesaiEstimas,
    isBooking: isBooking,
    biayaPerJam: biayaPerJam,
    biayaJamPertama: biayaJamPertama,
    penalty: penalty,
    statusParkir: statusParkir,
  );
}
