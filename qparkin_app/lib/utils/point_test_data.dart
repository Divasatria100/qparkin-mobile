import '../data/models/point_history_model.dart';
import '../data/models/point_statistics_model.dart';

/// Utility class for generating test data for point system
///
/// Provides mock data for development and testing purposes.
/// This should be removed or disabled in production.
///
/// Business Logic:
/// - Uses 'earned' and 'used' terminology (not 'tambah'/'kurang')
/// - 1 poin = Rp100 discount value
///
/// Requirements: Testing & Development
class PointTestData {
  /// Generate sample point history with various transaction types
  static List<PointHistoryModel> generateSampleHistory() {
    final now = DateTime.now();
    
    return [
      // Recent transactions
      PointHistoryModel(
        idPoin: '1',
        idUser: '1',
        poin: 50,
        perubahan: 'earned',
        keterangan: 'Parkir di Grand Mall - Rp50.000',
        waktu: now.subtract(const Duration(hours: 2)),
      ),
      PointHistoryModel(
        idPoin: '2',
        idUser: '1',
        poin: 100,
        perubahan: 'used',
        keterangan: 'Diskon booking parkir - Rp10.000',
        waktu: now.subtract(const Duration(hours: 5)),
      ),
      PointHistoryModel(
        idPoin: '3',
        idUser: '1',
        poin: 75,
        perubahan: 'earned',
        keterangan: 'Parkir di Plaza Indonesia - Rp75.000',
        waktu: now.subtract(const Duration(days: 1)),
      ),
      
      // Yesterday
      PointHistoryModel(
        idPoin: '4',
        idUser: '1',
        poin: 50,
        perubahan: 'used',
        keterangan: 'Diskon parkir - Rp5.000',
        waktu: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      PointHistoryModel(
        idPoin: '5',
        idUser: '1',
        poin: 100,
        perubahan: 'earned',
        keterangan: 'Parkir di Senayan City - Rp100.000',
        waktu: now.subtract(const Duration(days: 2)),
      ),
      
      // Last week
      PointHistoryModel(
        idPoin: '6',
        idUser: '1',
        poin: 25,
        perubahan: 'earned',
        keterangan: 'Parkir di Central Park - Rp25.000',
        waktu: now.subtract(const Duration(days: 3)),
      ),
      PointHistoryModel(
        idPoin: '7',
        idUser: '1',
        poin: 150,
        perubahan: 'earned',
        keterangan: 'Parkir di Pacific Place - Rp150.000',
        waktu: now.subtract(const Duration(days: 5)),
      ),
      PointHistoryModel(
        idPoin: '8',
        idUser: '1',
        poin: 75,
        perubahan: 'used',
        keterangan: 'Diskon booking - Rp7.500',
        waktu: now.subtract(const Duration(days: 6)),
      ),
      
      // Last month
      PointHistoryModel(
        idPoin: '9',
        idUser: '1',
        poin: 200,
        perubahan: 'earned',
        keterangan: 'Parkir di Mall Taman Anggrek - Rp200.000',
        waktu: now.subtract(const Duration(days: 15)),
      ),
      PointHistoryModel(
        idPoin: '10',
        idUser: '1',
        poin: 100,
        perubahan: 'used',
        keterangan: 'Diskon parkir - Rp10.000',
        waktu: now.subtract(const Duration(days: 20)),
      ),
      PointHistoryModel(
        idPoin: '11',
        idUser: '1',
        poin: 50,
        perubahan: 'earned',
        keterangan: 'Parkir di Central Park - Rp50.000',
        waktu: now.subtract(const Duration(days: 25)),
      ),
      PointHistoryModel(
        idPoin: '12',
        idUser: '1',
        poin: 125,
        perubahan: 'earned',
        keterangan: 'Parkir di Pondok Indah Mall - Rp125.000',
        waktu: now.subtract(const Duration(days: 28)),
      ),
      
      // Older transactions
      PointHistoryModel(
        idPoin: '13',
        idUser: '1',
        poin: 50,
        perubahan: 'used',
        keterangan: 'Diskon parkir - Rp5.000',
        waktu: now.subtract(const Duration(days: 35)),
      ),
      PointHistoryModel(
        idPoin: '14',
        idUser: '1',
        poin: 100,
        perubahan: 'earned',
        keterangan: 'Parkir di Kota Kasablanka - Rp100.000',
        waktu: now.subtract(const Duration(days: 40)),
      ),
      PointHistoryModel(
        idPoin: '15',
        idUser: '1',
        poin: 75,
        perubahan: 'earned',
        keterangan: 'Parkir di Gandaria City - Rp75.000',
        waktu: now.subtract(const Duration(days: 50)),
      ),
    ];
  }

  /// Calculate balance from history
  static int calculateBalance(List<PointHistoryModel> history) {
    int balance = 0;
    
    for (final item in history) {
      if (item.isEarned) {
        balance += item.absolutePoints;
      } else {
        balance -= item.absolutePoints;
      }
    }
    
    return balance;
  }

  /// Generate sample statistics based on history
  static PointStatisticsModel generateSampleStatistics({
    List<PointHistoryModel>? history,
  }) {
    final historyList = history ?? generateSampleHistory();
    
    int totalEarned = 0;
    int totalUsed = 0;
    DateTime? lastTransaction;
    
    for (final item in historyList) {
      if (item.isEarned) {
        totalEarned += item.absolutePoints;
      } else {
        totalUsed += item.absolutePoints;
      }
      
      if (lastTransaction == null || item.waktu.isAfter(lastTransaction)) {
        lastTransaction = item.waktu;
      }
    }
    
    return PointStatisticsModel(
      totalEarned: totalEarned,
      totalUsed: totalUsed,
      currentBalance: totalEarned - totalUsed,
      transactionCount: historyList.length,
      lastTransaction: lastTransaction,
    );
  }

  /// Generate empty history for testing empty state
  static List<PointHistoryModel> generateEmptyHistory() {
    return [];
  }

  /// Generate single transaction for testing
  static PointHistoryModel generateSingleTransaction({
    bool isEarned = true,
    int amount = 100,
  }) {
    return PointHistoryModel(
      idPoin: '1',
      idUser: '1',
      poin: amount,
      perubahan: isEarned ? 'earned' : 'used',
      keterangan: isEarned
          ? 'Parkir di Test Mall - Rp${amount * 1000}'
          : 'Diskon parkir - Rp${amount * 100}',
      waktu: DateTime.now(),
    );
  }

  /// Generate large history for testing pagination
  static List<PointHistoryModel> generateLargeHistory({int count = 100}) {
    final List<PointHistoryModel> history = [];
    final now = DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final isEarned = i % 3 != 0; // 2/3 earned, 1/3 used
      final amount = (i % 5 + 1) * 25; // 25, 50, 75, 100, 125
      
      history.add(
        PointHistoryModel(
          idPoin: '${i + 1}',
          idUser: '1',
          poin: amount,
          perubahan: isEarned ? 'earned' : 'used',
          keterangan: isEarned
              ? 'Parkir di Mall ${i + 1} - Rp${amount * 1000}'
              : 'Diskon parkir ${i + 1} - Rp${amount * 100}',
          waktu: now.subtract(Duration(hours: i * 2)),
        ),
      );
    }
    
    return history;
  }

  /// Generate history with specific date range for testing filters
  static List<PointHistoryModel> generateHistoryInDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int count = 10,
  }) {
    final List<PointHistoryModel> history = [];
    final daysDiff = endDate.difference(startDate).inDays;
    
    for (int i = 0; i < count; i++) {
      final daysOffset = (daysDiff / count * i).floor();
      final transactionDate = startDate.add(Duration(days: daysOffset));
      final amount = (i % 4 + 1) * 50;
      final isEarned = i % 2 == 0;
      
      history.add(
        PointHistoryModel(
          idPoin: '${i + 1}',
          idUser: '1',
          poin: amount,
          perubahan: isEarned ? 'earned' : 'used',
          keterangan: 'Transaction ${i + 1}',
          waktu: transactionDate,
        ),
      );
    }
    
    return history;
  }

  /// Generate history with specific amount range for testing filters
  static List<PointHistoryModel> generateHistoryInAmountRange({
    required int minAmount,
    required int maxAmount,
    int count = 10,
  }) {
    final List<PointHistoryModel> history = [];
    final amountRange = maxAmount - minAmount;
    
    for (int i = 0; i < count; i++) {
      final amount = minAmount + (amountRange / count * i).floor();
      final isEarned = i % 2 == 0;
      
      history.add(
        PointHistoryModel(
          idPoin: '${i + 1}',
          idUser: '1',
          poin: amount,
          perubahan: isEarned ? 'earned' : 'used',
          keterangan: 'Transaction $amount poin',
          waktu: DateTime.now().subtract(Duration(days: i)),
        ),
      );
    }
    
    return history;
  }

  /// Mock balance for testing (calculated from sample history)
  static int get mockBalance {
    return calculateBalance(generateSampleHistory());
  }

  /// Generate mock statistics for testing
  static PointStatisticsModel generateMockStatistics() {
    return generateSampleStatistics();
  }
}
