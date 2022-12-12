import 'package:flutter/material.dart';

class HintButton extends StatelessWidget {
  final VoidCallback onTap;
  final int hintCount;

  const HintButton({Key? key, required this.onTap, required this.hintCount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(4.0),
              child: Text(
                '$hintCount',
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
            )),
        IconButton(
          icon: const Icon(Icons.tungsten),
          onPressed: () => onTap(),
        ),
      ],
    );
  }
}
