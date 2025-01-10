// ignore_for_file: dead_code, constant_identifier_names

import 'package:flutter/material.dart';
import 'package:farma_app_v2/apis/api.dart';
import 'package:farma_app_v2/autenticador.dart';
import 'package:farma_app_v2/componentes/produtocard.dart';
import 'package:farma_app_v2/estado.dart';
import 'package:farma_app_v2/usuario.dart';
import 'package:toast/toast.dart';

class Produtos extends StatefulWidget {
  const Produtos({super.key});

  @override
  State<StatefulWidget> createState() {
    return _EstadoProdutos();
  }
}

const int TAMANHO_DA_PAGINA = 4;

class _EstadoProdutos extends State<Produtos> {
  List<dynamic> _produtos = [];

  final ScrollController _controladorListaProdutos = ScrollController();
  final TextEditingController _controladorDoFiltro = TextEditingController();

  late DragStartDetails startVerticalDragDetails;
  late DragUpdateDetails updateVerticalDragDetails;

  // ignore: unused_field
  String _filtro = "";

  late ServicoProdutos _servicoProdutos;
  int _ultimoProduto = 0;

  @override
  void initState() {
    super.initState();

    ToastContext().init(context);
    _servicoProdutos = ServicoProdutos();

    _controladorListaProdutos.addListener(() {
      if (_controladorListaProdutos.position.pixels ==
          _controladorListaProdutos.position.maxScrollExtent) {
        _carregarProdutos();
      }
    });

    _carregarProdutos();
    _recuperarUsuario();
  }

  void _recuperarUsuario() {
    final usuario = Autenticador.recuperarUsuario();
    estadoApp.login(usuario);
  }

  void _carregarProdutos() {
    _servicoProdutos
        .getProdutos(_ultimoProduto, TAMANHO_DA_PAGINA)
        .then((produtos) {
      setState(() {
        if (produtos.isNotEmpty) {
          _ultimoProduto = produtos.last["id"];
        }

        _produtos.addAll(produtos);
      });
    });
  }

  Future<void> _atualizarProdutos() async {
    _produtos = [];
    _ultimoProduto = 0;

    _controladorDoFiltro.text = "";
    _filtro = "";

    _carregarProdutos();
  }

  void _aplicarFiltro(String filtro) {
    _filtro = filtro;

    _carregarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    bool usuarioLogado = estadoApp.usuario != null;

    return Scaffold(
        appBar: AppBar(actions: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, left: 60, right: 20),
                  child: TextField(
                    controller: _controladorDoFiltro,
                    onSubmitted: (filtro) {
                      _aplicarFiltro(filtro);
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search)),
                  ))),
          usuarioLogado
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      estadoApp.logout();
                    });

                    Toast.show("Você deslogou no aplicativo",
                        duration: Toast.lengthLong, gravity: Toast.bottom);
                  },
                  icon: const Icon(Icons.logout))
              : IconButton(
                  onPressed: () {
                    final usuario = Autenticador.recuperarUsuario();

                    setState(() {
                      estadoApp.login(usuario);
                    });

                    Toast.show("Você logou no aplcativo",
                        duration: Toast.lengthLong, gravity: Toast.bottom);
                  },
                  icon: const Icon(Icons.login))
        ]),
        body: RefreshIndicator(
            color: Colors.blueAccent,
            onRefresh: () => _atualizarProdutos(),
            child: GridView.builder(
                controller: _controladorListaProdutos,
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 0.5,
                ),
                itemCount: _produtos.length,
                itemBuilder: (context, index) {
                  return ProdutoCard(produto: _produtos[index]);
                })));
  }
}
