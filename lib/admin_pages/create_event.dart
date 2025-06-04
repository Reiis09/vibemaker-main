import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vibemaker/admin_pages/adminhome_page.dart';

class CriarEventoPage extends StatefulWidget {
  const CriarEventoPage({super.key});

  @override
  State<CriarEventoPage> createState() => _CriarEventoPageState();
}

class _CriarEventoPageState extends State<CriarEventoPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _localController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _imagemController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _lotacaoController = TextEditingController();

  bool _destaque = false;

  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _enviarEvento() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final evento = {
      'Titulo': _nomeController.text.trim(),
      'local': _localController.text.trim(),
      'data': _dataController.text.trim(),
      'descricao': _descricaoController.text.trim(),
      'imagem': _imagemController.text.trim(),
      'destaque': _destaque,
      'preco': _precoController.text.trim(),
      'lotacao': int.tryParse(_lotacaoController.text.trim()) ?? 0,
    };

    try {
      final url = Uri.parse('http://10.0.2.2:5120/api/eventos/create');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(evento),
      );

      if (response.statusCode == 200) {
        // sucesso
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evento criado com sucesso!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminPage()),
          );
        }
      } else {
        debugPrint('Erro no servidor: ${response.statusCode}');
        debugPrint('Resposta do servidor: ${response.body}');

        setState(() {
          _errorMessage =
              'Erro ao criar evento. Código: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de conexão com o servidor.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _localController.dispose();
    _dataController.dispose();
    _descricaoController.dispose();
    _imagemController.dispose();
    _precoController.dispose();
    _lotacaoController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mantendo o fundo gradiente das outras páginas
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Criar Evento',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    _nomeController,
                    'Nome do Evento',
                    'Nome é obrigatório',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _localController,
                    'Local do Evento',
                    'Local é obrigatório',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _dataController,
                    'Data (ex: 2025-06-20)',
                    'Data é obrigatória',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _descricaoController,
                    'Descrição',
                    'Descrição é obrigatória',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _imagemController,
                    'URL da Imagem',
                    'Imagem é obrigatória',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _precoController,
                    'Preço (ex: 10€ ou 12.50)',
                    'Preço é obrigatório',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    _lotacaoController,
                    'Lotação máxima (ex: 200)',
                    'Lotação é obrigatória',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _destaque,
                        onChanged: (val) {
                          setState(() {
                            _destaque = val ?? false;
                          });
                        },
                      ),
                      const Text(
                        'Evento em Destaque',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _enviarEvento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : const Text(
                            'Criar Evento',
                            style: TextStyle(fontSize: 18),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    String validationMsg, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validationMsg;
        }
        return null;
      },
    );
  }
}
