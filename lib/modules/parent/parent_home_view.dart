import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/notifications_api_poller.dart';
import '../../services/session_service.dart';
import 'parent_controller.dart';

class ParentHomeView extends GetView<ParentController> {
  const ParentHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Home'),
        centerTitle: false,
        scrolledUnderElevation: 2,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Get.toNamed(Routes.parentNotifications),
            icon: const Icon(Icons.notifications),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.fetch,
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            tooltip: 'Logout',
            onPressed: () async {
              await Get.find<SessionService>().clear();
              NotificationsApiPoller().stop(); // إيقافها عند مغادرة الواجهة

              Get.offAllNamed(Routes.login);
            },
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: cs.error),
                  const SizedBox(height: 12),
                  Text(
                    controller.error.value!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: controller.fetch,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetch,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              // شريط حالة آخر تحديث (مظهر أنظف)
              if (controller.lastUpdated.value != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.surfaceVariant.withOpacity(.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_sync, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Last update: ${_fmt(controller.lastUpdated.value!)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),

              // قائمة الأطفال (بطاقات M3 محسّنة)
              ...controller.children
                  .map((c) => _ChildCard(child: c, cs: cs))
                  .toList(),

              if (controller.children.isEmpty)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: cs.secondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'No children linked to this account.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _ChildCard extends StatelessWidget {
  final Map<dynamic, dynamic> child;
  final ColorScheme cs;
  const _ChildCard({required this.child, required this.cs});

  @override
  Widget build(BuildContext context) {
    final name = (child['name'] ?? 'Student').toString();
    final grade = (child['grade'] ?? '').toString();
    final onBus = (child['on_bus'] ?? false) == true;

    final lastEvent = (child['last_event'] ?? {}) as Map<dynamic, dynamic>;
    final evType = (lastEvent['type'] ?? '').toString();
    final evTime = (lastEvent['time'] ?? '').toString();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الحالة (Avatar)
            CircleAvatar(
              radius: 22,
              backgroundColor: onBus ? Colors.green : Colors.orange,
              child: Icon(
                onBus ? Icons.directions_bus_filled : Icons.person,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),

            // النصوص و Chips
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),

                  // Chips خفيفة للمعلومات
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      if (grade.isNotEmpty)
                        Chip(
                          label: Text('Grade $grade'),
                          visualDensity: VisualDensity.compact,
                        ),
                      Chip(
                        label: Text(onBus ? 'On bus' : 'Off bus'),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: (onBus ? Colors.green : Colors.orange)
                            .withOpacity(.12),
                        side: BorderSide.none,
                      ),
                      if (evType.isNotEmpty)
                        Chip(
                          label: Text('Last: ${evType.toUpperCase()}'),
                          visualDensity: VisualDensity.compact,
                        ),
                      if (evTime.isNotEmpty)
                        Chip(
                          label: Text('At: $evTime'),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // أزرار الإجراءات (هرمية واضحة)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {
                    Get.toNamed(
                      Routes.parentMap,
                      arguments: {
                        'child_id': child['id'],
                        'child_name': child['name'],
                      },
                    );
                  },
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Map'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Get.toNamed(
                      Routes.parentAttendance,
                      arguments: {
                        'child_id': child['id'],
                        'child_name': child['name'],
                      },
                    );
                  },
                  icon: const Icon(Icons.history, size: 18),
                  label: const Text('History'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
