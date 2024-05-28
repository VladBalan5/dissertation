class UserModel {
  final String email;
  final String phoneNumber;
  final String profilePicUrl;
  final String userId;
  final String userName;
  final String aesKey;
  final String aesIV;
  final String publicKey;

  UserModel({
    required this.email,
    required this.phoneNumber,
    required this.profilePicUrl,
    required this.userId,
    required this.userName,
    required this.aesKey,
    required this.aesIV,
    required this.publicKey,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String userId) {
    return UserModel(
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePicUrl: data['profilePicUrl'] ?? '',
      userId: userId,
      userName: data['userName'] ?? '',
      aesKey: data['aesKey'] ?? '',
      aesIV: data['aesIV'] ?? '',
      publicKey: data['publicKey'] ?? '',
    );
  }
}
