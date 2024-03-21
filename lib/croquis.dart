import 'package:croquis/croquis_stepper.dart';
import 'package:croquis/next_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'Models/drawing_mode.dart';
import 'Models/sketch.dart';
import 'drawingCanvas.dart';

class Croquis extends HookWidget {
  const Croquis({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Color(0xFF7B0945);
    final drawingMode = useState(DrawingMode.pencil);
    ValueNotifier<Sketch?> currentSketch = useState(null);
    ValueNotifier<List<Sketch>> allSketches = useState([]);
    //Force Landscape orientation
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: primaryColor,
          title: const Text(
            "Croquis de l'accident",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  child: DrawingCanvas(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    currentSketch: currentSketch,
                    allSketches: allSketches,
                    drawingMode: drawingMode,
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.15,
                child: CroquisStepper(
                    allSketches: allSketches,
                    currentSketch: currentSketch,
                    drawingMode: drawingMode),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
