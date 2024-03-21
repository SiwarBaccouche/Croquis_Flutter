import 'package:flutter/material.dart';
class NextButton extends StatefulWidget {
  const NextButton({Key? key}) : super(key: key);

  @override
  State<NextButton> createState() => _NextButtonState();
}

class _NextButtonState extends State<NextButton> {
  Color primaryColor = Color(0xFF7B0945);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      ),
      onPressed: () { },
      child: const Text("Next", style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),),
    );
  }
}
