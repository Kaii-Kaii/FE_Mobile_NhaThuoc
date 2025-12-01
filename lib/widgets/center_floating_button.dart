import 'package:flutter/material.dart';
import 'package:quan_ly_nha_thuoc/theme/app_theme.dart';
import 'package:quan_ly_nha_thuoc/screens/chat/chat_screen.dart';

class CenterFloatingButton extends StatelessWidget {
  const CenterFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.secondaryColor, AppTheme.primaryColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryColor.withOpacity(0.5),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatScreen()),
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
