import 'package:flutter/material.dart';

/// Generate icon based on medicine type name
class IconGenerator {
  static IconData getIconForMedicineType(String typeName) {
    final name = typeName.toLowerCase().trim();
    
    // Map Vietnamese medicine type names to appropriate icons
    if (name.contains('thuốc kháng sinh') || name.contains('kháng sinh')) {
      return Icons.biotech;
    } else if (name.contains('thuốc giảm đau') || name.contains('giảm đau')) {
      return Icons.healing;
    } else if (name.contains('thuốc ha sốt') || name.contains('ha sốt') || name.contains('hạ sốt')) {
      return Icons.thermostat;
    } else if (name.contains('thuốc kháng viêm') || name.contains('kháng viêm')) {
      return Icons.local_fire_department;
    } else if (name.contains('thuốc huyết áp') || name.contains('huyết áp')) {
      return Icons.favorite;
    } else if (name.contains('vitamin') || name.contains('dinh dưỡng')) {
      return Icons.apple;
    } else if (name.contains('dị ứng')) {
      return Icons.masks;
    } else if (name.contains('ho') || name.contains('cảm')) {
      return Icons.air;
    } else if (name.contains('tiêu hóa') || name.contains('dạ dày')) {
      return Icons.restaurant;
    } else if (name.contains('tim') || name.contains('tim mạch')) {
      return Icons.favorite_border;
    } else if (name.contains('gan')) {
      return Icons.bubble_chart;
    } else if (name.contains('thận')) {
      return Icons.water_drop;
    } else if (name.contains('xương') || name.contains('khớp')) {
      return Icons.accessibility;
    } else if (name.contains('da') || name.contains('ngoài da')) {
      return Icons.face;
    } else if (name.contains('mắt')) {
      return Icons.visibility;
    } else if (name.contains('tai')) {
      return Icons.hearing;
    } else if (name.contains('kháng nấm') || name.contains('nấm')) {
      return Icons.bug_report;
    } else if (name.contains('kháng virus') || name.contains('virus')) {
      return Icons.shield;
    } else if (name.contains('ký sinh')) {
      return Icons.pest_control;
    } else if (name.contains('hormon')) {
      return Icons.psychology;
    } else if (name.contains('kháng dị ứng')) {
      return Icons.mood;
    } else if (name.contains('an thần')) {
      return Icons.hotel;
    } else if (name.contains('trầm cảm')) {
      return Icons.sentiment_dissatisfied;
    } else if (name.contains('tiểu đường')) {
      return Icons.bloodtype;
    } else if (name.contains('cholesterol')) {
      return Icons.restaurant_menu;
    } else if (name.contains('hô hấp')) {
      return Icons.cloud;
    } else {
      // Default icon for unknown types
      return Icons.local_pharmacy;
    }
  }

  /// Get a list of predefined icon colors
  static Color getColorForMedicineType(String typeName) {
    final hashCode = typeName.hashCode;
    final colors = [
      const Color(0xFF03A297), // Teal (primary)
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF009688), // Dark teal
      const Color(0xFF26A69A), // Light teal
      const Color(0xFF4DB6AC), // Medium teal
      const Color(0xFF80CBC4), // Lighter teal
      const Color(0xFFB2DFDB), // Very light teal
    ];
    return colors[hashCode.abs() % colors.length];
  }
}
