class User {
  String name;
  String email;
  String role;

  User({
    required this.name,
    required this.email,
    required this.role,
  });
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'],
      email: map['email'],
      role: map['role'],
    );
  }
  String getName()
  {
    return name;
  }
  String getEmail()
  {
    return email;
  }
  String getRole()
  {
    return role;
  }
  void setName(name){
    this.name = name;
  }
  void setEmail(email){
    this.email = email;
  }
  void setRole(role){
    this.role = role;
  }
  Map<String , dynamic> getMap()
  {
    return  <String, dynamic>{
      "name": name,
      "email":email,
      "role":role
    };
  }

}