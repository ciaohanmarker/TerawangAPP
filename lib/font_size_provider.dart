import 'package:flutter/material.dart';

class FontSizeProvider extends ChangeNotifier {
  // Default font sizes
  double _titleSize = 24.0;
  double _subtitleSize = 14.0;
  double _bodySize = 16.0;

  // Getters
  double get titleSize => _titleSize;
  double get subtitleSize => _subtitleSize;
  double get bodySize => _bodySize;

  // Method to update font sizes uniformly
  void updateFontSizes(double increment) {
    _titleSize += increment;
    _subtitleSize += increment;
    _bodySize += increment;
    notifyListeners();
  }
}
