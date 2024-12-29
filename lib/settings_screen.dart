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
      _increment += 2;
    });
  }

  void _decreaseFontSize() {
    setState(() {
      _increment -= 2;
    });
  }

  void _saveFontSize() {
    // Apply the increment globally
    Provider.of<FontSizeProvider>(context, listen: false)
        .updateFontSizes(_increment);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengaturan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Title Size: ${(fontSizeProvider.titleSize + _increment).toStringAsFixed(0)}",
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 20),
            Text(
              "Body Size: ${(fontSizeProvider.bodySize + _increment).toStringAsFixed(0)}",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Text(
              "Subtitle Size: ${(fontSizeProvider.subtitleSize + _increment).toStringAsFixed(0)}",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _decreaseFontSize,
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    side: const BorderSide(color: Colors.brown),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(width: 100),
                OutlinedButton(
                  onPressed: _increaseFontSize,
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                    side: const BorderSide(color: Colors.brown),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.brown,
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
