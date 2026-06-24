import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/session_service.dart';
import 'driver_controller.dart';

class DriverHomeView extends GetView<DriverController> {
  const DriverHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Driver Home'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              await Get.find<SessionService>().clear();
              Get.offAllNamed(Routes.login);
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.refreshDashboard,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // بطاقة العدّاد + حالة الرحلة + آخر تحديث
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.directions_bus_filled, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Onboard Students',
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            '${controller.onboardCount}',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Last update: ${_fmt(controller.lastUpdated.value)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Chip(
                      label: Obx(() => Text(controller.tripActive.value
                          ? 'Trip Active'
                          : 'No Trip')),
                      avatar: Obx(() => Icon(
                            controller.tripActive.value
                                ? Icons.play_circle_fill
                                : Icons.pause_circle_filled,
                            size: 18,
                          )),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Text('Quick Actions',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              GridView(
                shrinkWrap: true,
                primary: false,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                children: [
                  // Scan مع شارة Pending
                  Obx(() => _QuickTile(
                        title: 'Scan NFC',
                        icon: Icons.nfc,
                        badge: controller.pendingCount.value > 0
                            ? controller.pendingCount.value
                            : null,
                        onTap: () => Get.toNamed(Routes.driverScan),
                      )),
                  _QuickTile(
                    title: 'Student List',
                    icon: Icons.people_alt_outlined,
                    onTap: () => Get.toNamed(Routes.driverStudents),
                  ),
                  _QuickTile(
                    title: 'Live Map',
                    icon: Icons.map_outlined,
                    onTap: () => Get.toNamed(Routes.driverMap),
                  ),

                  _QuickTile(
                    title: 'Incident',
                    icon: Icons.report_gmailerrorred_outlined,
                    onTap: () => Get.toNamed(Routes.driverIncident),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  String _fmt(DateTime? dt) {
    if (dt == null) return '-';
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _QuickTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final int? badge;
  const _QuickTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tile = Material(
      color: cs.surfaceVariant.withOpacity(.5),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 34),
              const SizedBox(height: 10),
              Text(title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                  maxLines: 2),
            ],
          ),
        ),
      ),
    );

    if (badge == null) return tile;

    // شارة صغيرة في أعلى يمين البلاطة
    return Stack(
      clipBehavior: Clip.none,
      children: [
        tile,
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: cs.error,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$badge',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
