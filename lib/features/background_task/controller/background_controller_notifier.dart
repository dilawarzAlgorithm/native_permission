// lib/features/background_task/controller/background_controller_notifier.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../domain/background_state.dart';

const String backgroundTaskKey = "com.native_permission.bg_sync";

class BackgroundControllerNotifier extends AsyncNotifier<BackgroundState> {
  static const _isScheduledKey = 'is_bg_scheduled';
  static const _lastRunKey = 'last_bg_run';

  @override
  FutureOr<BackgroundState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final isScheduled = prefs.getBool(_isScheduledKey) ?? false;
    final lastRun = prefs.getString(_lastRunKey);

    return BackgroundState(
      isTaskScheduled: isScheduled,
      lastRunTimestamp: lastRun,
    );
  }

  Future<void> toggleBackgroundProcess() async {
    final currentState = state.value;
    if (currentState == null) return;

    final prefs = await SharedPreferences.getInstance();
    final willSchedule = !currentState.isTaskScheduled;

    if (willSchedule) {
      // 15 minutes is the minimum interval allowed by Android/iOS
      await Workmanager().registerPeriodicTask(
        "1", // unique task ID
        backgroundTaskKey,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType:
              NetworkType.connected, // Only run if internet is available
        ),
      );
    } else {
      await Workmanager().cancelAll();
    }

    await prefs.setBool(_isScheduledKey, willSchedule);
    state = AsyncValue.data(
      currentState.copyWith(isTaskScheduled: willSchedule),
    );
  }

  // Since the background task runs in a separate isolate, it cannot trigger
  // Riverpod to rebuild. We must manually check for updates when the user opens this view.
  Future<void> refreshTimestamp() async {
    final currentState = state.value;
    if (currentState == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final lastRun = prefs.getString(_lastRunKey);

    state = AsyncValue.data(currentState.copyWith(lastRunTimestamp: lastRun));
  }
}

final backgroundProvider =
    AsyncNotifierProvider.autoDispose<
      BackgroundControllerNotifier,
      BackgroundState
    >(BackgroundControllerNotifier.new);
