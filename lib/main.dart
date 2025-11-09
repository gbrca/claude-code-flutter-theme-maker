import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void main() {
  runApp(const FlutterThemeMakerApp());
}

class FlutterThemeMakerApp extends StatefulWidget {
  const FlutterThemeMakerApp({super.key});

  @override
  State<FlutterThemeMakerApp> createState() => _FlutterThemeMakerAppState();
}

class _FlutterThemeMakerAppState extends State<FlutterThemeMakerApp> {
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.orange;
  bool _isDarkMode = false;

  ThemeData _buildTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      secondary: _secondaryColor,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Theme Maker',
      theme: _buildTheme(),
      debugShowCheckedModeBanner: false,
      home: ThemeMakerScreen(
        primaryColor: _primaryColor,
        secondaryColor: _secondaryColor,
        isDarkMode: _isDarkMode,
        onPrimaryColorChanged: (color) => setState(() => _primaryColor = color),
        onSecondaryColorChanged: (color) => setState(() => _secondaryColor = color),
        onDarkModeChanged: (value) => setState(() => _isDarkMode = value),
      ),
    );
  }
}

class ThemeMakerScreen extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final bool isDarkMode;
  final ValueChanged<Color> onPrimaryColorChanged;
  final ValueChanged<Color> onSecondaryColorChanged;
  final ValueChanged<bool> onDarkModeChanged;

  const ThemeMakerScreen({
    super.key,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isDarkMode,
    required this.onPrimaryColorChanged,
    required this.onSecondaryColorChanged,
    required this.onDarkModeChanged,
  });

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
    String title,
  ) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) => pickerColor = color,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mégse'),
            ),
            ElevatedButton(
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.of(context).pop();
              },
              child: const Text('Kiválaszt'),
            ),
          ],
        );
      },
    );
  }

  String _generateThemeCode() {
    final primaryHex = '#${primaryColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    final secondaryHex = '#${secondaryColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

    return '''
// Generált Flutter ThemeData
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0x${primaryColor.value.toRadixString(16).padLeft(8, '0')}),
    secondary: Color(0x${secondaryColor.value.toRadixString(16).padLeft(8, '0')}),
    brightness: Brightness.${isDarkMode ? 'dark' : 'light'},
  ),
  useMaterial3: true,
  brightness: Brightness.${isDarkMode ? 'dark' : 'light'},
)

// Elsődleges szín: $primaryHex
// Másodlagos szín: $secondaryHex
// Téma: ${isDarkMode ? 'Sötét' : 'Világos'}
''';
  }

  void _copyThemeCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _generateThemeCode()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Téma kód vágólapra másolva!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Theme Maker'),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => onDarkModeChanged(!isDarkMode),
            tooltip: isDarkMode ? 'Világos téma' : 'Sötét téma',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Színválasztó szekció
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Színek kiválasztása',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Elsődleges szín'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _showColorPicker(
                                    context,
                                    primaryColor,
                                    onPrimaryColorChanged,
                                    'Elsődleges szín kiválasztása',
                                  ),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colorScheme.outline,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.colorize,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                const Text('Másodlagos szín'),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () => _showColorPicker(
                                    context,
                                    secondaryColor,
                                    onSecondaryColorChanged,
                                    'Másodlagos szín kiválasztása',
                                  ),
                                  child: Container(
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: secondaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colorScheme.outline,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.colorize,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Előnézet szekció
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Előnézet',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),

                      // Gombok
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Elevated gomb'),
                          ),
                          FilledButton(
                            onPressed: () {},
                            child: const Text('Filled gomb'),
                          ),
                          OutlinedButton(
                            onPressed: () {},
                            child: const Text('Outlined gomb'),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('Text gomb'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // FAB
                      Row(
                        children: [
                          FloatingActionButton.small(
                            onPressed: () {},
                            child: const Icon(Icons.add),
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton(
                            onPressed: () {},
                            child: const Icon(Icons.edit),
                          ),
                          const SizedBox(width: 8),
                          FloatingActionButton.extended(
                            onPressed: () {},
                            icon: const Icon(Icons.save),
                            label: const Text('Mentés'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Card példa
                      Card(
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          title: const Text('Card példa'),
                          subtitle: const Text('Ez egy példa card komponens'),
                          trailing: IconButton(
                            icon: const Icon(Icons.more_vert),
                            onPressed: () {},
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Chip-ek
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.star),
                            label: const Text('Chip'),
                          ),
                          ActionChip(
                            avatar: const Icon(Icons.touch_app),
                            label: const Text('Action Chip'),
                            onPressed: () {},
                          ),
                          FilterChip(
                            label: const Text('Filter Chip'),
                            selected: true,
                            onSelected: (value) {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Switch és Checkbox
                      Row(
                        children: [
                          Switch(
                            value: true,
                            onChanged: (value) {},
                          ),
                          const SizedBox(width: 16),
                          Checkbox(
                            value: true,
                            onChanged: (value) {},
                          ),
                          const SizedBox(width: 16),
                          Radio(
                            value: 1,
                            groupValue: 1,
                            onChanged: (value) {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kód generálás szekció
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Generált kód',
                            style: theme.textTheme.headlineSmall,
                          ),
                          FilledButton.icon(
                            onPressed: () => _copyThemeCode(context),
                            icon: const Icon(Icons.copy),
                            label: const Text('Másolás'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _generateThemeCode(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
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
    );
  }
}
