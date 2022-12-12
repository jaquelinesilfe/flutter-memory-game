import 'package:flutter/material.dart';

class GameBox extends StatelessWidget {
  final IconData icon;
  final bool open;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  const GameBox(
      {Key? key,
      required this.icon,
      this.open = false,
      this.backgroundColor = Colors.blue,
      this.borderColor = Colors.white,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [backgroundColor.withOpacity(.6), backgroundColor],
            ),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: borderColor, width: 4.0),
            boxShadow: const [
              BoxShadow(
                  blurRadius: 5, color: Colors.black26, offset: Offset.zero)
            ]),
        height: double.infinity,
        width: double.infinity,
        child: open ? Icon(icon, color: Colors.white) : const SizedBox.shrink(),
      ),
    );
  }
}
