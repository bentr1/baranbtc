import 'package:flutter/material.dart';

/// Helper extensions for Color to avoid deprecated APIs like [withOpacity].
///
/// Use [withOpacityDouble] to produce the same visual effect as
/// `color.withOpacity(opacity)` but implemented via [withAlpha] which
/// avoids analyzer deprecation warnings in some SDK versions.
extension ColorUtils on Color {
  /// Returns a copy of this color with the given opacity (0.0 - 1.0).
  Color withOpacityDouble(double opacity) {
    final clamped = opacity.clamp(0.0, 1.0);
    return withAlpha((clamped * 255).round());
  }
}
