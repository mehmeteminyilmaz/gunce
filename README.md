<div align="center">
  <img src="https://raw.githubusercontent.com/mehmeteminyilmaz/gunce/main/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="120" alt="Günce Logo">
  <h1>Günce (Zamanın Dinginliği) 🌿</h1>
  <p><strong>Ruhunuzu dinlendiren, kişisel ve güvenli bir dijital günlük uygulaması.</strong></p>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev/)
  [![Hive](https://img.shields.io/badge/Database-Hive-orange?logo=database)](https://pub.dev/packages/hive)
</div>

<br>

**Günce**, günlük hayattaki sıradan veya özel anılarınızı not alabileceğiniz, şık ve sade tasarımıyla göz yormayan, güvenli bir Flutter uygulamasıdır. "Krem ve Adaçayı" konseptiyle tasarlanmış arayüzü sayesinde yazarken zihninizi boşaltmanıza yardımcı olur.

---

## ✨ Özellikler

- 📸 **Anılarına Görsel Kat:** İster cihazının kamerasından o anın fotoğrafını çek, ister galerinden en güzel kareyi seç.
- 🔥 **Günlük Yazma Serisi (Streak):** Motive kal! Zinciri kırmadan kaç gün üst üste günlük tuttuğunu Yan Menü ve İstatistik sayfasından takip et.
- 🔒 **Biyometrik Kilit (FaceID / TouchID):** Anıların sadece sana özel. Uygulamayı parmak izi veya yüz tanıma ile kilitleyerek meraklı gözlerden koru.
- 🎨 **Dingin Tasarım Arayüzü:** Krem (Soft Light), Adaçayı yeşili ve Pastel şeftali tonlarıyla tamamen dikkat dağıtmayan, "zen" bir yazma deneyimi.
- 📅 **Zengin İstatistikler:** Hangi modda ne kadar yazdığını, ne kadar süredir Günce kullandığını analiz et.
- 💬 **Günlük Motivasyon Sözleri:** Her girdiğinde seni farklı ve ilham verici bir söz karşılar.
- 🗄️ **Çevrimdışı & Hızlı (Hive):** İnternet gerektirmez! Anıların sadece senin cihazında (Hive lokal veritabanı) güvende tutulur.

<br>

## 🚀 Kurulum

Projeyi kendi bilgisayarınızda çalıştırmak için aşağıdaki adımları izleyebilirsiniz.

1. **Depoyu Klonlayın:**
```bash
git clone https://github.com/mehmeteminyilmaz/gunce.git
cd gunce
```

2. **Bağımlılıkları Yükleyin:**
```bash
flutter pub get
```

3. **Uygulamayı Çalıştırın:**
```bash
flutter run
```

<br>

## 🛠️ Kullanılan Teknolojiler & Paketler

Güçlü ve modern bir yapı için projede aşağıdaki araçlar kullanılmıştır:

* **[Hive](https://pub.dev/packages/hive) / [Hive_Flutter](https://pub.dev/packages/hive_flutter):** Çok hızlı lokal NoSQL veritabanı. Modeller `TypeAdapter` ile kaydedilir.
* **[Local Auth](https://pub.dev/packages/local_auth):** Biyometrik (Touch/Face) güvenlik kilidi.
* **[Image Picker](https://pub.dev/packages/image_picker):** Kamera kullanımı ve galeri resim seçimi.
* **[Google Fonts](https://pub.dev/packages/google_fonts):** Tipografi detayları (Outfit, Playfair Display).
* **[Intl](https://pub.dev/packages/intl):** Tarih/Zaman ve Türkçeleştirme (Yerelleştirme) formatları.

<br>

<div align="center">
  <i>"Günlük tutmak, kendinle yaptığın en samimi sohbettir."</i>
</div>
