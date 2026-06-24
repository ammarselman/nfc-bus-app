import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NfcService {
  bool _sessionRunning = false;

  /// هل NFC متوفّر على الجهاز ومفعّل؟
  Future<bool> isAvailable() async {
    final availability = await FlutterNfcKit.nfcAvailability;
    return availability == NFCAvailability.available;
  }

  /// يبدأ جلسة NFC ويعيد أول UID يلتقطه (hex uppercase)
  /// يرجع null في الحالات:
  /// - NFC غير متوفر
  /// - لم يتم التقاط أي بطاقة
  /// - حدث خطأ أثناء القراءة
  Future<String?> readUidOnce() async {
    if (_sessionRunning) return null;
    _sessionRunning = true;

    try {
      final available = await isAvailable();
      if (!available) {
        _sessionRunning = false;
        return null;
      }

      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 10),
        androidCheckNDEF: false,
        iosMultipleTagMessage: 'رجاءً استخدم بطاقة واحدة فقط',
        iosAlertMessage: 'قرب الإسوارة من الجزء العلوي للجوال',
      );

      final uidHex = tag.id?.toUpperCase();

      await FlutterNfcKit.finish();
      _sessionRunning = false;

      return uidHex;
    } catch (e) {
      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
      _sessionRunning = false;
      return null;
    }
  }
}
