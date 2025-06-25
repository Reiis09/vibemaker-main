import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vibemaker/engine_codes/userid.dart';

class PerfilPage extends StatefulWidget {
  final int userId;

  const PerfilPage({super.key, required this.userId});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  String nome = '';
  String email = '';
  String password = '';
  String? avatarUrl;
  bool isLoading = true;

  bool isEditingNome = false;
  bool isEditingEmail = false;
  bool isEditingPassword = false;

  late TextEditingController nomeController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    final userId = UserSession().userId;

    if (userId == null) {
      setState(() {
        nome = 'Erro';
        email = 'Utilizador não autenticado.';
        password = '';
        avatarUrl = null;
        isLoading = false;
      });
      return;
    }

    try {
      final url = Uri.parse('http://10.0.2.2:5018/api/utilizadores/$userId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          nome = data['nome'] ?? '';
          email = data['email'] ?? '';
          password = '********';
          avatarUrl = data['avatar'] ?? null;
          nomeController = TextEditingController(text: nome);
          emailController = TextEditingController(text: email);
          passwordController = TextEditingController();
          isLoading = false;
        });
      } else {
        setState(() {
          nome = 'Erro';
          email = 'Falha ao buscar dados.';
          password = '';
          avatarUrl = null;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        nome = 'Erro';
        email = 'Erro de rede.';
        password = '';
        avatarUrl = null;
        isLoading = false;
      });
    }
  }

  Future<bool> updateUserField(
    BuildContext context,
    String field,
    String value,
  ) async {
    final userId = UserSession().userId;
    if (userId == null) return false;

    try {
      final url = Uri.parse('http://10.0.2.2:5018/api/utilizadores/$userId');
      final body = jsonEncode({field: value});
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$field atualizado com sucesso!')),
        );
        return true;
      } else {
        if (!mounted) return false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao atualizar $field.')));
        return false;
      }
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de rede ao atualizar $field.')),
      );
      return false;
    }
  }

  Future<void> _showEditAvatarDialog() async {
    final controller = TextEditingController(text: avatarUrl ?? '');

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Alterar URL da Foto de Perfil'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Insira a URL da nova foto",
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newUrl = controller.text.trim();
                if (newUrl.isEmpty) return;
                final success = await updateUserField(
                  context,
                  'avatar',
                  newUrl,
                );
                if (success) {
                  setState(() {
                    avatarUrl = newUrl;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Widget buildEditableField({
    required String title,
    required String value,
    required bool isEditing,
    required TextEditingController controller,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required Future<void> Function() onSave,
    bool obscureText = false,
  }) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        subtitle: isEditing
            ? TextField(
                controller: controller,
                autofocus: true,
                obscureText: obscureText,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: UnderlineInputBorder(),
                ),
                onSubmitted: (_) => onSave(),
              )
            : GestureDetector(
                onTap: onEdit,
                child: Text(value, style: const TextStyle(fontSize: 16)),
              ),
        trailing: isEditing
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: onSave,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: onCancel,
                  ),
                ],
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider avatarImage;

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(avatarUrl!);
    } else {
      avatarImage = const AssetImage('assets/logos/avatar.jpg');
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  GestureDetector(
                    onTap: _showEditAvatarDialog,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: avatarImage,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: CircleAvatar(
                          backgroundColor: Colors.white70,
                          radius: 15,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),
                  buildEditableField(
                    title: 'Nome',
                    value: nome,
                    isEditing: isEditingNome,
                    controller: nomeController,
                    onEdit: () {
                      setState(() {
                        isEditingNome = true;
                        nomeController.text = nome;
                      });
                    },
                    onCancel: () {
                      setState(() {
                        isEditingNome = false;
                      });
                    },
                    onSave: () async {
                      final newNome = nomeController.text.trim();
                      if (newNome.isEmpty) return;
                      final success = await updateUserField(
                        context,
                        'nome',
                        newNome,
                      );
                      if (success) {
                        setState(() {
                          nome = newNome;
                          isEditingNome = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  buildEditableField(
                    title: 'Email',
                    value: email,
                    isEditing: isEditingEmail,
                    controller: emailController,
                    onEdit: () {
                      setState(() {
                        isEditingEmail = true;
                        emailController.text = email;
                      });
                    },
                    onCancel: () {
                      setState(() {
                        isEditingEmail = false;
                      });
                    },
                    onSave: () async {
                      final newEmail = emailController.text.trim();
                      if (newEmail.isEmpty) return;
                      final success = await updateUserField(
                        context,
                        'email',
                        newEmail,
                      );
                      if (success) {
                        setState(() {
                          email = newEmail;
                          isEditingEmail = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  buildEditableField(
                    title: 'Password',
                    value: '********',
                    isEditing: isEditingPassword,
                    controller: passwordController,
                    obscureText: true,
                    onEdit: () {
                      setState(() {
                        isEditingPassword = true;
                        passwordController.clear();
                      });
                    },
                    onCancel: () {
                      setState(() {
                        isEditingPassword = false;
                        passwordController.clear();
                      });
                    },
                    onSave: () async {
                      final newPassword = passwordController.text.trim();
                      if (newPassword.isEmpty) return;
                      final success = await updateUserField(
                        context,
                        'password',
                        newPassword,
                      );
                      if (success) {
                        setState(() {
                          password = '********';
                          isEditingPassword = false;
                          passwordController.clear();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
