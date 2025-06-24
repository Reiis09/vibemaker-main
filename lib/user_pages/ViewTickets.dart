import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
          .where((inscricao) => inscricao.idUser == userId)
          .toList();
      return userInscricoes;
    } else {
      throw Exception('Erro ao carregar bilhetes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo com gradiente igual ao Login/Register
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
              // AppBar customizada dentro do container
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Bilhetes Comprados',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: FutureBuilder<List<Inscricao>>(
                  future: _futureBilhetes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Erro: ${snapshot.error}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'Nenhum bilhete comprado.',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      );
                    } else {
                      final bilhetes = snapshot.data!;
                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        itemCount: bilhetes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final inscricao = bilhetes[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(0, 3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bilhete #${inscricao.idInscricao}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Evento: ${inscricao.idEvento}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Data: ${_formatDate(inscricao.dataInscricao)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Valor Pago: €${inscricao.valorPago.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'QR Code: ${inscricao.qrcode}',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 209, 2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
