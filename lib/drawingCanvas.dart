import 'package:croquis/Models/sketch_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'Models/drawing_mode.dart';
import 'Models/sketch.dart';

class DrawingCanvas extends HookWidget {
  final double height;
  final double width;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;
  final ValueNotifier<DrawingMode> drawingMode;

  DrawingCanvas({
    Key? key,
    required this.height,
    required this.width,
    required this.currentSketch,
    required this.allSketches,
    required this.drawingMode,
  }) : super(key: key);

  Color drawingColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildAllPaths(),
        buildCurrentPath(context),
      ],
    );
  }

  Widget buildAllPaths() {
    return RepaintBoundary(
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          painter: SketchPainter(
            sketches: allSketches.value,
          ),
        ),
      ),
    );
  }

  Widget buildCurrentPath(BuildContext context) {
    return Listener(
      onPointerDown: (details) {
        final box = context.findRenderObject() as RenderBox;
        final offset = box.globalToLocal(details.position);

        currentSketch.value = Sketch(
            points: [offset],
            size: drawingMode.value == DrawingMode.eraser ? 8 : 4,
            color: drawingMode.value == DrawingMode.eraser
                ? Colors.white
                : Colors.black,
            type: () {
              switch (drawingMode.value) {
                case DrawingMode.line:
                  return SketchType.line;
                case DrawingMode.circle:
                  return SketchType.circle;
                default:
                  return SketchType.scribble;
              }
            }());
      },
      onPointerMove: (details) {
        final box = context.findRenderObject() as RenderBox;
        final offset = box.globalToLocal(details.position);
        final points = List<Offset>.from(currentSketch.value?.points ?? [])
          ..add(offset);
        currentSketch.value = Sketch(
            points: points,
            size: drawingMode.value == DrawingMode.eraser ? 8 : 4,
            color: drawingMode.value == DrawingMode.eraser
                ? Colors.white
                : Colors.black,
            type: () {
              switch (drawingMode.value) {
                case DrawingMode.line:
                  return SketchType.line;
                case DrawingMode.circle:
                  return SketchType.circle;
                default:
                  return SketchType.scribble;
              }
            }());
      },
      onPointerUp: (details) {
        allSketches.value = List<Sketch>.from(allSketches.value)
          ..add(currentSketch.value!);
      },
      child: RepaintBoundary(
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            painter: SketchPainter(
              sketches:
                  currentSketch.value == null ? [] : [currentSketch.value!],
            ),
          ),
        ),
      ),
    );
  }
}

class SketchPainter extends CustomPainter {
  final List<Sketch> sketches;

  SketchPainter({required this.sketches});

  @override
  void paint(Canvas canvas, Size size) {
    for (Sketch sketch in sketches) {
      final points = sketch.points;
      final path = Path();
      path.moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < points.length - 1; i++) {
        final p0 = points[i];
        final p1 = points[i + 1];
        path.quadraticBezierTo(
            p0.dx, p0.dy, (p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      }

      Paint paint = Paint()
        ..color = sketch.color
        ..strokeWidth = sketch.size
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      Offset firstPoint = sketch.points.first;
      Offset lastPoint = sketch.points.last;

      Rect rect = Rect.fromPoints(firstPoint,lastPoint);

      if (sketch.type == SketchType.scribble) {
        canvas.drawPath(path, paint);
      } else if (sketch.type == SketchType.line) {
        canvas.drawLine(firstPoint, lastPoint, paint);
      } else if (sketch.type == SketchType.circle) {
        canvas.drawOval(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
