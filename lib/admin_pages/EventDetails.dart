import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetalhesEventoPage extends StatefulWidget {
  final Map<String, dynamic> evento;

  const DetalhesEventoPage({super.key, required this.evento});

  @override
  State<DetalhesEventoPage> createState() => _DetalhesEventoPageState();
}

class _DetalhesEventoPageState extends State<DetalhesEventoPage> {
  late TextEditingController _nomeController;
  late TextEditingController _descricaoController;
  late TextEditingController _dataController;
  late TextEditingController _precoController;
  late TextEditingController _lotacaoController;
  bool _destaque = false;
  bool _aGuardar = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.evento['nome_evento']);
    _descricaoController = TextEditingController(
      text: widget.evento['descricao'],
    );
    _dataController = TextEditingController(
      text: widget.evento['data_hora_evento'],
    );
    _precoController = TextEditingController(
      text: widget.evento['preco'].toString(),
    );
    _lotacaoController = TextEditingController(
      text: widget.evento['cap_max'].toString(),
    );
    _destaque = widget.evento['destaque'] ?? false;
  }

  Future<void> _guardarAlteracoes() async {
    setState(() => _aGuardar = true);

    final eventoAtualizado = {
      "id_evento": widget.evento['id_evento'],
      "nome_evento": _nomeController.text.trim(),
      "descricao": _descricaoController.text.trim(),
      "preco": double.tryParse(_precoController.text.trim()) ?? 0.0,
      "data_hora_evento": _dataController.text.trim(),
      "n_inscritos": widget.evento['n_inscritos'],
      "cap_max": int.tryParse(_lotacaoController.text.trim()) ?? 0,
      "id_local": widget.evento['id_local'],
      "id_polo": widget.evento['id_polo'],
      "id_tipo_evento": widget.evento['id_tipo_evento'],
      "id_estado_evento": widget.evento['id_estado_evento'],
      "id_moeda": widget.evento['id_moeda'],
      "destaque": _destaque,
    };

    final url = Uri.parse(
      'http://10.0.2.2:5018/evento/${widget.evento['id_evento']}',
    );
    final resposta = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(eventoAtualizado),
    );

    setState(() => _aGuardar = false);

    if (resposta.statusCode == 200) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento atualizado com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao atualizar o evento')),
      );
    }
  }

  Future<void> _eliminarEvento() async {
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Evento'),
        content: const Text('Tens a certeza que queres eliminar este evento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmacao != true) return;

    final url = Uri.parse(
      'http://10.0.2.2:5018/evento/${widget.evento['id_evento']}',
    );
    final resposta = await http.delete(url);

    if (resposta.statusCode == 204) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evento eliminado com sucesso!')),
        );
        Navigator.pop(context, true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao eliminar o evento')),
      );
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
              // Botão voltar
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Detalhes do Evento',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCampo('Nome do Evento', _nomeController),
                      _buildCampo(
                        'Descrição',
                        _descricaoController,
                        maxLines: 2,
                      ),
                      _buildCampo('Data e Hora', _dataController),
                      _buildCampo('Preço (€)', _precoController),
                      _buildCampo('Lotação Máxima', _lotacaoController),
                      Row(
                        children: [
                          Checkbox(
                            value: _destaque,
                            onChanged: (val) =>
                                setState(() => _destaque = val ?? false),
                          ),
                          const Text(
                            'Evento em Destaque',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _aGuardar ? null : _guardarAlteracoes,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _aGuardar
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text('Guardar Alterações'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _eliminarEvento,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Eliminar Evento'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampo(
    String titulo,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: titulo,
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
