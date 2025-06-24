class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  UserSession._internal();

  int? userId;

  bool get isLoggedIn => userId != null;

  void clear() {
    userId = null;
  }
}
