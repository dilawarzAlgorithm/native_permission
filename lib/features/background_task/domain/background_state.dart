class BackgroundState {
  final bool isTaskScheduled;
  final String? lastRunTimestamp;

  BackgroundState({this.isTaskScheduled = false, this.lastRunTimestamp});

  BackgroundState copyWith({bool? isTaskScheduled, String? lastRunTimestamp}) {
    return BackgroundState(
      isTaskScheduled: isTaskScheduled ?? this.isTaskScheduled,
      lastRunTimestamp: lastRunTimestamp ?? this.lastRunTimestamp,
    );
  }
}
