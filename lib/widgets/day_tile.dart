import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../models/entry.dart';

class DayTile extends StatelessWidget {
  final DateTime day;
  final Entry? entry;
  final bool isToday;
  final VoidCallback onTap;

  const DayTile({
    super.key,
    required this.day,
    required this.entry,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: entry == null && isToday ? const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFFFF6584)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          color: entry == null && !isToday
            ? const Color(0xFF16213e)
            : null,
          boxShadow: isToday && entry == null ? [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ] : null,
          border: isToday && entry != null
            ? Border.all(color: const Color(0xFFFF6584), width: 2)
            : null,
          image: entry?.imagePath != null
            ? DecorationImage(
                image: kIsWeb 
                    ? NetworkImage(entry!.imagePath!) as ImageProvider 
                    : FileImage(File(entry!.imagePath!)),
                fit: BoxFit.cover,
              )
            : null,
        ),
        child: entry != null && entry!.imagePath == null
          ? Center(
              child: Text(
                '${day.day}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6584)),
              ))
          : Center(
              child: Text(
                '${day.day}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: (isToday && entry == null) || (entry?.imagePath != null) 
                    ? Colors.white 
                    : Colors.white54),
              )),
      ),
    );
  }
}