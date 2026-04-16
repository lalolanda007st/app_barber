import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/barber_provider.dart';
import '../models/hairstyle_model.dart';
import 'catalog_screen.dart';
import 'camera_preview_screen.dart';
import 'booking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomeContent(),
    const CatalogScreen(),
    const CameraPreviewScreen(),
    const BookingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(
          top: BorderSide(color: const Color(0xFFD4A853).withOpacity(0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'Inicio'),
              _navItem(1, Icons.grid_view_rounded, 'Cortes'),
              _navItem(2, Icons.camera_alt_rounded, 'Probar'),
              _navItem(3, Icons.calendar_month_rounded, 'Cita'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFD4A853).withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? const Color(0xFFD4A853) : const Color(0xFF555555),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 10,
                color: isActive ? const Color(0xFFD4A853) : const Color(0xFF555555),
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BarberProvider>();
    
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroSection(context),
              _buildFaceShapeSelector(context, provider),
              _buildTrendingSection(context, provider),
              _buildBarbersSection(context),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: const Color(0xFF0D0D0D),
      elevation: 0,
      expandedHeight: 0,
      pinned: true,
      title: Row(
        children: [
          const Icon(Icons.content_cut, color: Color(0xFFD4A853), size: 20),
          const SizedBox(width: 8),
          Text(
            'BarberVision',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD4A853),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFFD4A853)),
          onPressed: () {},
        ),
        const CircleAvatar(
          radius: 16,
          backgroundColor: Color(0xFF2A2A2A),
          child: Icon(Icons.person, color: Color(0xFFD4A853), size: 18),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A1F0A), Color(0xFF1A1200)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4A853).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4A853).withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tu próximo\ncorte perfecto',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF5F0E8),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Prueba el corte con tu cámara antes de sentarte en la silla',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: const Color(0xFF998877),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    // Navigate to camera tab
                    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                    homeState?.setState(() => homeState._currentIndex = 2);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A853),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.camera_alt, color: Color(0xFF0D0D0D), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Probar ahora',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0D0D0D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4A853), width: 2),
              gradient: const RadialGradient(
                colors: [Color(0xFF3A2810), Color(0xFF1A1200)],
              ),
            ),
            child: const Icon(
              Icons.face_retouching_natural,
              color: Color(0xFFD4A853),
              size: 44,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceShapeSelector(BuildContext context, BarberProvider provider) {
    final shapes = ['Oval', 'Redonda', 'Cuadrada', 'Rectangular', 'Diamante', 'Corazón', 'Triangular'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Row(
            children: [
              Text(
                'Tu forma de rostro',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF5F0E8),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A853).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD4A853).withOpacity(0.3)),
                ),
                child: Text(
                  'Para recomendaciones',
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    color: const Color(0xFFD4A853),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: shapes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final isSelected = provider.selectedFaceShape == shapes[i];
              return GestureDetector(
                onTap: () => provider.setFaceShape(shapes[i]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFD4A853) : const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD4A853)
                          : const Color(0xFF333333),
                    ),
                  ),
                  child: Text(
                    shapes[i],
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: isSelected ? const Color(0xFF0D0D0D) : const Color(0xFF999999),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingSection(BuildContext context, BarberProvider provider) {
    final hairstyles = provider.recommendedHairstyles.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recomendados para ti',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFF5F0E8),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final homeState = context.findAncestorStateOfType<_HomeScreenState>();
                  homeState?.setState(() => homeState._currentIndex = 1);
                },
                child: Text(
                  'Ver todos',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: const Color(0xFFD4A853),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: hairstyles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _HairstyleCard(hairstyle: hairstyles[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildBarbersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            'Nuestros Barberos',
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF5F0E8),
            ),
          ),
        ),
        ...BarberData.barbers.map((barber) => _BarberTile(barber: barber)).toList(),
      ],
    );
  }
}

class _HairstyleCard extends StatelessWidget {
  final HairstyleModel hairstyle;
  const _HairstyleCard({required this.hairstyle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<BarberProvider>().selectHairstyle(hairstyle);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CameraPreviewScreen(),
          ),
        );
      },
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      hairstyle.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF2A2A2A),
                        child: const Icon(Icons.person, color: Color(0xFF555555), size: 40),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A853),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up, size: 10, color: Color(0xFF0D0D0D)),
                            const SizedBox(width: 2),
                            Text(
                              '${hairstyle.popularity}%',
                              style: GoogleFonts.lato(
                                fontSize: 9,
                                color: const Color(0xFF0D0D0D),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hairstyle.name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF5F0E8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${hairstyle.price.toStringAsFixed(0)}',
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          color: const Color(0xFFD4A853),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 10, color: Color(0xFF888888)),
                          const SizedBox(width: 2),
                          Text(
                            '${hairstyle.duration}min',
                            style: GoogleFonts.lato(fontSize: 9, color: const Color(0xFF888888)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarberTile extends StatelessWidget {
  final BarberModel barber;
  const _BarberTile({required this.barber});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF2A2A2A),
                backgroundImage: NetworkImage(barber.imageUrl),
                onBackgroundImageError: (_, __) {},
                child: const Icon(Icons.person, color: Color(0xFF555555)),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: barber.available ? const Color(0xFF4CAF50) : const Color(0xFF888888),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF141414), width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barber.name,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF5F0E8),
                  ),
                ),
                Text(
                  barber.specialty,
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: const Color(0xFF998877),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Color(0xFFD4A853)),
                    const SizedBox(width: 4),
                    Text(
                      '${barber.rating} (${barber.reviews} reseñas)',
                      style: GoogleFonts.lato(fontSize: 11, color: const Color(0xFF777777)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                barber.available ? 'Disponible' : 'Ocupado',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: barber.available ? const Color(0xFF4CAF50) : const Color(0xFF888888),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: barber.available
                    ? () {
                        context.read<BarberProvider>().selectBarber(barber);
                        // Navigate to booking
                      }
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: barber.available
                        ? const Color(0xFFD4A853).withOpacity(0.15)
                        : const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: barber.available
                          ? const Color(0xFFD4A853).withOpacity(0.5)
                          : const Color(0xFF333333),
                    ),
                  ),
                  child: Text(
                    'Agendar',
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: barber.available ? const Color(0xFFD4A853) : const Color(0xFF555555),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
