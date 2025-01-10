import 'package:flutter/material.dart';
import 'package:farma_app_v2/usuario.dart';

enum Situacao { mostrandoProdutos, mostrandoDetalhes }

class Estado extends ChangeNotifier {
  Situacao _situacao = Situacao.mostrandoProdutos;

  double _altura = 0, _largura = 0;
  double get altura => _altura;
  double get largura => _largura;

  late int _idProduto;
  int get idProduto => _idProduto;

  Usuario? _usuario;
  Usuario? get usuario => _usuario;

  void setDimensoes(double altura, double largura) {
    _altura = altura;
    _largura = largura;
  }

  void mostrarProdutos() {
    _situacao = Situacao.mostrandoProdutos;

    notifyListeners();
  }

  bool mostrandoProdutos() {
    return _situacao == Situacao.mostrandoProdutos;
  }

  void mostrarDetalhes(int idProduto) {
    _situacao = Situacao.mostrandoDetalhes;
    _idProduto = idProduto;

    notifyListeners();
  }

  void login(Usuario? usuario) {
    _usuario = usuario;

    notifyListeners();
  }

  void logout() {
    _usuario = null;

    notifyListeners();
  }

  bool mostrandoDetalhes() {
    return _situacao == Situacao.mostrandoDetalhes;
  }
}

late Estado estadoApp;
