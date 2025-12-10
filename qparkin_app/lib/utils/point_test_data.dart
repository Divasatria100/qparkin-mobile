import '../data/models/point_history_model.dart';

/// Helper class to generate test data for point history
/// Used for development and testing purposes
class PointTestData {
  /// Generate sample point history with both additions and deductions
  static List<PointHistory> generateSampleHistory() {
    final now = DateTime.now();
    
    return [
      // Recent additions
      PointHistory(
        idPoin: 1,
        idUser: 1,
        idTransaksi: 101,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'SNL Food Bengkong | Garden Avenue Square, Bengkong, Batam',
        waktu: now.subtract(const Duration(hours: 1)),
      ),
      PointHistory(
        idPoin: 2,
        idUser: 1,
        idTransaksi: 102,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'Mega Mall Batam Centre | Jl. Engku Putri no.1, Batam Centre',
        waktu: now.subtract(const Duration(days: 1)),
      ),
      PointHistory(
        idPoin: 3,
        idUser: 1,
        idTransaksi: 103,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'SNL Food Bengkong | Garden Avenue Square, Bengkong, Batam',
        waktu: now.subtract(const Duration(days: 2)),
      ),
      PointHistory(
        idPoin: 4,
        idUser: 1,
        idTransaksi: 104,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'Mega Mall Batam Centre | Jl. Engku Putri no.1, Batam Centre',
        waktu: now.subtract(const Duration(days: 3)),
      ),
      
      // Some deductions
      PointHistory(
        idPoin: 5,
        idUser: 1,
        idTransaksi: 105,
        poin: 50,
        perubahan: 'kurang',
        keterangan: 'Gunakan poin untuk booking | Mega Mall Batam Centre',
        waktu: now.subtract(const Duration(days: 5)),
      ),
      PointHistory(
        idPoin: 6,
        idUser: 1,
        idTransaksi: 106,
        poin: 30,
        perubahan: 'kurang',
        keterangan: 'Gunakan poin untuk booking | SNL Food Bengkong',
        waktu: now.subtract(const Duration(days: 7)),
      ),
      
      // More additions
      PointHistory(
        idPoin: 7,
        idUser: 1,
        idTransaksi: 107,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'BCS Mall | Jl. Raja Ali Haji, Batam',
        waktu: now.subtract(const Duration(days: 10)),
      ),
      PointHistory(
        idPoin: 8,
        idUser: 1,
        idTransaksi: 108,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'Harbour Bay Mall | Jl. Duyung, Batam',
        waktu: now.subtract(const Duration(days: 12)),
      ),
      PointHistory(
        idPoin: 9,
        idUser: 1,
        idTransaksi: 109,
        poin: 15,
        perubahan: 'tambah',
        keterangan: 'Grand Batam Mall | Jl. Ahmad Yani, Batam',
        waktu: now.subtract(const Duration(days: 15)),
      ),
      PointHistory(
        idPoin: 10,
        idUser: 1,
        idTransaksi: 110,
        poin: 25,
        perubahan: 'kurang',
        keterangan: 'Gunakan poin untuk booking | BCS Mall',
        waktu: now.subtract(const Duration(days: 18)),
      ),
    ];
  }

  /// Calculate total balance from history
  static int calculateBalance(List<PointHistory> history) {
    int balance = 0;
    for (var item in history) {
      if (item.isAddition) {
        balance += item.poin;
      } else {
        balance -= item.poin;
      }
    }
    return balance;
  }
}
