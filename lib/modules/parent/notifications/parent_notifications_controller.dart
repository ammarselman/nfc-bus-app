import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/parent_repository.dart';
import '../../parent/parent_controller.dart';

class ParentNotificationsController extends GetxController {
  final ParentRepository repo;
  ParentNotificationsController(this.repo);

  final items = <Map<String, dynamic>>[].obs;
  final loading = false.obs;
  final loadingMore = false.obs;
  final error = RxnString();

  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  // formatter للتاريخ المحلي
  final _fmt = DateFormat('yyyy-MM-dd • hh:mm a');

  // helper: أكمل اسم الطفل إن كان null
  String? _resolveChildName(int? childId) {
    try {
      final pc = Get.find<ParentController>();
      final c = pc.children.firstWhereOrNull((e) => e['id'] == childId);
      return c?['name']?.toString();
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> _transform(Map<String, dynamic> n) {
    final childId = int.tryParse('${n['child_id'] ?? ''}') ?? 0;
    final childName =
        (n['child_name'] as String?) ?? _resolveChildName(childId);

    // صياغة الوقت للتوقيت المحلي
    final rawTime = (n['time'] ?? '').toString();
    String prettyTime = rawTime;
    try {
      final dt = DateTime.parse(rawTime).toLocal();
      prettyTime = _fmt.format(dt);
    } catch (_) {}

    // اشتقاق نوع الحدث (اختياري) من العنوان
    final title = (n['title'] ?? '').toString();
    final type = title.toLowerCase().contains('get on')
        ? 'in'
        : title.toLowerCase().contains('get out')
            ? 'out'
            : '';

    return {
      ...n,
      'child_name': childName,
      'time_pretty': prettyTime,
      'type': type, // in/out (للايقونة مثلاً)
    };
  }

  @override
  void onInit() {
    super.onInit();
    fetchFirst();
  }

  Future<void> fetchFirst() async {
    loading.value = true;
    error.value = null;
    _page = 1;
    try {
      final res = await repo.notifications(page: _page, perPage: _perPage);
      items.assignAll(res.items.map(_transform));
      _hasMore = res.hasMore;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> refreshList() => fetchFirst();

  Future<void> fetchMore() async {
    if (loadingMore.value || !_hasMore) return;
    loadingMore.value = true;
    try {
      _page += 1;
      final res = await repo.notifications(page: _page, perPage: _perPage);
      items.addAll(res.items.map(_transform));
      _hasMore = res.hasMore;
    } catch (_) {
      _page -= 1;
    } finally {
      loadingMore.value = false;
    }
  }

  bool get canLoadMore => _hasMore;
}
