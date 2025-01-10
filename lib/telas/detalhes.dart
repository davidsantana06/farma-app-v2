// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:intl/intl.dart';
import 'package:farma_app_v2/apis/api.dart';
import 'package:farma_app_v2/estado.dart';
import 'package:page_view_dot_indicator/page_view_dot_indicator.dart';
import 'package:toast/toast.dart';

class Detalhes extends StatefulWidget {
  const Detalhes({super.key});

  @override
  State<StatefulWidget> createState() {
    return _DetalhesState();
  }
}

enum _EstadoProduto { naoVerificado, temProduto, semProduto }

const TAMANHO_DA_PAGINA = 5;

class _DetalhesState extends State<Detalhes> {
  _EstadoProduto _temProduto = _EstadoProduto.naoVerificado;
  late dynamic _produto;
  int _ultimoComentario = 1;

  List<dynamic> _comentarios = [];
  bool _temComentarios = false;

  final TextEditingController _controladorNovoComentario =
      TextEditingController();
  final ScrollController _controladorListaProdutos = ScrollController();

  late PageController _controladorSlides;
  late int _slideSelecionado;

  late ServicoProdutos _servicoProdutos;
  late ServicoComentarios _servicoComentarios;

  @override
  void initState() {
    super.initState();

    ToastContext().init(context);

    _servicoProdutos = ServicoProdutos();
    _servicoComentarios = ServicoComentarios();

    _iniciarSlides();
    _carregarProduto();
    _carregarComentarios();
  }

  void _iniciarSlides() {
    _slideSelecionado = 0;
    _controladorSlides = PageController(initialPage: _slideSelecionado);
  }

  void _carregarProduto() {
    _servicoProdutos.findProduto(estadoApp.idProduto).then((produto) {
      _produto = produto;

      setState(() {
        _temProduto = _produto != null
            ? _EstadoProduto.temProduto
            : _EstadoProduto.semProduto;
      });
    });
  }

  void _carregarComentarios() {
    _servicoComentarios
        .getComentarios(
            estadoApp.idProduto, _ultimoComentario, TAMANHO_DA_PAGINA)
        .then((comentarios) {
      _temComentarios = comentarios.isNotEmpty;

      if (_temComentarios) {
        _ultimoComentario = comentarios.last['id'];
      }

      setState(() {
        _comentarios = comentarios;
      });
    });
  }

  Widget _exibirMensagemProdutoInexistente() {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(children: [
                    Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Text("Farma App"))
                  ]),
                  GestureDetector(
                      onTap: () {
                        estadoApp.mostrarProdutos();
                      },
                      child: const Icon(Icons.arrow_back))
                ])),
        body: const SizedBox.expand(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error, size: 32, color: Colors.red),
          Text("Produto não encontrado.",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red)),
          Text("Selecione outro produto a partir do feed.",
              style: TextStyle(fontSize: 14))
        ])));
  }

  Widget _exibirMensagemComentariosInexistentes() {
    return const Expanded(
        child: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.error, size: 26, color: Colors.redAccent),
      Text("Ninguém comentou até agora...",
          style: TextStyle(fontSize: 16, color: Colors.redAccent))
    ])));
  }

  Widget _exibirComentarios() {
    return Expanded(
        child: ListView.builder(
            controller: _controladorListaProdutos,
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _comentarios.length,
            itemBuilder: (context, index) {
              final comentario = _comentarios[index];
              String dataFormatada = DateFormat('dd/MM/yyyy HH:mm')
                  .format(DateTime.parse(comentario["createdAt"]));
              bool usuarioLogadoComentou = estadoApp.usuario != null &&
                  estadoApp.usuario!.email == comentario["authorEmail"];

              return SizedBox(
                  height: 90,
                  child: Dismissible(
                    key: Key(comentario["id"].toString()),
                    direction: usuarioLogadoComentou
                        ? DismissDirection.endToStart
                        : DismissDirection.none,
                    background: Container(
                        alignment: Alignment.centerRight,
                        child: const Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Icon(Icons.delete, color: Colors.red))),
                    child: Card(
                        color: usuarioLogadoComentou
                            ? Colors.green[100]
                            : Colors.white,
                        child: Column(children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 6, left: 6),
                              child: Container(
                                  alignment: Alignment.topLeft,
                                  child: Text(comentario["content"],
                                      style: const TextStyle(fontSize: 12)))),
                          const Spacer(),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 6.0),
                              child: Row(
                                children: [
                                  Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10.0, left: 6.0),
                                      child: Text(
                                        dataFormatada,
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(right: 10.0),
                                      child: Text(
                                        comentario["authorName"],
                                        style: const TextStyle(fontSize: 12),
                                      )),
                                ],
                              )),
                        ])),
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        setState(() {
                          _comentarios.removeAt(index);
                        });

                        showDialog(
                            context: context,
                            builder: (BuildContext contexto) {
                              return AlertDialog(
                                title: const Text(
                                    "Deseja excluir o seu comentário?",
                                    style: TextStyle(fontSize: 14)),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _comentarios.insert(
                                              index, comentario);
                                        });

                                        Navigator.of(contexto).pop();
                                      },
                                      child: const Text("NÃO",
                                          style: TextStyle(fontSize: 14))),
                                  TextButton(
                                      onPressed: () {
                                        _removerComentario(comentario["id"]);

                                        Navigator.of(contexto).pop();
                                      },
                                      child: const Text("SIM",
                                          style: TextStyle(fontSize: 14)))
                                ],
                              );
                            });
                      }
                    },
                  ));
            }));
  }

  Future<void> _atualizarComentarios() async {
    _comentarios = [];
    _ultimoComentario = 0;

    _carregarComentarios();
  }

  void _adicionarComentario() {
    _servicoComentarios
        .adicionar(estadoApp.idProduto, estadoApp.usuario!,
            _controladorNovoComentario.text)
        .then((_) {
      Toast.show("Comentário adicionado!",
          duration: Toast.lengthLong, gravity: Toast.bottom);

      _atualizarComentarios();
    });
  }

  void _removerComentario(int idComentario) {
    _servicoComentarios.remover(idComentario).then((_) {
      Toast.show("comentário removido com sucesso",
          duration: Toast.lengthLong, gravity: Toast.bottom);
    });
  }

  List<String> _imagensDoSlide() {
    List<String> imagens = ["product.png", "product.png", "product.png"];
    return imagens;
  }

  Widget _exibirProduto() {
    bool usuarioLogado = estadoApp.usuario != null;
    final slides = _imagensDoSlide();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(children: [
          Row(children: [
            Image.network(formatarCaminhoImage("company.png"),
                width: 38),
            Padding(
                padding: const EdgeInsets.only(left: 10.0, bottom: 5.0),
                child: Text(
                  _produto["company"]["name"],
                  style: const TextStyle(fontSize: 15),
                ))
          ]),
          const Spacer(),
          GestureDetector(
            onTap: () {
              estadoApp.mostrarProdutos();
            },
            child: const Icon(Icons.arrow_back, size: 30),
          )
        ]),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 230,
            child: Stack(children: [
              PageView.builder(
                itemCount: slides.length,
                controller: _controladorSlides,
                onPageChanged: (slide) {
                  setState(() {
                    _slideSelecionado = slide;
                  });
                },
                itemBuilder: (context, pagePosition) {
                  return Image.network(
                    formatarCaminhoImage(slides[pagePosition]),
                    fit: BoxFit.cover,
                  );
                },
              ),
              Align(
                  alignment: Alignment.topRight,
                  child: Column(children: [
                    IconButton(
                        onPressed: () {
                          final texto =
                              '${_produto["name"]} por R\$ ${_produto["price"].toString()} disponível no Farma App.';
                          FlutterShare.share(title: "Farma App", text: texto);
                        },
                        icon: const Icon(Icons.share),
                        color: Colors.blue,
                        iconSize: 26)
                  ]))
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: PageViewDotIndicator(
              currentItem: _slideSelecionado,
              count: 3,
              unselectedColor: Colors.black26,
              selectedColor: Colors.blue,
              duration: const Duration(milliseconds: 200),
              boxShape: BoxShape.circle,
            ),
          ),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Text(
                      _produto["name"],
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                    )),
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(_produto["description"],
                        style: const TextStyle(fontSize: 12))),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    usuarioLogado
                        ? "Ingerir ${_produto['dosage']}"
                        : "Posologia não disponível",
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(left: 8.0, bottom: 6.0),
                    child: Row(children: [
                      Text(
                        "R\$ ${_produto["price"].toString()}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12),
                      )
                    ]))
              ],
            ),
          ),
          const Center(
              child: Text(
            "Comentários",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          )),
          usuarioLogado
              ? Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: TextField(
                      controller: _controladorNovoComentario,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          enabledBorder: const OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black87, width: 0.0),
                          ),
                          border: const OutlineInputBorder(),
                          hintStyle: const TextStyle(fontSize: 14),
                          hintText: 'Faça um comentário...',
                          suffixIcon: GestureDetector(
                              onTap: () {
                                _adicionarComentario();
                              },
                              child: const Icon(Icons.send,
                                  color: Colors.black87)))))
              : const SizedBox.shrink(),
          _temComentarios
              ? _exibirComentarios()
              : _exibirMensagemComentariosInexistentes()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget detalhes = const SizedBox.shrink();

    if (_temProduto == _EstadoProduto.naoVerificado) {
      detalhes = const SizedBox.shrink();
    } else if (_temProduto == _EstadoProduto.temProduto) {
      detalhes = _exibirProduto();
    } else {
      detalhes = _exibirMensagemProdutoInexistente();
    }

    return detalhes;
  }
}
