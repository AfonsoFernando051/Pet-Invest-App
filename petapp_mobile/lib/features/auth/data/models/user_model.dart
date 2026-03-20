class UserModel {
  final String email;
  final String? token;
  
  UserModel({required this.email, this.token});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      token: json['token'],
    );
  }
}
