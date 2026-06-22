import 'package:flutter/material.dart';

/// Paleta minimalista do Tru.co: fundo escuro, texto claro e um único acento.
class AppColors {
  AppColors._();

  static const Color dark = Color(0xFF262624);
  static const Color light = Color(0xFFF6F6F4);
  static const Color accent = Color(0xFFC6613F);

  static final Color surface = Color.alphaBlend(light.withValues(alpha: 0.04), dark);
  static final Color surfaceElevated = Color.alphaBlend(light.withValues(alpha: 0.08), dark);
  static final Color muted = light.withValues(alpha: 0.55);
}
