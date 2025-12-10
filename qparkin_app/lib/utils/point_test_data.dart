import '../data/models/point_history_model.dart';

/// Helper class to generate test data for point history
/// Used for development and testing purposes
class PointTestData {
  /// Generate sample point history with both additions and deductions
  /// Total balance will be 200 points to match home page
  static List<PointHistory> generateSampleHistory() {
    final now = DateTime.now();
    
    return [
      // Recent additions - Parkir selesai dapat poin
      PointHistory(
        idPoin: 1,
        idUser: 1,
        idTransaksi: 101,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'SNL Food Bengkong | Garden Avenue Square, Bengkong, Batam',
        waktu: DateTime(2025, 12, 8, 23, 53),
      ),
      PointHistory(
        idPoin: 2,
        idUser: 1,
        idTransaksi: 102,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'Mega Mall Batam Centre | Jl. Engku Putri no.1, Batam Centre',
        waktu: DateTime(2025, 12, 7, 23, 53),
      ),
      PointHistory(
        idPoin: 3,
        idUser: 1,
        idTransaksi: 103,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'SNL Food Bengkong | Garden Avenue Square, Bengkong, Batam',
        waktu: DateTime(2025, 12, 6, 23, 53),
      ),
      PointHistory(
        idPoin: 4,
        idUser: 1,
        idTransaksi: 104,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'Mega Mall Batam Centre | Jl. Engku Putri no.1, Batam Centre',
        waktu: DateTime(2025, 12, 5, 15, 30),
      ),
      PointHistory(
        idPoin: 5,
        idUser: 1,
        idTransaksi: 105,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'BCS Mall | Jl. Raja Ali Haji, Batam',
        waktu: DateTime(2025, 12, 4, 14, 20),
      ),
      PointHistory(
        idPoin: 6,
        idUser: 1,
        idTransaksi: 106,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'Harbour Bay Mall | Jl. Duyung, Batam',
        waktu: DateTime(2025, 12, 3, 16, 45),
      ),
      PointHistory(
        idPoin: 7,
        idUser: 1,
        idTransaksi: 107,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'Grand Batam Mall | Jl. Ahmad Yani, Batam',
        waktu: DateTime(2025, 12, 2, 11, 15),
      ),
      PointHistory(
        idPoin: 8,
        idUser: 1,
        idTransaksi: 108,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'One Batam Mall | Jl. Raja H. Fisabilillah No. 9, Batam Center',
        waktu: DateTime(2025, 12, 1, 13, 30),
      ),
      
      // Deductions - Gunakan poin untuk booking
      PointHistory(
        idPoin: 9,
        idUser: 1,
        idTransaksi: 109,
        poin: 50,
        perubahan: 'kurang',
        keterangan: 'Gunakan poin untuk booking | Mega Mall Batam Centre',
        waktu: DateTime(2025, 11, 30, 10, 20),
      ),
      PointHistory(
        idPoin: 10,
        idUser: 1,
        idTransaksi: 110,
        poin: 30,
        perubahan: 'kurang',
        keterangan: 'Gunakan poin untuk booking | SNL Food Bengkong',
        waktu: DateTime(2025, 11, 28, 14, 45),
      ),
      
      // More additions
      PointHistory(
        idPoin: 11,
        idUser: 1,
        idTransaksi: 111,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'Mega Mall Batam Centre | Jl. Engku Putri no.1, Batam Centre',
        waktu: DateTime(2025, 11, 27, 9, 15),
      ),
      PointHistory(
        idPoin: 12,
        idUser: 1,
        idTransaksi: 112,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'SNL Food Bengkong | Garden Avenue Square, Bengkong, Batam',
        waktu: DateTime(2025, 11, 25, 16, 30),
      ),
      PointHistory(
        idPoin: 13,
        idUser: 1,
        idTransaksi: 113,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'BCS Mall | Jl. Raja Ali Haji, Batam',
        waktu: DateTime(2025, 11, 23, 12, 0),
      ),
      
      // Another deduction
      PointHistory(
        idPoin: 14,
        idUser: 1,
        idTransaksi: 114,
        poin: 25,
        perubahan: 'kurang',
        keterangan: 'Gunakan poin untuk booking | BCS Mall',
        waktu: DateTime(2025, 11, 20, 15, 20),
      ),
      
      // More additions to reach 201 total
      PointHistory(
        idPoin: 15,
        idUser: 1,
        idTransaksi: 115,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'Harbour Bay Mall | Jl. Duyung, Batam',
        waktu: DateTime(2025, 11, 18, 10, 45),
      ),
      PointHistory(
        idPoin: 16,
        idUser: 1,
        idTransaksi: 116,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'Grand Batam Mall | Jl. Ahmad Yani, Batam',
        waktu: DateTime(2025, 11, 15, 14, 30),
      ),
      PointHistory(
        idPoin: 17,
        idUser: 1,
        idTransaksi: 117,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'One Batam Mall | Jl. Raja H. Fisabilillah No. 9, Batam Center',
        waktu: DateTime(2025, 11, 12, 11, 15),
      ),
      PointHistory(
        idPoin: 18,
        idUser: 1,
        idTransaksi: 118,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'Mega Mall Batam Centre | Jl. Engku Putri no.1, Batam Centre',
        waktu: DateTime(2025, 11, 10, 16, 0),
      ),
      PointHistory(
        idPoin: 19,
        idUser: 1,
        idTransaksi: 119,
        poin: 20,
        perubahan: 'tambah',
        keterangan: 'SNL Food Bengkong | Garden Avenue Square, Bengkong, Batam',
        waktu: DateTime(2025, 11, 8, 13, 45),
      ),
      PointHistory(
        idPoin: 20,
        idUser: 1,
        idTransaksi: 120,
        poin: 5,
        perubahan: 'tambah',
        keterangan: 'BCS Mall | Jl. Raja Ali Haji, Batam',
        waktu: DateTime(2025, 11, 5, 15, 20),
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
