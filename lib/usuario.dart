class Usuario {
  String? _nome;
  String? get nome => _nome;
  set nome(String? nome) {
    _nome = nome;
  }

  String? _email;
  String? get email => _email;
  set email(String? email) {
    _email = email;
  }

  Usuario(String? nome, String? email) {
    _nome = nome;
    _email = email;
  }
}
