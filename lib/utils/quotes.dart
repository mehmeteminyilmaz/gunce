import 'dart:math' as math;

class Quotes {
  static const List<String> _list = [
    "Her yeni gün, yazılmayı bekleyen bembeyaz bir sayfadır.",
    "Küçük anlar, hayatın en büyük hazineleridir.",
    "Yağmurdan sonraki toprak kokusu gibi, ruhunu taze tut.",
    "Gelecek, bugünden umut ekenlerin bahçesidir.",
    "Kendi hikayenin yazarı sensin; bırak kelimelerin özgürce aksın.",
    "En karanlık gece bile sona erer ve güneş yeniden doğar.",
    "Saklanmış bir tebessüm, günün yönünü değiştirebilir.",
    "Kendine ayırdığın her sessiz an, ruhuna bir armağandır.",
    "Bir tohumun yeşermesi sabır ister, kendi büyümeni kutla.",
    "Anılarımız, rüzgara fısıldadığımız en güzel şarkılardır.",
    "Bazen yavaşlamak, en hızlı ilerleme şeklidir.",
    "Düşüncelerin, gökyüzündeki bulutlar gibidir; gelip geçerler.",
    "İçindeki huzuru bulduğunda, dışarıdaki fırtınalar diner.",
    "Her adım, ne kadar küçük olursa olsun seni ileri taşır.",
    "Su yatağını bulur, kalbini akışa bırak.",
    "Bugün, dünün hayali; yarının ise hatırasıdır.",
    "Köklerini derinlere salan ağaçlar, en sert rüzgarlarda bile yıkılmazlar."
  ];

  static String getRandomQuote() {
    final random = math.Random();
    return _list[random.nextInt(_list.length)];
  }
}
