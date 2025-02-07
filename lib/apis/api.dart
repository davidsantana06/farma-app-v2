import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:farma_app_v2/usuario.dart';

// const BASE_URL = "https://farma-server-temporary.onrender.com";
const BASE_URL = "http://192.168.235.44:3000";
const URL_PRODUTO = "$BASE_URL/product";
const URL_COMENTARIO = "$BASE_URL/comment";
const URL_IMAGEM = "$BASE_URL/public/img";

class ServicoProdutos {
  Future<List<dynamic>> getProdutos(int ultimoId, int tamanhoPagina) async {
    final resposta = await http
        .get(Uri.parse("$URL_PRODUTO?page=$ultimoId&limit=$tamanhoPagina"));

    final produtos = jsonDecode(resposta.body);

    return produtos;
  }

  Future<List<dynamic>> findProdutos(
      int ultimoProduto, int tamanhoPagina, String nome) async {
    final resposta = await http.get(Uri.parse(
        "$URL_PRODUTO?page=$ultimoProduto&limit=$tamanhoPagina&name=$nome"));

    final produtos = jsonDecode(resposta.body);

    return produtos;
  }

  Future<Map<String, dynamic>> findProduto(int idProduto) async {
    final resposta = await http.get(Uri.parse("$URL_PRODUTO/$idProduto"));

    final produto = jsonDecode(resposta.body);

    return produto;
  }
}

class ServicoComentarios {
  Future<List<dynamic>> getComentarios(
      int idProduto, int ultimoId, int tamanhoPagina) async {
    final uri = Uri.parse(
        "$URL_COMENTARIO?page=$ultimoId&limit=$tamanhoPagina&productId=$idProduto");

    print(uri);

    final resposta = await http.get(uri);

    print("\n\nID PRODUTO: $idProduto\n\n");

    final comentarios = jsonDecode(resposta.body);

    print("\n\nCOMENTÁRIOS: $comentarios\n\n");

    return comentarios;
  }

  Future<dynamic> adicionar(
      int idProduto, Usuario usuario, String comentario) async {
    final Map<String, dynamic> payload = {
      "productId": idProduto,
      "authorName": usuario.nome,
      "authorEmail": usuario.email,
      "content": comentario,
    };

    final resposta = await http.post(
      Uri.parse(URL_COMENTARIO),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    return resposta;
  }

  Future<dynamic> remover(int idComentario) async {
    final resposta =
        await http.delete(Uri.parse("$URL_COMENTARIO/$idComentario"));

    final comentario = jsonDecode(resposta.body);

    return comentario;
  }
}

String formatarCaminhoImage(String imagem) {
  return "$URL_IMAGEM/$imagem";
}
