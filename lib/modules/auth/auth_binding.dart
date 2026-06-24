import 'package:get/get.dart';
import '../../core/http/api_client.dart';
import '../../services/session_service.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiClient>(() => ApiClient());

    Get.lazyPut<AuthRepository>(() => AuthRepository(Get.find<ApiClient>()));

    // SessionService أُنشئ في main()، فقط نضمن وجوده
    Get.find<SessionService>();

    Get.lazyPut<AuthController>(() => AuthController(
          Get.find<AuthRepository>(),
          Get.find<SessionService>(),
        ));
  }
}
