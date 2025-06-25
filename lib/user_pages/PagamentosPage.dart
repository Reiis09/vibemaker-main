import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vibemaker/user_pages/ViewTickets.dart';
import 'package:vibemaker/user_pages/home_page.dart';

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
      final eventoId = widget.evento['id_evento'];
      final novoNInscritos = (widget.evento['n_inscritos'] ?? 0) + 1;
      final eventoAtualizado = Map<String, dynamic>.from(widget.evento)
        ..['n_inscritos'] = novoNInscritos;

      final eventoResp = await http.put(
        Uri.parse('http://10.0.2.2:5018/evento/$eventoId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(eventoAtualizado),
      );

      if (eventoResp.statusCode != 200) {
        throw Exception('Erro ao atualizar o evento');
      }

      final inscricao = {
        "id_evento": eventoId,
        "data_inscricao": DateTime.now().toIso8601String(),
        "id_pagamentos": _mapearMetodoPagamento(_metodoSelecionado!),
        "id_estado_inscricao": 1,
        "id_user": widget.userId,
        "valor_pago": widget.evento['preco'],
        "qrcode": "qrcode_${DateTime.now().millisecondsSinceEpoch}",
      };

      final inscricaoResp = await http.post(
        Uri.parse('http://10.0.2.2:5018/Inscricao'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(inscricao),
      );

      if (inscricaoResp.statusCode != 200) {
        throw Exception('Erro ao criar a inscrição');
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => CompraProcessamentoPage(userId: widget.userId),
          ),
        );
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Escolhe o método de pagamento',
                  textAlign: TextAlign.center,
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
                ),
                const SizedBox(height: 30),
                ...[
                  'MBWay',
                  'Multibanco',
                  'Visa',
                  'Saldo da Carteira',
                ].map((metodo) => _buildMetodoCard(metodo)).toList(),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _confirmarCompra,
                  icon: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 130, 39, 254),
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      _isProcessing ? 'A processar...' : 'Confirmar Compra',
                      style: const TextStyle(fontSize: 18),
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
      ),
    );
  }

  Widget _buildMetodoCard(String metodo) {
    final bool isSelected = _metodoSelecionado == metodo;

    return GestureDetector(
      onTap: () => setState(() => _metodoSelecionado = metodo),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white54,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: metodo,
              groupValue: _metodoSelecionado,
              onChanged: (value) => setState(() => _metodoSelecionado = value),
              activeColor: Colors.white,
              fillColor: MaterialStateProperty.all(Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              metodo,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class CompraProcessamentoPage extends StatefulWidget {
  final int userId;
  const CompraProcessamentoPage({super.key, required this.userId});

  @override
  State<CompraProcessamentoPage> createState() =>
      _CompraProcessamentoPageState();
}

class _CompraProcessamentoPageState extends State<CompraProcessamentoPage>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = true; // para controlar qual conteúdo mostrar
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        // Fase 1: processo de compra (3 segundos)
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;

        // Muda para fase 2 - mostrar sucesso com animação
        setState(() {
          _isProcessing = false;
        });

        // Iniciar animação do ícone
        _animationController.forward();

        // Esperar 2 segundos antes de navegar
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userId: widget.userId),
          ),
        );
      } catch (e, stack) {
        debugPrint('Erro na navegação: $e');
        debugPrintStack(stackTrace: stack);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
          child: Center(
            child: _isProcessing
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'A processar a tua compra...',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ],
                  )
                : ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.white,
                          size: 100,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Compra efetuada com sucesso!',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
