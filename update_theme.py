import os

def update_theme():
    directory = r'c:\Users\mehmet emin yılmaz\.gemini\antigravity\scratch\gunce\lib'
    
    # Eski Tema -> Yeni Tema (Indigo & Lavender)
    color_map = {
        '0xFF7D9B76': '0xFF5A67D8', # Indigo (Primary)
        '0xFFA5C29F': '0xFF7F9CF5', # Light Indigo
        '0xFFFFB38E': '0xFF9F7AEA', # Lavender (Secondary)
        '0xFFFF8552': '0xFF805AD5', # Deep Lavender
        '0xFFFDFBF7': '0xFFF7FAFC', # Cool Soft Grey (Backgrounds)
        '0xFFE8E4D9': '0xFFE2E8F0', # Borders
        '0xFF2D3142': '0xFF1A202C', # Very Dark Slate (Titles)
        '0xFF4F5D75': '0xFF4A5568', # Slate (Text)
    }

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()

                original = content
                
                # Global Renk Değişimi
                for old_c, new_c in color_map.items():
                    content = content.replace(old_c, new_c)
                    
                # Açılış Ekranı Logo Değişimi
                content = content.replace(
                    'const FlutterLogo(size: 80)', 
                    'const Icon(Icons.edit_document, size: 80, color: Color(0xFF5A67D8))'
                )
                content = content.replace(
                    'FlutterLogo(size: 80)', 
                    'Icon(Icons.edit_document, size: 80, color: Color(0xFF5A67D8))'
                )
                
                if content != original:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)
                    print(f'Updated {file}')

if __name__ == "__main__":
    update_theme()
    print("Theme update complete.")
