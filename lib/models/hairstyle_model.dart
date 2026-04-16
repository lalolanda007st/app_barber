class HairstyleModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String imageUrl;
  final String overlayAsset;
  final int duration; // minutes
  final double price;
  final List<String> tags;
  final int popularity; // 1-100
  final String difficulty; // Easy, Medium, Hard
  final List<String> suitableFor; // face shapes

  const HairstyleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.imageUrl,
    required this.overlayAsset,
    required this.duration,
    required this.price,
    required this.tags,
    required this.popularity,
    required this.difficulty,
    required this.suitableFor,
  });
}

class BarberModel {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final String imageUrl;
  final bool available;
  final List<String> schedule;

  const BarberModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.imageUrl,
    required this.available,
    required this.schedule,
  });
}

// Sample data
class BarberData {
  static const List<HairstyleModel> hairstyles = [
    HairstyleModel(
      id: '1',
      name: 'Fade Clásico',
      description:
          'El fade degradado perfecto con los lados limpios y la parte superior con volumen natural. Atemporal y elegante.',
      category: 'Fade',
      imageUrl: 'assets/images/lalo.jpg',
      // imageUrl: 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?w=400',
      overlayAsset: 'fade_classic',
      duration: 30,
      price: 250.0,
      tags: ['Degradado', 'Clásico', 'Limpio'],
      popularity: 95,
      difficulty: 'Medium',
      suitableFor: ['Oval', 'Cuadrada', 'Rectangular'],
    ),
    HairstyleModel(
      id: '2',
      name: 'Skin Fade',
      description:
          'Degradado a piel extremo, ultra moderno con línea de detalle. El corte más popular entre los jóvenes.',
      category: 'Fade',
      imageUrl:
          'https://images.unsplash.com/photo-1605497788044-5a32c7078486?w=400',
      overlayAsset: 'skin_fade',
      duration: 45,
      price: 300.0,
      tags: ['Moderno', 'Afilado', 'Urbano'],
      popularity: 88,
      difficulty: 'Hard',
      suitableFor: ['Oval', 'Diamante'],
    ),
    HairstyleModel(
      id: '3',
      name: 'Undercut Moderno',
      description:
          'Lados rapados con la parte superior larga y peinada hacia atrás. Versátil y sofisticado.',
      category: 'Undercut',
      imageUrl:
          'https://images.unsplash.com/photo-1593702288056-f4a9f9f8e2b4?w=400',
      overlayAsset: 'undercut',
      duration: 40,
      price: 280.0,
      tags: ['Sofisticado', 'Versátil', 'Europeo'],
      popularity: 82,
      difficulty: 'Medium',
      suitableFor: ['Oval', 'Rectangular', 'Triangular'],
    ),
    HairstyleModel(
      id: '4',
      name: 'Pompadour',
      description:
          'El ícono del rock & roll modernizado. Volumen en la cima, lados ordenados. Presencia y carácter.',
      category: 'Pompadour',
      imageUrl:
          'https://images.unsplash.com/photo-1620331311520-246422fd82f9?w=400',
      overlayAsset: 'pompadour',
      duration: 50,
      price: 320.0,
      tags: ['Retro', 'Volumen', 'Rock'],
      popularity: 75,
      difficulty: 'Hard',
      suitableFor: ['Oval', 'Corazón', 'Cuadrada'],
    ),
    HairstyleModel(
      id: '5',
      name: 'Buzz Cut',
      description:
          'Simple, limpio y siempre elegante. El corte militar que nunca pasa de moda. Bajo mantenimiento.',
      category: 'Corto',
      imageUrl:
          'https://images.unsplash.com/photo-1517832207067-4db24a2ae47c?w=400',
      overlayAsset: 'buzz_cut',
      duration: 20,
      price: 180.0,
      tags: ['Militar', 'Simple', 'Fresco'],
      popularity: 70,
      difficulty: 'Easy',
      suitableFor: ['Oval', 'Cuadrada', 'Diamante'],
    ),
    HairstyleModel(
      id: '6',
      name: 'Texturizado con Flequillo',
      description:
          'Textura natural con movimiento y flequillo lateral. Casual pero con estilo definido.',
      category: 'Texturizado',
      imageUrl:
          'https://images.unsplash.com/photo-1578681994506-b8f463449011?w=400',
      overlayAsset: 'textured',
      duration: 35,
      price: 260.0,
      tags: ['Casual', 'Natural', 'Juvenil'],
      popularity: 85,
      difficulty: 'Easy',
      suitableFor: ['Oval', 'Redonda', 'Corazón'],
    ),
    HairstyleModel(
      id: '7',
      name: 'Man Bun',
      description:
          'El moño masculino que combina estilo y practicidad. Para cabello largo con actitud.',
      category: 'Largo',
      imageUrl:
          'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=400',
      overlayAsset: 'man_bun',
      duration: 25,
      price: 200.0,
      tags: ['Bohemio', 'Largo', 'Artístico'],
      popularity: 65,
      difficulty: 'Easy',
      suitableFor: ['Oval', 'Rectangular'],
    ),
    HairstyleModel(
      id: '8',
      name: 'Caesar Cut',
      description:
          'Corte horizontal recto al frente con textura uniforme. El look del poder discreto.',
      category: 'Clásico',
      imageUrl:
          'https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=400',
      overlayAsset: 'caesar',
      duration: 30,
      price: 240.0,
      tags: ['Clásico', 'Ejecutivo', 'Limpio'],
      popularity: 72,
      difficulty: 'Medium',
      suitableFor: ['Oval', 'Rectangular', 'Cuadrada'],
    ),
  ];

  static const List<BarberModel> barbers = [
    BarberModel(
      id: '1',
      name: 'Miguel Ángel',
      specialty: 'Fades & Diseños',
      rating: 4.9,
      reviews: 342,
      imageUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
      available: true,
      schedule: ['10:00', '10:30', '11:00', '14:00', '15:30'],
    ),
    BarberModel(
      id: '2',
      name: 'Carlos Reyes',
      specialty: 'Clásicos & Pompadour',
      rating: 4.8,
      reviews: 218,
      imageUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200',
      available: true,
      schedule: ['09:00', '11:00', '12:30', '16:00'],
    ),
    BarberModel(
      id: '3',
      name: 'Diego Torres',
      specialty: 'Undercut & Moderno',
      rating: 4.7,
      reviews: 189,
      imageUrl:
          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200',
      available: false,
      schedule: ['10:00', '13:00', '15:00', '17:00'],
    ),
  ];
}
