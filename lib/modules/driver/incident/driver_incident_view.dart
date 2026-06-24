import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'driver_incident_controller.dart';

class DriverIncidentView extends GetView<DriverIncidentController> {
  const DriverIncidentView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident'),
        actions: [
          // ✅ استخدم .value داخل Obx
          Obx(() => Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text('Pending: ${controller.pendingCount.value}'),
                ),
              )),
          Obx(() => IconButton(
                tooltip: 'Sync Pending',
                onPressed:
                    controller.syncing.value ? null : controller.syncPending,
                icon: controller.syncing.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
              )),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // نوع البلاغ
          Text('Type', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),

          // ✅ هذا Obx يقرأ Rx (type.value) بشكل صحيح
          Obx(() => SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                      value: 'delay',
                      label: Text('Delay'),
                      icon: Icon(Icons.schedule)),
                  ButtonSegment(
                      value: 'breakdown',
                      label: Text('Breakdown'),
                      icon: Icon(Icons.build_outlined)),
                  ButtonSegment(
                      value: 'accident',
                      label: Text('Accident'),
                      icon: Icon(Icons.emergency_outlined)),
                  ButtonSegment(
                      value: 'other',
                      label: Text('Other'),
                      icon: Icon(Icons.more_horiz)),
                ],
                selected: {controller.type.value},
                onSelectionChanged: (s) => controller.type.value = s.first,
              )),
          const SizedBox(height: 16),

          // الملاحظة
          Text('Note (optional)',
              style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),

          // ❌ لا حاجة لـ Obx هنا (لا يوجد قراءة Rx داخل الودجت)
          TextField(
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Write any details…',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => controller.note.value = v,
          ),

          const SizedBox(height: 20),

          // زر الإرسال
          Obx(() => FilledButton.icon(
                onPressed: controller.loading.value ? null : controller.submit,
                icon: controller.loading.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  controller.loading.value ? 'Sending…' : 'Send Incident',
                ),
              )),

          const SizedBox(height: 12),
          Card(
            color: cs.surfaceVariant.withOpacity(.6),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'If you are offline, incidents will be saved locally and synced later.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
