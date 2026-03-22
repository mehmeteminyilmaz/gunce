import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Box _profileBox = Hive.box('profile');
  late TextEditingController _nameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _profileBox.get('name', defaultValue: 'Gezgin'));
  }

  Future<void> _saveName() async {
    await _profileBox.put('name', _nameController.text.trim());
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: Text('Profilim', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20, offset: const Offset(0, 10),
                        )
                      ]
                    ),
                    child: const Icon(Icons.person_rounded, size: 60, color: Color(0xFFE0E0E0)),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5A67D8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            _isEditing
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        style: GoogleFonts.outfit(fontSize: 24, color: const Color(0xFF1A202C)),
                        decoration: InputDecoration(
                          hintText: 'Adınız',
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF5A67D8))),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF5A67D8), size: 32),
                      onPressed: _saveName,
                    )
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_nameController.text,
                      style: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w600, color: const Color(0xFF1A202C))),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _isEditing = true),
                      child: const Icon(Icons.edit_rounded, color: Color(0xFF9E9E9E), size: 20),
                    )
                  ],
                ),
            
            const SizedBox(height: 8),
            Text('Günce ile yeni anılar biriktiriyor',
              style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF8E8E93))),
              
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))
                ],
                border: Border.all(color: const Color(0xFFF4F1EA)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Katılım Tarihi', style: GoogleFonts.outfit(color: const Color(0xFF8E8E93))),
                      Text('Bugün', style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: const Color(0xFF1A202C))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
