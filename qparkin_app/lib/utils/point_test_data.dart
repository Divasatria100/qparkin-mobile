import '../data/models/point_history_model.dart';
import '../data/models/point_statistics_model.dart';

/// Utility class for generating test data for point system
///
/// Provides mock data for development and testing purposes.
/// This should be removed or disabled in production.
///
/// Requirements: Testing & Development
class PointTestData {
  /// Generate sample point history with various transaction types
  static List<PointHistory> generateSampleHistory() {
    final now = DateTime.now();
    
    return [
      // Recent transactions
      PointHistory(
        idPoin: 1,
        idUser: 1,
        poin: 50,
        perubahan: 'tambah',
        keterangan: 'Booking parkir di Grand Mall',
        waktu: now.subtract(const Duration(hours: 2)),
      ),
      PointHistory(
        idPoin: 2,
        idUser: 1,
        poin: 100,
        perubahan: 'kurang',
        keterangan: 'Gunakan poin untuk pembayaran parkir',
        waktu: now.subtract(const Duration(hours: 5)),
      ),
      PointHistory(
        idPoin: 3,
        idUser: 1,
        poin: 75,
        perubahan: 'tambah',
        keterangan: 'Booking parkir di Plaza Indonesia',
        waktu: now.subtract(const Duration(days: 1)),
      ),
      
      // Yesterday
      PointHistory(
        idPoin: 4,
        idUser: 1,
        poin: 50,
        perubahan: 'kurang',
        keterangan: 'Gunakan poin untuk diskon parkir',
        waktu: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      PointHistory(
        idPoin: 5,
        idUser: 1,
        poin: 100,
        perubahan: 'tambah',
        keterangan: 'Booking parkir di Senayan City',
        waktu: now.subtract(const Duration(days: 2)),
      ),
      
      // Last week
      PointHistory(
        idPoin: 6,
        idUser: 1,
        poin: 25,
        perubahan: 'tambah',
        keterangan: 'Bonus poin member baru',
        waktu: now.subtract(const Duration(days: 3)),
      ),
      PointHistory(
        idPoin: 7,
        idUser: 1,
        poin: 150,
        perubahan: 'tambah',
        keterangan: 'Booking parkir di Pacific Place',
        waktu: now.subtract(const Duration(days: 5)),
      ),
      PointHistory(
        idPoin: 8,
        idUser: 1,
        poin: 75,
        perubahan: 'kurang',
        keterangan: 'Gunakan poin untuk pembayaran',
        waktu: now.subtract(const Duration(days: 6)),
      ),
      
      // Last month
      PointHistory(
        idPoin: 9,
        idUser: 1,
        poin: 200,
        perubahan: 'tambah',
        keterangan: 'Booking parkir di Mall Taman Anggrek',
        waktu: now.subtract(const Duration(days: 15)),
      ),
      PointHistory(
        idPoin: 10,
        idUser: 1,
        poin: 100,
        perubahan: 'kurang',
        keterangan: 'Gunakan poin untuk diskon',
        waktu: now.subtract(const Duration(days: 20)),
      ),
      PointHistory(
        idPoin: 11,
        idUser: 1,
        poin: 50,
        perubahan: 'tambah',
        keterangan: 'Booking parkir di Central Park',
        waktu: now.subtract(const Duration(days: 25)),
      ),
      PointHistory(
        idPoin: 12,
        idUser: 1,
        poin: 125,
        perubahan: 'tambah',
        keterangan: 'Booking parkir di Pondok Indah Mall',
        waktu: now.subtract(const Duration(days: 28)),
      ),
      
      // Older transactions
      PointHistory(
        idPoin: 13,
        idUser: 1,
        poin: 50,
        perubahan: 'kurang',
        keterangan: 'Gunakan poin untuk pembayaran',
        waktu: now.subtract(const Duration(days: 35)),
      ),
      PointHistory(
        idPoin: 14,
        idUser: 1,
        poin: 100,
        perubahan: 'tambah',
        keterangan: 'Booking parkir di Kota Kasablanka',
        waktu: now.subtract(const Duration(days: 40)),
      ),
      PointHistory(
        idPoin: 15,
        idUser: 1,
        poin: 75,
        perubahan: 'tambah',
        keterangan: 'Booking parkir di Gandaria City',
        waktu: now.subtract(const Duration(days: 50)),
      ),
    ];
  }

  /// Calculate balance from history
  static int calculateBalance(List<PointHistory> history) {
    int balance = 0;
    
    for (final item in history) {
      if (item.isAddition) {
        balance += item.poin;
      } else {
        balance -= item.poin;
      }
    }
    
    return balance;
  }

  /// Generate sample statistics based on history
  static PointStatistics generateSampleStatistics({
    List<PointHistory>? history,
  }) {
    final historyList = history ?? generateSampleHistory();
    
    int totalEarned = 0;
    int totalUsed = 0;
    DateTime? lastTransaction;
    
    for (final item in historyList) {
      if (item.isAddition) {
        totalEarned += item.poin;
      } else {
        totalUsed += item.poin;
      }
      
      if (lastTransaction == null || item.waktu.isAfter(lastTransaction)) {
        lastTransaction = item.waktu;
      }
    }
    
    return PointStatistics(
      totalEarned: totalEarned,
      totalUsed: totalUsed,
      currentBalance: totalEarned - totalUsed,
      transactionCount: historyList.length,
      lastTransaction: lastTransaction,
    );
  }

  /// Generate empty history for testing empty state
  static List<PointHistory> generateEmptyHistory() {
    return [];
  }

  /// Generate single transaction for testing
  static PointHistory generateSingleTransaction({
    bool isAddition = true,
    int amount = 100,
  }) {
    return PointHistory(
      idPoin: 1,
      idUser: 1,
      poin: amount,
      perubahan: isAddition ? 'tambah' : 'kurang',
      keterangan: isAddition
          ? 'Booking parkir di Test Mall'
          : 'Gunakan poin untuk pembayaran',
      waktu: DateTime.now(),
    );
  }

  /// Generate large history for testing pagination
  static List<PointHistory> generateLargeHistory({int count = 100}) {
    final List<PointHistory> history = [];
    final now = DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final isAddition = i % 3 != 0; // 2/3 additions, 1/3 deductions
      final amount = (i % 5 + 1) * 25; // 25, 50, 75, 100, 125
      
      history.add(
        PointHistory(
          idPoin: i + 1,
          idUser: 1,
          poin: amount,
          perubahan: isAddition ? 'tambah' : 'kurang',
          keterangan: isAddition
              ? 'Booking parkir di Mall ${i + 1}'
              : 'Gunakan poin untuk pembayaran ${i + 1}',
          waktu: now.subtract(Duration(hours: i * 2)),
        ),
      );
    }
    
    return history;
  }

  /// Generate history with specific date range for testing filters
  static List<PointHistory> generateHistoryInDateRange({
    required DateTime startDate,
    required DateTime endDate,
    int count = 10,
  }) {
    final List<PointHistory> history = [];
    final daysDiff = endDate.difference(startDate).inDays;
    
    for (int i = 0; i < count; i++) {
      final daysOffset = (daysDiff / count * i).floor();
      final transactionDate = startDate.add(Duration(days: daysOffset));
      
      history.add(
        PointHistory(
          idPoin: i + 1,
          idUser: 1,
          poin: (i % 4 + 1) * 50,
          perubahan: i % 2 == 0 ? 'tambah' : 'kurang',
          keterangan: 'Transaction ${i + 1}',
          waktu: transactionDate,
        ),
      );
    }
    
    return history;
  }

  /// Generate history with specific amount range for testing filters
  static List<PointHistory> generateHistoryInAmountRange({
    required int minAmount,
    required int maxAmount,
    int count = 10,
  }) {
    final List<PointHistory> history = [];
    final amountRange = maxAmount - minAmount;
    
    for (int i = 0; i < count; i++) {
      final amount = minAmount + (amountRange / count * i).floor();
      
      history.add(
        PointHistory(
          idPoin: i + 1,
          idUser: 1,
          poin: amount,
          perubahan: i % 2 == 0 ? 'tambah' : 'kurang',
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
  static PointStatistics generateMockStatistics() {
    return generateSampleStatistics();
  }
}
