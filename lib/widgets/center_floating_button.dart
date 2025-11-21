import 'package:flutter/material.dart';

class CenterFloatingButton extends StatelessWidget {
  const CenterFloatingButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF03A297), Color(0xFF028A7F)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF03A297).withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.white, width: 4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Chat sẽ được cập nhật sớm.')),
            );
          },
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(Icons.chat_bubble, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
