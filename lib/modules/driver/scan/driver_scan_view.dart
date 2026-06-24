import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'driver_scan_controller.dart';

class DriverScanView extends GetView<DriverScanController> {
  const DriverScanView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan (NFC)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: cs.primaryContainer,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tap a student NFC wristband/card',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: controller.scanning.value
                              ? null
                              : controller.startOneShotScan,
                          icon: const Icon(Icons.nfc),
                          label: const Text('Scan'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: controller.syncing.value
                              ? null
                              : controller.flushPending,
                          icon: const Icon(Icons.sync),
                          label: const Text('Sync Pending'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Status:',
                        style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 6),
                    _StatusLine(
                        label: 'Scanning',
                        value: controller.scanning.value ? 'YES' : 'NO'),
                    _StatusLine(
                        label: 'Syncing',
                        value: controller.syncing.value ? 'YES' : 'NO'),
                    _StatusLine(
                        label: 'Last UID',
                        value: controller.lastUid.value ?? '-'),
                    _StatusLine(
                        label: 'Last Result',
                        value: controller.lastResult.value ?? '-'),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          const _Tips(),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final String label;
  final String value;
  const _StatusLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 110, child: Text(label)),
          const Text(':  '),
          Expanded(child: Text(value, maxLines: 2)),
        ],
      ),
    );
  }
}

class _Tips extends StatelessWidget {
  const _Tips();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tips', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('• تأكّد أن الجهاز يدعم NFC ومفعّل.'),
            Text('• قرّب السوار/البطاقة من منطقة NFC خلف الهاتف.'),
            Text(
                '• عند انقطاع الإنترنت، سيتم حفظ المسحات وإرسالها لاحقاً عبر Sync Pending.'),
          ],
        ),
      ),
    );
  }
}
