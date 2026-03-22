import os
import re

# Lib klasörü
lib_dir = r"c:\Users\mehmet emin yılmaz\.gemini\antigravity\scratch\gunce\lib"

# ─── Değiştirme kuralları ───────────────────────────────────────────────
# (eski_metin, yeni_metin, açıklama)
replacements = [
    # 1) Sabit koyu yazı rengi → theme'den al
    ("const Color(0xFF1A202C)",     "Theme.of(context).colorScheme.onSurface",     "yazı rengi"),
    ("Color(0xFF1A202C)",           "Theme.of(context).colorScheme.onSurface",     "yazı rengi"),
    
    # 2) Kart / input arka planı (sabit beyaz) → surface rengi
    ("color: Colors.white,",        "color: Theme.of(context).colorScheme.surface,",  "kart beyazı"),
    ("backgroundColor: Colors.white,", "backgroundColor: Theme.of(context).colorScheme.surface,", "arkaplan beyazı"),
    
    # 3) İnce çizgi / kenarlık rengi
    ("Color(0xFFE2E8F0)",           "Theme.of(context).dividerColor",              "kenarlık rengi"),
    ("Color(0xFFF4F1EA)",           "Theme.of(context).dividerColor",              "bölücü rengi"),
    
    # 4) Soluk gri yazı → yarı saydam onSurface
    ("Color(0xFF8E8E93)",           "Theme.of(context).colorScheme.onSurface.withOpacity(0.5)", "soluk gri"),
    ("Color(0xFF4A5568)",           "Theme.of(context).colorScheme.onSurface.withOpacity(0.7)", "orta gri"),
    
    # 5) Profil / settings container beyaz arka planı
    ("color: Colors.white\n",       "color: Theme.of(context).colorScheme.surface\n", "beyaz alan"),
]

# Taranmayacak dosyalar
skip_files = {"splash_screen.dart", "app_theme.dart"}

changed = 0
for root, dirs, files in os.walk(lib_dir):
    for fname in files:
        if not fname.endswith(".dart"): continue
        if fname in skip_files: continue
        path = os.path.join(root, fname)
        with open(path, "r", encoding="utf-8") as f:
            content = f.read()
        original = content
        for old, new, note in replacements:
            content = content.replace(old, new)
        if content != original:
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
            changed += 1
            print(f"✔ Güncellendi: {fname}")

print(f"\nToplam {changed} dosya güncellendi.")
