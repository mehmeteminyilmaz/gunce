import os, re

lib_dir = r"c:\Users\mehmet emin yılmaz\.gemini\antigravity\scratch\gunce\lib"

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

        # 1) "const Theme.of" → "Theme.of"  (const + runtime = hata)
        content = content.replace("const Theme.of", "Theme.of")

        # 2) "const Icon(..., color: Theme.of" → "Icon(..., color: Theme.of"
        #    Yani Icon/Divider'ın önündeki const'u kaldır
        content = re.sub(r'\bconst\s+(Icon\([^)]*Theme\.of)', r'\1', content)
        content = re.sub(r'\bconst\s+(Divider\([^)]*Theme\.of)', r'\1', content)

        if content != original:
            with open(path, "w", encoding="utf-8") as f:
                f.write(content)
            changed += 1
            print(f"✔ const çakışması düzeltildi: {fname}")

print(f"\nToplam {changed} dosya güncellendi.")
