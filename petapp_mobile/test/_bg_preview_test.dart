import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petrimonium/core/theme/app_color_tokens.dart';
import 'package:petrimonium/core/theme/background_presets.dart';
import 'package:petrimonium/core/widgets/cosmic_background.dart';

final _darkTheme = ThemeData.dark().copyWith(extensions: [AppColorTokens.dark]);

Future<void> _capture(WidgetTester tester, String name) async {
  await tester.pump(const Duration(milliseconds: 900));
  final element = find.byKey(const Key('capture-boundary'));
  final boundary = tester.renderObject(element) as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1.5);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final dir = Directory('/tmp/claude-1000/-home-fernando-eclipse-workspace-Pet-Invest-App/0b2c1ba8-1901-4272-8104-b35dfefb052a/scratchpad/bg_preview');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  File('${dir.path}/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

Widget _sampleContent() {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('R\$ 12.480,32', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Rendimento do mês: +4,2%', style: TextStyle(color: Colors.white70, fontSize: 15)),
        ],
      ),
    ),
  );
}

Future<void> _pumpIntensity(WidgetTester tester, BackgroundIntensity intensity, String name) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: _darkTheme,
      home: Scaffold(
        body: RepaintBoundary(
          key: const Key('capture-boundary'),
          child: SizedBox(
            width: 390,
            height: 844,
            child: CosmicBackground(intensity: intensity, child: _sampleContent()),
          ),
        ),
      ),
    ),
  );
  await _capture(tester, name);
}

void main() {
  testWidgets('capture background intensities', (tester) async {
    await _pumpIntensity(tester, BackgroundIntensity.immersive, '1_immersive_home');
    await _pumpIntensity(tester, BackgroundIntensity.balanced, '2_balanced_portfolio');
    await _pumpIntensity(tester, BackgroundIntensity.subtle, '3_subtle_academy');
    await _pumpIntensity(tester, BackgroundIntensity.focus, '4_focus_lesson');
    await _pumpIntensity(tester, BackgroundIntensity.mentor, '5_mentor');
  });
}
