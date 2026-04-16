import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/barber_provider.dart';
import '../models/hairstyle_model.dart';
import 'camera_preview_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  static const categories = [
    'Todos',
    'Fade',
    'Undercut',
    'Pompadour',
    'Corto',
    'Texturizado',
    'Largo',
    'Clásico'
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BarberProvider>();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: const Color(0xFF0D0D0D),
          pinned: true,
          title: Text(
            'Catálogo de Cortes',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFF5F0E8),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search_rounded, color: Color(0xFFD4A853)),
              onPressed: () {},
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: _buildCategoryFilter(context, provider),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final hairstyle = provider.filteredHairstyles[index];
                return _HairstyleGridCard(hairstyle: hairstyle);
              },
              childCount: provider.filteredHairstyles.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildCategoryFilter(BuildContext context, BarberProvider provider) {
    return Container(
      height: 50,
      color: const Color(0xFF0D0D0D),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isSelected = provider.selectedCategory == categories[i];
          return GestureDetector(
            onTap: () => provider.setCategory(categories[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD4A853)
                    : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFD4A853)
                      : const Color(0xFF333333),
                ),
              ),
              child: Text(
                categories[i],
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: isSelected
                      ? const Color(0xFF0D0D0D)
                      : const Color(0xFF999999),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HairstyleGridCard extends StatelessWidget {
  final HairstyleModel hairstyle;
  const _HairstyleGridCard({required this.hairstyle});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BarberProvider>();
    final isFav = context.watch<BarberProvider>().isFavorite(hairstyle.id);

    return GestureDetector(
      onTap: () {
        provider.selectHairstyle(hairstyle);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CameraPreviewScreen()),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF1A1A1A),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      hairstyle.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: const Color(0xFF2A2A2A),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFD4A853),
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF2A2A2A),
                        child: const Icon(Icons.person,
                            color: Color(0xFF555555), size: 50),
                      ),
                    ),
                    // Gradient overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Color(0xFF1A1A1A), Colors.transparent],
                          ),
                        ),
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => provider.toggleFavorite(hairstyle.id),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isFav ? Colors.red : Colors.white,
                          ),
                        ),
                      ),
                    ),
                    // Difficulty badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _difficultyColor(hairstyle.difficulty)
                              .withOpacity(0.85),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          hairstyle.difficulty,
                          style: GoogleFonts.lato(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Try it button at bottom
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A853),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt,
                                size: 10, color: Color(0xFF0D0D0D)),
                            const SizedBox(width: 4),
                            Text(
                              'Probar',
                              style: GoogleFonts.lato(
                                fontSize: 10,
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
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Text(
                      hairstyle.description,
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        color: const Color(0xFF777777),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${hairstyle.price.toStringAsFixed(0)}',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: const Color(0xFFD4A853),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 11, color: Color(0xFF777777)),
                            const SizedBox(width: 3),
                            Text(
                              '${hairstyle.duration}m',
                              style: GoogleFonts.lato(
                                  fontSize: 10, color: const Color(0xFF777777)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 4,
                      children: hairstyle.tags
                          .take(2)
                          .map((tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF252525),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tag,
                                  style: GoogleFonts.lato(
                                    fontSize: 9,
                                    color: const Color(0xFF888888),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return const Color(0xFF4CAF50);
      case 'Medium':
        return const Color(0xFFFF9800);
      case 'Hard':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF888888);
    }
  }
}
