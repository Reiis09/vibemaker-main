import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PagamentoPage extends StatefulWidget {
  final Map<String, dynamic> evento;
  final int userId;

  const PagamentoPage({super.key, required this.evento, required this.userId});

  @override
  State<PagamentoPage> createState() => _PagamentoPageState();
}

class _PagamentoPageState extends State<PagamentoPage> {
  String? _metodoSelecionado;
  bool _isProcessing = false;

  void _confirmarCompra() async {
    if (_metodoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolhe um método de pagamento!')),
      );
      return;
    }

    int _mapearMetodoPagamento(String metodo) {
      switch (metodo) {
        case 'MBWay':
          return 1;
        case 'Multibanco':
          return 2;
        case 'Visa':
          return 3;
        case 'Saldo da Carteira':
          return 4;
        default:
          return 0;
      }
    }

    setState(() => _isProcessing = true);

    try {
      // Atualizar n_inscritos (igual)
      final eventoId = widget.evento['id_evento'];
      final novoNInscritos = (widget.evento['n_inscritos'] ?? 0) + 1;
      final eventoAtualizado = Map<String, dynamic>.from(widget.evento);
      eventoAtualizado['n_inscritos'] = novoNInscritos;

      final eventoResp = await http.put(
        Uri.parse('http://10.0.2.2:5018/evento/$eventoId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(eventoAtualizado),
      );

      if (eventoResp.statusCode != 200) {
        throw Exception('Erro ao atualizar o evento');
      }

      // Criar registo na tabela Inscricao
      final inscricao = {
        "id_evento": eventoId,
        "data_inscricao": DateTime.now().toIso8601String(),
        "id_pagamentos": _mapearMetodoPagamento(_metodoSelecionado!),
        "id_estado_inscricao": 1,
        "id_user": widget
            .userId, // <-- Corrigido aqui: mudou de "id_utilizador" para "id_user"
        "valor_pago": widget.evento['preco'],
        "qrcode": "qrcode_${DateTime.now().millisecondsSinceEpoch}",
      };

      // DEBUG: imprimir o JSON que será enviado
      print('JSON inscrição a enviar: ${jsonEncode(inscricao)}');
      print('Valor de userId: ${widget.userId}');

      final inscricaoResp = await http.post(
        Uri.parse('http://10.0.2.2:5018/Inscricao'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(inscricao),
      );

      if (inscricaoResp.statusCode != 200) {
        throw Exception('Erro ao criar a inscrição');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compra simulada com sucesso!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro na compra: $e')));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const corPrincipal = Color.fromARGB(255, 130, 39, 254);

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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Escolhe o método de pagamento',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black45,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              _metodoRadio('MBWay'),
              _metodoRadio('Multibanco'),
              _metodoRadio('Visa'),
              _metodoRadio('Saldo da Carteira'),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _confirmarCompra,
                icon: const Icon(Icons.check_circle_outline),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Text(
                          'Confirmar Compra',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: corPrincipal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metodoRadio(String metodo) {
    return ListTile(
      title: Text(metodo, style: const TextStyle(color: Colors.white)),
      leading: Radio<String>(
        value: metodo,
        groupValue: _metodoSelecionado,
        onChanged: (value) {
          setState(() => _metodoSelecionado = value);
        },
        activeColor: Colors.white,
        fillColor: MaterialStateProperty.all(Colors.white),
      ),
    );
  }
}
