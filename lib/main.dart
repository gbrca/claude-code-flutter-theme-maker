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
    // Elsődleges szín alapján generálunk color scheme-et
    final baseScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    );

    // Másodlagos színt explicit beállítjuk
    final colorScheme = baseScheme.copyWith(
      secondary: _secondaryColor,
      onSecondary: _secondaryColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ColorPickerDialog(
          initialColor: currentColor,
          title: title,
          onColorSelected: onColorChanged,
        );
      },
    );
  }

  String _generateThemeCode() {
    final primaryHex = '#${primaryColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    final secondaryHex = '#${secondaryColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';

    return '''
// Generált Flutter ThemeData
final baseScheme = ColorScheme.fromSeed(
  seedColor: Color(0x${primaryColor.value.toRadixString(16).padLeft(8, '0')}),
  brightness: Brightness.${isDarkMode ? 'dark' : 'light'},
);

final colorScheme = baseScheme.copyWith(
  secondary: Color(0x${secondaryColor.value.toRadixString(16).padLeft(8, '0')}),
  onSecondary: ${secondaryColor.computeLuminance() > 0.5 ? 'Colors.black' : 'Colors.white'},
);

ThemeData(
  colorScheme: colorScheme,
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

                      // Gombok (elsődleges és másodlagos)
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
                          FilledButton.tonal(
                            onPressed: () {},
                            style: FilledButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary,
                              foregroundColor: theme.colorScheme.onSecondary,
                            ),
                            child: const Text('Másodlagos'),
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

                      // FAB (elsődleges és másodlagos)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FloatingActionButton.small(
                            onPressed: () {},
                            child: const Icon(Icons.add),
                          ),
                          FloatingActionButton(
                            onPressed: () {},
                            child: const Icon(Icons.edit),
                          ),
                          FloatingActionButton(
                            onPressed: () {},
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            child: const Icon(Icons.star),
                          ),
                          FloatingActionButton.extended(
                            onPressed: () {},
                            icon: const Icon(Icons.save),
                            label: const Text('Mentés'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Card példák (elsődleges és másodlagos)
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              elevation: 4,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.primary,
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                                title: const Text('Elsődleges'),
                                subtitle: const Text('Primary card'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Card(
                              elevation: 4,
                              color: theme.colorScheme.secondaryContainer,
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: theme.colorScheme.secondary,
                                  foregroundColor: theme.colorScheme.onSecondary,
                                  child: const Icon(Icons.star),
                                ),
                                title: Text(
                                  'Másodlagos',
                                  style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
                                ),
                                subtitle: Text(
                                  'Secondary card',
                                  style: TextStyle(color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Chip-ek (másodlagos színnel)
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
                          Chip(
                            backgroundColor: theme.colorScheme.secondary,
                            label: Text(
                              'Másodlagos szín',
                              style: TextStyle(color: theme.colorScheme.onSecondary),
                            ),
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

// Színválasztó Dialog HSL csúszkákkal
class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final String title;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.title,
    required this.onColorSelected,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _currentColor;
  int _pickerType = 0; // 0: Material, 1: HSL csúszkák, 2: HSB csúszkák

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Előnézet
              Container(
                height: 60,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _currentColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: Center(
                  child: Text(
                    '#${_currentColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}',
                    style: TextStyle(
                      color: _currentColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              // Választó típus
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(
                    value: 0,
                    label: Text('Material'),
                    icon: Icon(Icons.palette),
                  ),
                  ButtonSegment(
                    value: 1,
                    label: Text('HSL'),
                    icon: Icon(Icons.tune),
                  ),
                  ButtonSegment(
                    value: 2,
                    label: Text('HSB'),
                    icon: Icon(Icons.gradient),
                  ),
                ],
                selected: {_pickerType},
                onSelectionChanged: (Set<int> newSelection) {
                  setState(() {
                    _pickerType = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Színválasztó
              if (_pickerType == 0)
                ColorPicker(
                  pickerColor: _currentColor,
                  onColorChanged: (Color color) {
                    setState(() => _currentColor = color);
                  },
                  pickerAreaHeightPercent: 0.7,
                  displayThumbColor: true,
                  enableAlpha: false,
                )
              else if (_pickerType == 1)
                _buildHSLSliders()
              else
                _buildHSBSliders(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Mégse'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onColorSelected(_currentColor);
            Navigator.of(context).pop();
          },
          child: const Text('Kiválaszt'),
        ),
      ],
    );
  }

  Widget _buildHSLSliders() {
    final hsl = HSLColor.fromColor(_currentColor);

    return Column(
      children: [
        // Hue (Színárnyalat)
        _buildSlider(
          label: 'Színárnyalat (H)',
          value: hsl.hue,
          max: 360,
          divisions: 360,
          color: Colors.red,
          onChanged: (value) {
            setState(() {
              _currentColor = hsl.withHue(value).toColor();
            });
          },
          valueLabel: '${hsl.hue.round()}°',
        ),
        const SizedBox(height: 8),

        // Saturation (Telítettség)
        _buildSlider(
          label: 'Telítettség (S)',
          value: hsl.saturation * 100,
          max: 100,
          divisions: 100,
          color: Colors.green,
          onChanged: (value) {
            setState(() {
              _currentColor = hsl.withSaturation(value / 100).toColor();
            });
          },
          valueLabel: '${(hsl.saturation * 100).round()}%',
        ),
        const SizedBox(height: 8),

        // Lightness (Világosság)
        _buildSlider(
          label: 'Világosság (L)',
          value: hsl.lightness * 100,
          max: 100,
          divisions: 100,
          color: Colors.blue,
          onChanged: (value) {
            setState(() {
              _currentColor = hsl.withLightness(value / 100).toColor();
            });
          },
          valueLabel: '${(hsl.lightness * 100).round()}%',
        ),
      ],
    );
  }

  Widget _buildHSBSliders() {
    final hsv = HSVColor.fromColor(_currentColor);

    return Column(
      children: [
        // Hue (Színárnyalat)
        _buildSlider(
          label: 'Színárnyalat (H)',
          value: hsv.hue,
          max: 360,
          divisions: 360,
          color: Colors.red,
          onChanged: (value) {
            setState(() {
              _currentColor = hsv.withHue(value).toColor();
            });
          },
          valueLabel: '${hsv.hue.round()}°',
        ),
        const SizedBox(height: 8),

        // Saturation (Telítettség)
        _buildSlider(
          label: 'Telítettség (S)',
          value: hsv.saturation * 100,
          max: 100,
          divisions: 100,
          color: Colors.green,
          onChanged: (value) {
            setState(() {
              _currentColor = hsv.withSaturation(value / 100).toColor();
            });
          },
          valueLabel: '${(hsv.saturation * 100).round()}%',
        ),
        const SizedBox(height: 8),

        // Brightness (Fényerő)
        _buildSlider(
          label: 'Fényerő (B)',
          value: hsv.value * 100,
          max: 100,
          divisions: 100,
          color: Colors.amber,
          onChanged: (value) {
            setState(() {
              _currentColor = hsv.withValue(value / 100).toColor();
            });
          },
          valueLabel: '${(hsv.value * 100).round()}%',
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double max,
    required int divisions,
    required Color color,
    required ValueChanged<double> onChanged,
    required String valueLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(valueLabel),
          ],
        ),
        Slider(
          value: value,
          max: max,
          divisions: divisions,
          label: valueLabel,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
