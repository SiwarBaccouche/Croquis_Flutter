import 'package:croquis/next_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Models/drawing_mode.dart';
import 'Models/sketch.dart';

class CroquisStepper extends HookWidget {
  final ValueNotifier<DrawingMode> drawingMode;
  final ValueNotifier<Sketch?> currentSketch;
  final ValueNotifier<List<Sketch>> allSketches;

  const CroquisStepper({
    Key? key,
    required this.drawingMode,
    required this.currentSketch,
    required this.allSketches,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Color(0xFF7B0945);

    final undoRedoStack = useState(
      _UndoRedoStack(
        sketchesNotifier: allSketches,
        currentSketchNotifier: currentSketch,
      ),
    );
    return Container(
      color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text(
            "  Dessinez les voix de circulation",
            style: TextStyle(
                color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
          ),
          _IconBox(
            iconData: FontAwesomeIcons.pen,
            selected: drawingMode.value == DrawingMode.pencil,
            onTap: () => drawingMode.value = DrawingMode.pencil,
            tooltip: 'Pencil',
          ),
          _IconBox(
            selected: drawingMode.value == DrawingMode.line,
            onTap: () => drawingMode.value = DrawingMode.line,
            tooltip: 'Line',
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 22,
                  height: 2,
                  color: drawingMode.value == DrawingMode.line
                      ?  Color(0xFF7B0945) : Colors.black87,
                ),
              ],
            ),
          ),
          _IconBox(
            iconData: FontAwesomeIcons.circle,
            selected: drawingMode.value == DrawingMode.circle,
            onTap: () => drawingMode.value = DrawingMode.circle,
            tooltip: 'Circle',
          ),
          _IconBox(
            iconData: FontAwesomeIcons.eraser,
            selected: drawingMode.value == DrawingMode.eraser,
            onTap: () => drawingMode.value = DrawingMode.eraser,
            tooltip: 'Eraser',
          ),
          TextButton(
            onPressed: allSketches.value.isNotEmpty
                ? () => undoRedoStack.value.undo()
                : null,
            child: const Text('Undo'),
          ),

          TextButton(
            child: const Text('Clear'),
            onPressed: () => undoRedoStack.value.clear(),
          ),


          NextButton(),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData? iconData;
  final Widget? child;
  final bool selected;
  final VoidCallback onTap;
  final String? tooltip;

  const _IconBox({
    Key? key,
    this.iconData,
    this.child,
    this.tooltip,
    required this.selected,
    required this.onTap,
  })  : assert(child != null || iconData != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected ? Color(0xFF7B0945)! : Colors.black87,
              width: 1.5,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Tooltip(
            message: tooltip,
            preferBelow: false,
            child: child ??
                Icon(
                  iconData,
                  color: selected ? Color(0xFF7B0945) : Colors.black87,
                  size: 20,
                ),
          ),
        ),
      ),
    );
  }
}



///A data structure for undoing and redoing sketches.
class _UndoRedoStack {
  _UndoRedoStack({
    required this.sketchesNotifier,
    required this.currentSketchNotifier,
  }) {
    _sketchCount = sketchesNotifier.value.length;
    sketchesNotifier.addListener(_sketchesCountListener);
  }

  final ValueNotifier<List<Sketch>> sketchesNotifier;
  final ValueNotifier<Sketch?> currentSketchNotifier;

  ///Collection of sketches that can be redone.
  late final List<Sketch> _redoStack = [];

  ///Whether redo operation is possible.
  ValueNotifier<bool> get canRedo => _canRedo;
  late final ValueNotifier<bool> _canRedo = ValueNotifier(false);

  late int _sketchCount;

  void _sketchesCountListener() {
    if (sketchesNotifier.value.length > _sketchCount) {
      //if a new sketch is drawn,
      //history is invalidated so clear redo stack
      _redoStack.clear();
      _canRedo.value = false;
      _sketchCount = sketchesNotifier.value.length;
    }
  }

  void clear() {
    _sketchCount = 0;
    sketchesNotifier.value = [];
    _canRedo.value = false;
    currentSketchNotifier.value = null;
  }

  void undo() {
    final sketches = List<Sketch>.from(sketchesNotifier.value);
    if (sketches.isNotEmpty) {
      _sketchCount--;
      _redoStack.add(sketches.removeLast());
      sketchesNotifier.value = sketches;
      _canRedo.value = true;
      currentSketchNotifier.value = null;
    }
  }

  void redo() {
    if (_redoStack.isEmpty) return;
    final sketch = _redoStack.removeLast();
    _canRedo.value = _redoStack.isNotEmpty;
    _sketchCount++;
    sketchesNotifier.value = [...sketchesNotifier.value, sketch];
  }

  void dispose() {
    sketchesNotifier.removeListener(_sketchesCountListener);
  }
}