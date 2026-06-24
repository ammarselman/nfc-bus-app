import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'parent_attendance_controller.dart';

class ParentAttendanceView extends GetView<ParentAttendanceController> {
  const ParentAttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance – ${controller.childName}'),
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // فلاتر التاريخ
              _DateFilters(),

              const SizedBox(height: 12),
              if (controller.items.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No attendance records in this range.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                ...controller.items
                    .map((e) => _EventTile(event: e, cs: cs))
                    .toList(),
            ],
          ),
        );
      }),
    );
  }
}

class _DateFilters extends GetView<ParentAttendanceController> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Obx(() {
          final f = controller.from.value;
          final t = controller.to.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date range', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: f ?? now,
                          firstDate: DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 1),
                        );
                        if (picked != null) controller.setFrom(picked);
                      },
                      icon: const Icon(Icons.date_range),
                      label: Text(_fmtDate(f)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: t ?? now,
                          firstDate: DateTime(now.year - 1),
                          lastDate: DateTime(now.year + 1),
                        );
                        if (picked != null) controller.setTo(picked);
                      },
                      icon: const Icon(Icons.event),
                      label: Text(_fmtDate(t)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: controller.fetch,
                  icon: const Icon(Icons.filter_alt),
                  label: const Text('Apply'),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  String _fmtDate(DateTime? d) {
    if (d == null) return '—';
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final da = d.day.toString().padLeft(2, '0');
    return '$y-$m-$da';
  }
}

class _EventTile extends StatelessWidget {
  final Map<String, dynamic> event;
  final ColorScheme cs;
  const _EventTile({required this.event, required this.cs});

  @override
  Widget build(BuildContext context) {
    final type = (event['type'] ?? '').toString().toLowerCase(); // in|out
    final time = (event['time'] ?? '').toString();
    final bus = (event['bus'] ?? '').toString();
    final by = (event['by'] ?? '').toString();

    final isIn = type == 'in';
    final icon = isIn ? Icons.login : Icons.logout;
    final color = isIn ? cs.primary : cs.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: cs.onPrimary),
        ),
        title: Text('${type.toUpperCase()} — ${time.isEmpty ? '-' : time}'),
        subtitle: Text([
          if (bus.isNotEmpty) 'Bus: $bus',
          if (by.isNotEmpty) 'By: $by',
        ].join(' • ')),
      ),
    );
  }
}
