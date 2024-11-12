class Users {
  final String name;
  final String phone;
  final String email;
  final String pass;
  final String uid;
  final bool role;

  Users(
      {required this.name,
      required this.phone,
      required this.email,
      required this.pass,
      required this.uid,
      required this.role});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'password': pass,
      'uid': uid,
      'role': role,
    };
  }
}
