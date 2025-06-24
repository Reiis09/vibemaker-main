import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vibemaker/admin_pages/EventDetails.dart';

class VerEventosPage extends StatefulWidget {
  const VerEventosPage({super.key});

  @override
  State<VerEventosPage> createState() => _VerEventosPageState();
}

class _VerEventosPageState extends State<VerEventosPage> {
  List<dynamic> _eventos = [];
  bool _aCarregar = true;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    _obterEventos();
  }

  Future<void> _obterEventos() async {
    try {
      final url = Uri.parse('http://10.0.2.2:5018/evento');
      final resposta = await http.get(url);

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        setState(() {
          _eventos = dados;
          _aCarregar = false;
        });
      } else {
        setState(() {
          _mensagemErro =
              'Erro ao obter eventos (Código: ${resposta.statusCode})';
          _aCarregar = false;
        });
      }
    } catch (e) {
      setState(() {
        _mensagemErro = 'Erro de ligação ao servidor.';
        _aCarregar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 209, 2),
              Color.fromARGB(255, 255, 62, 194),
              Color.fromARGB(255, 130, 39, 254),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Título + Botão Voltar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Lista de Eventos',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _aCarregar
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : _mensagemErro != null
                    ? Center(
                        child: Text(
                          _mensagemErro!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : _eventos.isEmpty
                    ? const Center(
                        child: Text(
                          'Não existem eventos registados.',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _eventos.length,
                        itemBuilder: (context, indice) {
                          final evento = _eventos[indice];
                          final bool destaque = evento['destaque'] ?? false;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetalhesEventoPage(evento: evento),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white54,
                                  width: 1.2,
                                ),
                              ),
                              child: ListTile(
                                title: Text(
                                  evento['nome_evento'] ?? 'Evento sem nome',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'Data: ${evento['data_hora_evento']}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      'Preço: ${evento['preco']} €',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    Text(
                                      destaque
                                          ? '🔸 Evento em Destaque'
                                          : 'Normal',
                                      style: TextStyle(
                                        color: destaque
                                            ? Colors.amberAccent
                                            : Colors.white60,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
