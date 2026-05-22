// lib/features/background_task/presentation/background_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controller/background_controller_notifier.dart';

class BackgroundView extends ConsumerWidget {
  const BackgroundView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bgAsync = ref.watch(backgroundProvider);

    return bgAsync.when(
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (bgState) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        bgState.isTaskScheduled
                            ? Icons.cloud_sync
                            : Icons.cloud_off,
                        size: 64,
                        color: bgState.isTaskScheduled
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Periodic Data Sync'),
                        subtitle: const Text('Runs in background ~every 15m'),
                        value: bgState.isTaskScheduled,
                        onChanged: (val) {
                          ref
                              .read(backgroundProvider.notifier)
                              .toggleBackgroundProcess();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'Last Background Execution:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        bgState.lastRunTimestamp != null
                            ? bgState.lastRunTimestamp!
                            : 'Has not executed yet.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => ref
                            .read(backgroundProvider.notifier)
                            .refreshTimestamp(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Check for Updates'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
