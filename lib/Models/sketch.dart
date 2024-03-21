import 'package:croquis/Models/sketch_type.dart';
import 'package:flutter/material.dart';

class Sketch {
  final List<Offset> points;
  final Color color;
  final double size;
final SketchType type;
  Sketch({
    required this.points,
    this.color = Colors.black,
    this.size = 10,
    this.type = SketchType.scribble
  });
}
