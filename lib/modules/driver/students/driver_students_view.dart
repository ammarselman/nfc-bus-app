import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'driver_students_controller.dart';

class DriverStudentsView extends GetView<DriverStudentsController> {
  const DriverStudentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Onboard (${controller.items.length})')),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.fetch,
            icon: const Icon(Icons.refresh),
          ),
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
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 12),
                  Text(controller.error.value!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
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
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(12),
            itemCount: controller.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final s = controller.items[i];
              final name = (s['name'] ?? 'Student').toString();
              final grade = (s['grade'] ?? '').toString();
              final boardedAt = (s['boarded_at'] ?? '').toString();

              return Material(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(.45),
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(name),
                  subtitle: Text(
                    [
                      if (grade.isNotEmpty) 'Grade: $grade',
                      if (boardedAt.isNotEmpty) 'Boarded: $boardedAt',
                    ].join(' • '),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
