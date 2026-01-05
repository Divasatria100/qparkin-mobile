/// Model representing a user in the QPARKIN system
class UserModel {
  final String id;
  final String name;
  final String? email; // Made nullable to support optional email
  final String? phoneNumber;
  final String? photoUrl;
  final int saldoPoin;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    this.email, // Email is now optional
    this.phoneNumber,
    this.photoUrl,
    this.saldoPoin = 0,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(), // Allow null email
      phoneNumber: json['phone_number']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      saldoPoin: json['saldo_poin'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'photo_url': photoUrl,
      'saldo_poin': saldoPoin,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with method that properly handles null values
  /// 
  /// IMPORTANT: To explicitly set a field to null, pass null as the value.
  /// To keep the existing value, don't pass the parameter at all.
  /// 
  /// This uses a special approach where we check if parameters are provided
  /// using named parameters with default values.
  UserModel copyWith({
    String? id,
    String? name,
    Object? email = const _Undefined(), // Use Object to allow explicit null
    Object? phoneNumber = const _Undefined(),
    Object? photoUrl = const _Undefined(),
    int? saldoPoin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email is _Undefined ? this.email : email as String?,
      phoneNumber: phoneNumber is _Undefined ? this.phoneNumber : phoneNumber as String?,
      photoUrl: photoUrl is _Undefined ? this.photoUrl : photoUrl as String?,
      saldoPoin: saldoPoin ?? this.saldoPoin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Private class to distinguish between "not provided" and "explicitly null"
class _Undefined {
  const _Undefined();
}
