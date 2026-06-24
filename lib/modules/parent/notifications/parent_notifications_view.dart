import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'parent_notifications_controller.dart';

class ParentNotificationsView extends StatelessWidget {
  const ParentNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ParentNotificationsController>();
    final scroll = ScrollController();

    // تحميل المزيد عند نهاية القائمة
    scroll.addListener(() {
      if (scroll.position.pixels >= scroll.position.maxScrollExtent - 120) {
        c.fetchMore();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Obx(() {
        if (c.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.error.value != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 40),
                  const SizedBox(height: 8),
                  Text(c.error.value!, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: c.fetchFirst,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (c.items.isEmpty) {
          return const Center(child: Text('No notifications'));
        }

        return RefreshIndicator(
          onRefresh: c.refreshList,
          child: ListView.separated(
              controller: scroll,
              padding: const EdgeInsets.all(12),
              itemCount: c.items.length + (c.canLoadMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                if (i >= c.items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final n = c.items[i];
                final title = (n['title'] ?? '').toString();
                final body = (n['body'] ?? '').toString();
                final time = (n['time_pretty'] ?? n['time'] ?? '').toString();
                final child = (n['child_name'] ?? '').toString();
                final type = (n['type'] ?? '').toString();

                IconData leading;
                if (type == 'in') {
                  leading = Icons.login; // صعود
                } else if (type == 'out') {
                  leading = Icons.logout; // نزول
                } else {
                  leading = Icons.notifications;
                }

                final subtitleLines = [
                  if (child.isNotEmpty) 'Student: $child',
                  if (body.isNotEmpty) body,
                  if (time.isNotEmpty) time,
                ];

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: Icon(leading),
                    title: Text(title),
                    subtitle: Text(subtitleLines.join('\n')),
                    isThreeLine: true,
                  ),
                );
              }),
        );
      }),
    );
  }
}
