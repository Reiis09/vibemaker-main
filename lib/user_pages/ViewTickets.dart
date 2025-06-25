import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vibemaker/user_pages/TicketDetails.dart';

class BilhetesCompradosPage extends StatefulWidget {
  final int userId;

  const BilhetesCompradosPage({super.key, required this.userId});

  @override
  State<BilhetesCompradosPage> createState() => _BilhetesCompradosPageState();
}

class _BilhetesCompradosPageState extends State<BilhetesCompradosPage> {
  late Future<List<Inscricao>> _futureBilhetes;

  @override
  void initState() {
    super.initState();
    _futureBilhetes = fetchBilhetes(widget.userId);
  }

  Future<List<Inscricao>> fetchBilhetes(int userId) async {
    final url = Uri.parse('http://10.0.2.2:5018/Inscricao/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);

      final allInscricoes = jsonList
          .map((json) => Inscricao.fromJson(json))
          .toList();

      final userInscricoes = allInscricoes
          .where((i) => i.idUser == userId)
          .toList();

      return userInscricoes;
    } else {
      throw Exception('Erro ao carregar bilhetes');
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Meus Bilhetes Comprados',
                    style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Inscricao>>(
                  future: _futureBilhetes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erro: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Nenhum bilhete comprado.'),
                      );
                    } else {
                      final bilhetes = snapshot.data!;
                      return ListView.builder(
                        itemCount: bilhetes.length,
                        itemBuilder: (context, index) {
                          final inscricao = bilhetes[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DetalhesBilhetePage(inscricao: inscricao),
                                ),
                              );
                            },
                            child: Card(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 6,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bilhete #${inscricao.idInscricao}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('Evento: ${inscricao.idEvento}'),
                                    Text(
                                      'Data: ${inscricao.dataInscricao.toLocal().toString().split(" ")[0]}',
                                    ),
                                    Text(
                                      'Valor pago: €${inscricao.valorPago.toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
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

class Inscricao {
  final int idInscricao;
  final int idEvento;
  final int idUser;
  final DateTime dataInscricao;
  final double valorPago;
  final String qrcode;

  Inscricao({
    required this.idInscricao,
    required this.idEvento,
    required this.idUser,
    required this.dataInscricao,
    required this.valorPago,
    required this.qrcode,
  });

  factory Inscricao.fromJson(Map<String, dynamic> json) {
    return Inscricao(
      idInscricao: json['id_inscricao'] ?? 0,
      idEvento: json['id_evento'] ?? 0,
      idUser: json['id_user'] ?? 0,
      dataInscricao: json['data_inscricao'] != null
          ? DateTime.parse(json['data_inscricao'])
          : DateTime.now(),
      valorPago: (json['valor_pago'] != null)
          ? (json['valor_pago'] as num).toDouble()
          : 0.0,
      qrcode: json['qrcode'] ?? '',
    );
  }
}
