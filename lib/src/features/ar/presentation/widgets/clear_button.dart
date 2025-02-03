import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class ClearButton extends StatefulWidget {
  Function deleteAllPoints;
  ClearButton({super.key, required this.deleteAllPoints});

  @override
  State<ClearButton> createState() => _ClearButtonState();
}

class _ClearButtonState extends State<ClearButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          widget.deleteAllPoints();
        },
        child: Align(
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white60, borderRadius: BorderRadius.circular(20)),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Clear All Nodes",
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
