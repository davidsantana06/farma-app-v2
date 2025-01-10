import 'package:farma_app_v2/estado.dart';
import 'package:farma_app_v2/telas/detalhes.dart';
import 'package:farma_app_v2/telas/produtos.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => Estado(),
        child: MaterialApp(
          title: 'Farma App',
          theme: ThemeData(
              colorScheme: const ColorScheme.light(),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(backgroundColor: Colors.white),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.blueGrey)),
          home: const TelaPrincipal(title: 'Farma App'),
        ));
  }
}

class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key, required this.title});

  final String title;

  @override
  State<TelaPrincipal> createState() => _EstadoTelaPrincipal();
}

class _EstadoTelaPrincipal extends State<TelaPrincipal> {
  @override
  Widget build(BuildContext context) {
    estadoApp = context.watch<Estado>();

    final media = MediaQuery.of(context);
    estadoApp.setDimensoes(media.size.height, media.size.width);

    Widget tela = const SizedBox.shrink();
    if (estadoApp.mostrandoProdutos()) {
      tela = const Produtos();
    } else if (estadoApp.mostrandoDetalhes()) {
      tela = const Detalhes();
    }

    return tela;
  }
}
