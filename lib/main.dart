import 'package:busapp/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await LocalNotifService().init(); // لإظهار Local notifications
  await Get.putAsync<SessionService>(() => SessionService().init());

  runApp(const NFCBusApp());
}

class NFCBusApp extends StatelessWidget {
  const NFCBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NFC Bus',
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.login,
      getPages: AppPages.pages,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
    );
  }
}
