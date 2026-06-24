import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import '../data/repositories/parent_repository.dart';
import 'notification_service.dart';
import 'package:intl/intl.dart';

/// يجلب الإشعارات دوريًا من الـ API، ويُطلق Local Notification
/// عندما يكون وقت الإشعار مطابقًا لوقت الجهاز (ضمن نافذة ±30 ثانية).
class NotificationsApiPoller {
  static final NotificationsApiPoller _i = NotificationsApiPoller._();
  NotificationsApiPoller._();
  factory NotificationsApiPoller() => _i;

  Timer? _timer;
  final _firedIds = <dynamic>{}; // نتجنّب التكرار خلال عمر الجلسة
  Duration interval = const Duration(seconds: 10);
  Duration window = const Duration(seconds: 5); // نافذة التطابق

  bool get isRunning => _timer != null;

  void start() {
    if (_timer != null) return;
    // أول فحص بعد ثانيتين، ثم دوريًا
    _timer = Timer.periodic(interval, (_) => _tick());
    Future.delayed(const Duration(seconds: 2), _tick);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _firedIds.clear();
  }

  Future<void> _tick() async {
    try {
      final repo = Get.find<ParentRepository>();
      // خذ أول صفحة تكفي للدقيقة الحالية (20 عنصر تكفي عادة)
      final res = await repo.notifications(page: 1, perPage: 250);
      final now = DateTime.now();

      for (final n in res.items) {
        final id = n['id'];
        if (_firedIds.contains(id)) continue;

        final raw = (n['time'] ?? '').toString();
        if (raw.isEmpty) continue;

        DateTime? tUtc;
        try {
          tUtc = DateTime.parse(raw);
        } catch (_) {}
        if (tUtc == null) continue;

        // حوّل لزمن الجهاز المحلي
        final tLocal = tUtc.toLocal();
        final diff = now.difference(tLocal).inSeconds.abs();

        if (diff <= window.inSeconds) {
          // أطلق إشعارًا محليًا
          final title = (n['title'] ?? 'Bus Update').toString();

          final body = (n['body'] ?? '').toString();

          print(body);
          final parts = body.split(' • ');

          final timePart = parts.first; // "07:11 AM"
          final rest = parts.length > 1 ? parts[1] : '';

          // تحليل الوقت إلى DateTime
          final time = DateFormat('hh:mm a').parse(timePart);

          // إضافة 3 ساعات
          final newTime = time.add(const Duration(hours: 3));

          // إعادة تنسيق الوقت الجديد
          final formattedTime = DateFormat('hh:mm a').format(newTime);

          // بناء النص من جديد
          final newBody = '$formattedTime • $rest';
          print(newBody); // مثلاً: "10:11 AM • BUS-001"

          await LocalNotifService().show(
            id: id is int ? id : Random().nextInt(1 << 31),
            title: title,
            body: newBody,
          );
          _firedIds.add(id);
        }
      }
    } catch (_) {
      // تجاهل الأخطاء الشبكية المؤقتة
    }
  }
}
