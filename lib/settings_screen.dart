import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'font_size_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _increment;

  @override
  void initState() {
    super.initState();
    _increment = 0;
  }

  void _increaseFontSize() {
    setState(() {
      if ((_currentBodySize() + 2) <= 36) {
        _increment += 2;
      }
    });
  }

  void _decreaseFontSize() {
    setState(() {
      if ((_currentBodySize() - 2) >= 10) {
        _increment -= 2;
      }
    });
  }

  double _currentBodySize() {
    final fontSizeProvider =
        Provider.of<FontSizeProvider>(context, listen: false);
    return fontSizeProvider.bodySize + _increment;
  }

  double _currentTitleSize() {
    final fontSizeProvider =
        Provider.of<FontSizeProvider>(context, listen: false);
    return fontSizeProvider.titleSize + _increment;
  }

  double _currentSubtitleSize() {
    final fontSizeProvider =
        Provider.of<FontSizeProvider>(context, listen: false);
    return fontSizeProvider.subtitleSize + _increment;
  }

  void _saveFontSize() {
    // Apply the increment globally
    Provider.of<FontSizeProvider>(context, listen: false)
        .updateFontSizes(_increment);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentBodySize = _currentBodySize();
    final currentTitleSize = _currentTitleSize();
    final currentSubtitleSize = _currentSubtitleSize();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Title Size: ${currentTitleSize.toStringAsFixed(0)}",
                style: TextStyle(
                      fontSize: currentTitleSize,
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                "Body Size: ${currentBodySize.toStringAsFixed(0)}",
                style: TextStyle(
                      fontSize: currentBodySize,
                    ),
              ),
              const SizedBox(height: 20),
              Text(
                "Subtitle Size: ${currentSubtitleSize.toStringAsFixed(0)}",
                style: TextStyle(
                      fontSize: currentSubtitleSize,
                    ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: currentBodySize > 10 ? _decreaseFontSize : null,
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      side: BorderSide(
                        color:
                            currentBodySize > 10 ? Colors.brown : Colors.grey,
                      ),
                    ),
                    child: Icon(
                      Icons.remove,
                      color: currentBodySize > 10 ? Colors.brown : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 100),
                  OutlinedButton(
                    onPressed: currentBodySize < 36 ? _increaseFontSize : null,
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(12),
                      side: BorderSide(
                        color:
                            currentBodySize < 36 ? Colors.brown : Colors.grey,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: currentBodySize < 36 ? Colors.brown : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              ElevatedButton.icon(
                onPressed: _saveFontSize,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                label: Text(
                  "Simpan Perubahan",
                  style: TextStyle(
                        fontSize: currentBodySize,
                        color: Colors.white,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
