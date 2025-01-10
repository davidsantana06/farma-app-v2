import 'package:flutter/material.dart';

import 'package:farma_app_v2/estado.dart';
import 'package:farma_app_v2/apis/api.dart';

class ProdutoCard extends StatelessWidget {
  final dynamic produto;

  const ProdutoCard({super.key, required this.produto});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        estadoApp.mostrarDetalhes(produto["id"]);
      },
      child: Card(
        child: Column(children: [
          Image.network(formatarCaminhoImage("product.png")),
          Row(children: [
            CircleAvatar(
                backgroundColor: Colors.transparent,
                child: Image.network(formatarCaminhoImage("company.png"))),
            Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(produto["company"]["name"],
                    style: const TextStyle(fontSize: 15))),
          ]),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Text(produto["name"],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
          Padding(
              padding: const EdgeInsets.only(left: 10, top: 5, bottom: 10),
              child: Text(produto["description"])),
          const Spacer(),
          Row(children: [
            Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 5),
                child: Text("R\$ ${produto['price'].toString()}"))
          ])
        ]),
      ),
    );
  }
}
