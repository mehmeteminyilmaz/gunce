import '../models/entry.dart';

class StreakCalculator {
  static int calculate(List<Entry> entries) {
    if (entries.isEmpty) return 0;

    // Saatleri yok sayıp sadece günleri baz alarak listeyi benzersiz hale ve sıralı hale getirelim
    final uniqueDates = entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList();
    uniqueDates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    DateTime checkDate;
    // Eğer bugün kayıt varsa seriye bugünden başla. Değilse dünden başla (çünkü gün bitmemiş olabilir).
    if (uniqueDates.contains(today)) {
      checkDate = today;
    } else if (uniqueDates.contains(today.subtract(const Duration(days: 1)))) {
      checkDate = today.subtract(const Duration(days: 1));
    } else {
      return 0; // Ne bugün ne de dün bir kayıt var, seri kopmuş.
    }

    // Geriye doğru giderek seriyi say
    while (uniqueDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }
}
