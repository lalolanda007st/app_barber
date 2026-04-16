import 'package:flutter/material.dart';
import '../models/hairstyle_model.dart';

class BarberProvider extends ChangeNotifier {
  HairstyleModel? _selectedHairstyle;
  String _selectedCategory = 'Todos';
  String? _capturedImagePath;
  bool _isProcessing = false;
  double _overlayOpacity = 0.85;
  String _selectedFaceShape = 'Oval';
  List<String> _favorites = [];
  BarberModel? _selectedBarber;
  String? _selectedTime;

  HairstyleModel? get selectedHairstyle => _selectedHairstyle;
  String get selectedCategory => _selectedCategory;
  String? get capturedImagePath => _capturedImagePath;
  bool get isProcessing => _isProcessing;
  double get overlayOpacity => _overlayOpacity;
  String get selectedFaceShape => _selectedFaceShape;
  List<String> get favorites => _favorites;
  BarberModel? get selectedBarber => _selectedBarber;
  String? get selectedTime => _selectedTime;

  List<HairstyleModel> get filteredHairstyles {
    if (_selectedCategory == 'Todos') return BarberData.hairstyles;
    return BarberData.hairstyles
        .where((h) => h.category == _selectedCategory)
        .toList();
  }

  List<HairstyleModel> get recommendedHairstyles {
    return BarberData.hairstyles
        .where((h) => h.suitableFor.contains(_selectedFaceShape))
        .toList()
      ..sort((a, b) => b.popularity.compareTo(a.popularity));
  }

  void selectHairstyle(HairstyleModel style) {
    _selectedHairstyle = style;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCapturedImage(String path) {
    _capturedImagePath = path;
    notifyListeners();
  }

  void setProcessing(bool value) {
    _isProcessing = value;
    notifyListeners();
  }

  void setOverlayOpacity(double value) {
    _overlayOpacity = value;
    notifyListeners();
  }

  void setFaceShape(String shape) {
    _selectedFaceShape = shape;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }

  bool isFavorite(String id) => _favorites.contains(id);

  void selectBarber(BarberModel barber) {
    _selectedBarber = barber;
    notifyListeners();
  }

  void selectTime(String time) {
    _selectedTime = time;
    notifyListeners();
  }

  void clearCapturedImage() {
    _capturedImagePath = null;
    notifyListeners();
  }
}
