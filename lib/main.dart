import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'configuracoes.dart';
import 'package:random_string/random_string.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'Simulador WebSocket';
//    final urlWS = 'ws://192.168.1.10:8080';
    final urlWS = 'ws://10.0.0.3:8080';

    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
        channel: IOWebSocketChannel.connect(urlWS),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final casoDeUso = 3;
  final mensagemAleatoria = false;

  final String title;
  final WebSocketChannel channel;

  MyHomePage({Key key, @required this.title, @required this.channel}) : super(key: key) {}

  @override
  _MyHomePageState createState() => _MyHomePageState();

}

class _MyHomePageState extends State<MyHomePage> {
  var _timer;
  var configuracoes;

  void _handleTimeout(timer) {

    var message;
    if (widget.mensagemAleatoria) {
      message = randomAlphaNumeric(configuracoes.mensagem);

    } else {
      Random random = new Random();
      int messageIndex = random.nextInt(10);
      message = configuracoes.mensagens[messageIndex];

    }

    widget.channel.sink.add(message);
  }

  void _startTimeout() {
    _timer = Timer.periodic(Duration(milliseconds: configuracoes.intervalo), _handleTimeout);
  }

  @override
  Widget build(BuildContext context) {
    configuracoes = new Configuracoes(widget.casoDeUso);
    _startTimeout();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
              stream: widget.channel.stream,
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0)
                );
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    _timer.cancel();
    super.dispose();
  }
}
