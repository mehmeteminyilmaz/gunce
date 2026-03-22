import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/entry.dart';

class DetailScreen extends StatelessWidget {
  final Entry entry;
  const DetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMMM yyyy', 'tr').format(entry.date);

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7), // Krem zemin
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: const Color(0xFFFDFBF7),
            elevation: 0,
            expandedHeight: entry.imagePath != null ? 400.0 : 100.0,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                    ]
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF2D3142), size: 16),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: entry.imagePath != null
                ? Image.file(
                    File(entry.imagePath!),
                    fit: BoxFit.cover,
                  )
                : const SizedBox(),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Color(0xFFFDFBF7), // Krem zemin üstüne
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateStr,
                        style: GoogleFonts.outfit(
                          fontSize: 14, letterSpacing: 2, color: const Color(0xFF8E8E93))),
                      if (entry.mood != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE8E4D9)),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Text(entry.mood!.toUpperCase(),
                            style: GoogleFonts.outfit(fontSize: 10, letterSpacing: 1, color: const Color(0xFF7D9B76), fontWeight: FontWeight.w600)),
                        )
                    ],
                  ),
                  
                  if (entry.locationName != null && entry.locationName!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Color(0xFFFFB38E), size: 16),
                        const SizedBox(width: 8),
                        Text(entry.locationName!,
                          style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF8E8E93), fontWeight: FontWeight.w400)),
                      ],
                    ),
                  ],
                  
                  const SizedBox(height: 48),
                  
                  Text('"${entry.text}"',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      color: const Color(0xFF2D3142),
                      fontWeight: FontWeight.w500,
                      height: 1.8,
                    )),
                    
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}