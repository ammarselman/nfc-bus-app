import 'package:busapp/modules/parent/notifications/parent_notifications_view.dart';
import 'package:get/get.dart';
import '../core/http/api_client.dart';
import '../data/repositories/parent_repository.dart';
import '../modules/auth/login_view.dart';
import '../modules/auth/auth_binding.dart';
import '../modules/driver/driver_home_view.dart';
import '../modules/driver/driver_binding.dart';
import '../modules/driver/incident/driver_incident_binding.dart';
import '../modules/driver/incident/driver_incident_view.dart';
import '../modules/driver/map/driver_map_binding.dart';
import '../modules/driver/map/driver_map_view.dart';
import '../modules/driver/scan/driver_scan_binding.dart';
import '../modules/driver/scan/driver_scan_view.dart';
import '../modules/driver/students/driver_students_binding.dart';
import '../modules/driver/students/driver_students_view.dart';
import '../modules/parent/history/parent_attendance_binding.dart';
import '../modules/parent/history/parent_attendance_view.dart';
import '../modules/parent/map/parent_map_binding.dart';
import '../modules/parent/map/parent_map_view.dart';
import '../modules/parent/notifications/parent_notifications_controller.dart';
import '../modules/parent/parent_home_view.dart';
import '../modules/parent/parent_binding.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.driverHome,
      page: () => const DriverHomeView(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: Routes.parentHome,
      page: () => const ParentHomeView(),
      binding: ParentBinding(),
    ),
    GetPage(
      name: Routes.driverScan,
      page: () => const DriverScanView(),
      binding: DriverScanBinding(),
    ),
    GetPage(
      name: Routes.driverStudents,
      page: () => const DriverStudentsView(),
      binding: DriverStudentsBinding(),
    ),
    GetPage(
      name: Routes.driverMap,
      page: () => const DriverMapView(),
      binding: DriverMapBinding(),
    ),
    GetPage(
      name: Routes.driverIncident,
      page: () => const DriverIncidentView(),
      binding: DriverIncidentBinding(),
    ),
    GetPage(
      name: Routes.parentMap,
      page: () => const ParentMapView(),
      binding: ParentMapBinding(),
    ),
    GetPage(
      name: Routes.parentAttendance,
      page: () => const ParentAttendanceView(),
      binding: ParentAttendanceBinding(),
    ),
    GetPage(
      name: Routes.parentNotifications,
      page: () => const ParentNotificationsView(),
    ),
    GetPage(
      name: Routes.parentNotifications,
      page: () => const ParentNotificationsView(),
      binding: BindingsBuilder(() {
        // تأكد أن ApiClient و ParentRepository مسجلين بـ Get.put في مكان مناسب
        final api = Get.find<ApiClient>();
        Get.put(ParentRepository(api));
        Get.put(ParentNotificationsController(Get.find<ParentRepository>()));
        Get.lazyPut(() => ParentNotificationsController(Get.find()));
      }),
    ),
  ];
}
