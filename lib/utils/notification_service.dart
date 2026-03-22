// Bildirim paketleri Türkçe karakterli dosya yolu nedeniyle Android'de derlenemiyor.
// Bu servis şimdilik stub olarak bırakıldı. Paket ekleme, farklı bir proje dizininde yapılmalıdır.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> init() async {
    // Bildirim desteği geçici olarak devre dışı
  }

  Future<void> scheduleDailyReminder(
      int id, String title, String body, int hour, int minute) async {
    // Bildirim desteği geçici olarak devre dışı
  }

  Future<void> cancelReminder(int id) async {
    // Bildirim desteği geçici olarak devre dışı
  }
}
