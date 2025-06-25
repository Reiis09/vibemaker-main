import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'package:vibemaker/user_pages/EventDetails.dart';
import 'package:vibemaker/user_pages/Events.dart';
import 'package:vibemaker/user_pages/ProfilePage.dart';
import 'package:vibemaker/user_pages/ViewTickets.dart';

class HomePage extends StatefulWidget {
  final int userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      InicioPage(userId: widget.userId),
      const EventosPage(),
      BilhetesCompradosPage(userId: widget.userId),
      PerfilPage(userId: widget.userId),
      Center(
        child: Text("Eventos", style: TextStyle(color: Colors.white)),
      ),
      Center(
        child: Text("Novo Evento", style: TextStyle(color: Colors.white)),
      ),
      Center(
        child: Text("Menu", style: TextStyle(color: Colors.white)),
      ),
    ];

    return Container(
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(child: _pages[_selectedIndex]),
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: GNav(
            gap: 8,
            backgroundColor: Colors.white,
            color: Colors.black87,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.deepPurpleAccent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            tabs: const [
              GButton(icon: Icons.home, text: 'Início'),
              GButton(icon: Icons.shopping_bag, text: 'Eventos'),
              GButton(icon: Icons.add_circle_outline, text: 'Bilhetes'),
              GButton(icon: Icons.menu, text: 'Perfil'),
            ],
          ),
        ),
      ),
    );
  }
}

class InicioPage extends StatefulWidget {
  final int userId;
  const InicioPage({super.key, required this.userId});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  String? _userName;
  String? _avatarUrl;
  bool _loadingUserName = true;

  List<dynamic> _eventos = [];
  bool _loadingEventos = true;
  String? _errorEventos;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchEventos();
  }

  Future<void> _fetchUserName() async {
    try {
      final url = Uri.parse(
        'http://10.0.2.2:5018/api/utilizadores/${widget.userId}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userName = data['nome'] ?? 'Utilizador';
          _avatarUrl = data['avatar'];
          _loadingUserName = false;
        });
      } else {
        setState(() {
          _userName = 'Erro a carregar nome';
          _loadingUserName = false;
        });
      }
    } catch (_) {
      setState(() {
        _userName = 'Erro de rede';
        _loadingUserName = false;
      });
    }
  }

  Future<void> _fetchEventos() async {
    try {
      final url = Uri.parse('http://10.0.2.2:5018/evento');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        data.sort(
          (a, b) => (b['destaque'] == true ? 1 : 0).compareTo(
            a['destaque'] == true ? 1 : 0,
          ),
        );

        setState(() {
          _eventos = data;
          _loadingEventos = false;
          _errorEventos = null;
        });
      } else {
        setState(() {
          _errorEventos =
              'Erro ao carregar eventos (código: ${response.statusCode})';
          _loadingEventos = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorEventos = 'Erro de conexão ao carregar eventos.';
        _loadingEventos = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventoDestaque = _eventos.firstWhere(
      (evento) => evento['destaque'] == true,
      orElse: () => null,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com saudação e foto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OLÁ DE VOLTA,',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _loadingUserName
                        ? 'Carregando...'
                        : (_userName ?? 'Utilizador'),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundImage: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                    ? NetworkImage(_avatarUrl!)
                    : const AssetImage('assets/logos/avatar.png')
                          as ImageProvider,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Campo de pesquisa
          Text(
            'Procura o teu evento',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              hintText: 'Procurar',
              hintStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Eventos populares
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Eventos populares',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'ver tudo',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (_loadingEventos)
            const Center(child: CircularProgressIndicator(color: Colors.white))
          else if (_errorEventos != null)
            Text(
              _errorEventos!,
              style: const TextStyle(color: Colors.redAccent),
            )
          else if (eventoDestaque != null)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DetalhesEventoUserPage(evento: eventoDestaque),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      eventoDestaque['imagem'] ??
                          'https://media.discordapp.net/attachments/1387560195172991018/1387562789857656853/Noticia-IPCA-1.png?ex=685dcc0c&is=685c7a8c&hm=7ada1aaf35123356f5032d1bb5f675076205a94ac4095bc5d328eea91732a6d4&=&format=webp&quality=lossless&width=550&height=288',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Text(
                        eventoDestaque['nome_evento'] ?? 'Evento sem nome',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(
                              offset: Offset(0, 1),
                              blurRadius: 4,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/evento_banner.png'),
            ),

          const SizedBox(height: 30),

          // Para ti - Premium
          Text(
            'Para ti',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 62, 194),
                  Color.fromARGB(255, 255, 62, 194),
                  Color.fromARGB(255, 130, 39, 254),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.card_giftcard,
                        color: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Compre o Premium!',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Ao comprar o premium pela primeira vez, ganha 2 bilhetes até 10€ grátis!',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Comprar premium 4,99€/mês',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
