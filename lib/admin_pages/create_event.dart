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
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();
  final TextEditingController _lotacaoController = TextEditingController();

  bool _destaque = false;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _enviarEvento() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final evento = {
      "nome_evento": _nomeController.text.trim(),
      "descricao": _descricaoController.text.trim(),
      "preco": double.tryParse(_precoController.text.trim()) ?? 0.0,
      "data_hora_evento": _dataController.text.trim(),
      "n_inscritos": 0,
      "cap_max": int.tryParse(_lotacaoController.text.trim()) ?? 0,
      "id_local": 1,
      "id_polo": 1,
      "id_tipo_evento": 1,
      "id_estado_evento": 1,
      "id_moeda": 1,
      "destaque": _destaque,
    };

    try {
      final url = Uri.parse('http://10.0.2.2:5018/evento');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(evento),
      );

      if (response.statusCode == 200) {
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
        setState(() {
          _errorMessage =
              'Erro ao criar evento. Código: ${response.statusCode}\n${response.body}';
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
    _descricaoController.dispose();
    _dataController.dispose();
    _precoController.dispose();
    _lotacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
        onPressed: () => Navigator.pop(context),
        child: const Icon(Icons.arrow_back),
      ),
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
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    _nomeController,
                    'Nome do Evento',
                    'Nome é obrigatório',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _descricaoController,
                    'Descrição',
                    'Descrição é obrigatória',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _dataController,
                    'Data e Hora (ex: 2025-06-25T21:00:00)',
                    'Data é obrigatória',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _precoController,
                    'Preço (ex: 10.0)',
                    'Preço é obrigatório',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _lotacaoController,
                    'Lotação máxima (ex: 200)',
                    'Lotação é obrigatória',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _destaque,
                        onChanged: (value) {
                          setState(() {
                            _destaque = value ?? false;
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
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _enviarEvento,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
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
