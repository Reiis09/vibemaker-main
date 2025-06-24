import 'package:flutter/material.dart';
import 'package:vibemaker/engine_codes/userid.dart';
import 'package:vibemaker/user_pages/PagamentosPage.dart';

class DetalhesEventoUserPage extends StatelessWidget {
  final Map<String, dynamic> evento;

  const DetalhesEventoUserPage({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    final corPrincipal = const Color.fromARGB(255, 130, 39, 254);
    final corDestaque = const Color.fromARGB(255, 255, 209, 2);
    final int userId = UserSession().userId ?? 0;
    print('Valor de userId no DetalhesEventoUserPage: $userId');

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
              /// Top Bar com botão voltar e título
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Detalhes do Evento',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
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
                  ),
                ],
              ),
              const SizedBox(height: 30),

              /// Card Principal
              Card(
                elevation: 10,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        evento['nome_evento'] ?? 'Evento sem nome',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (evento['destaque'] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: corDestaque,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Text(
                            '🔥 Evento em Destaque',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// Descrição
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    evento['descricao'] ?? 'Sem descrição disponível.',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              /// Info rápida (data, lotação, preço)
              Row(
                children: [
                  _InfoCard(
                    icon: Icons.calendar_today,
                    label: 'Data',
                    value:
                        evento['data_hora_evento']?.toString().substring(
                          0,
                          16,
                        ) ??
                        'N/A',
                  ),
                  const SizedBox(width: 12),
                  _InfoCard(
                    icon: Icons.people,
                    label: 'Lotação',
                    value: '${evento['cap_max'] ?? 'N/A'}',
                  ),
                  const SizedBox(width: 12),
                  _InfoCard(
                    icon: Icons.euro,
                    label: 'Preço',
                    value: '€${evento['preco']?.toStringAsFixed(2) ?? '0.00'}',
                  ),
                ],
              ),

              const Spacer(),

              /// Botão Comprar
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          PagamentoPage(evento: evento, userId: userId),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Comprar Bilhete',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
