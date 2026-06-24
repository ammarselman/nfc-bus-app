/// جميع المسارات (Endpoints) في مكان واحد لتسهيل الإدارة
class ApiPath {
  // Auth
  static const String login = 'auth/login';
  static const String signup = 'auth/register';

  // Driver
  static const String driverAttendanceScan = 'driver/attendance/scan';
  static const String driverOnboard = 'driver/onboard';
  static const String driverTripCurrent = 'driver/trip/current';
  static const String driverLocation = 'driver/location';
  static const String driverIncident = 'driver/incident';
  // Parent
  static const String parentChild =
      'parent/child'; // تفاصيل الطفل/الأطفال + الحالة الحالية
  static const String parentBusLocation = 'parent/location';
  static const String parentAttendance = 'parent/attendance';
  static const String parentNotifications =
      'parent/notifications'; // GET ?since=lastId
  static const String wsParentStream = 'ws://192.168.1.103:8080/parent/stream';
}
