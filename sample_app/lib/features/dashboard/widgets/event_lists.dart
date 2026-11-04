import 'package:material_ui/material_ui.dart';
import 'package:tracklite_sample/core/common/time_text.dart';
import 'package:tracklite_sample/core/design_system/design_system.dart';
import 'package:tracklite_sample/domain/analytics/analytics_debug.dart';
import 'package:tracklite_sample/features/dashboard/dashboard_words.dart';

/// The newest events: what each is, when, and where it is.
class RecentEventsSection extends StatelessWidget {
  const RecentEventsSection({super.key, required this.events});

  final List<RecentEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Recent events'),
        if (events.isEmpty)
          const ListTile(title: Text('Nothing tracked yet'))
        else
          for (final event in events) _EventTile(event),
      ],
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile(this.event);

  final RecentEvent event;

  @override
  Widget build(BuildContext context) {
    final retryAt = event.retryAt;
    final details = [
      if (event.summary.isNotEmpty) event.summary,
      clockTime(event.trackedAt),
      if (event.attempts > 0) count(event.attempts, 'server error'),
      if (retryAt != null && event.state == EventState.pending)
        'retry at ${clockTime(retryAt)}',
      ?event.lastError,
    ].join(' · ');
    final (icon, label, color) = event.state.style(context.appColors);
    final chip = StatusChip(icon: icon, label: label, color: color);
    // At large text the chip would leave the name a narrow column, and an
    // event name (one long word, `screen_opened`) would break mid-word:
    // the chip goes under the details instead.
    if (context.prefersStackedLayout) {
      return ListTile(
        title: Text(event.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(details),
            const SizedBox(height: AppSpacing.xSmall),
            chip,
          ],
        ),
      );
    }
    return ListTile(
      title: Text(event.name),
      subtitle: Text(details),
      trailing: chip,
    );
  }
}

/// The newest upload runs: why each ran, and what came of it.
class UploadLogSection extends StatelessWidget {
  const UploadLogSection({super.key, required this.runs});

  final List<UploadRun> runs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader('Upload log'),
        if (runs.isEmpty)
          const ListTile(title: Text('No upload yet'))
        else
          for (final run in runs)
            ListTile(
              leading: Icon(_iconOf(run.outcome)),
              title: Text(
                '${triggerWords(run.trigger)} · ${outcomeWords(run.outcome)}',
              ),
              subtitle: Text(
                [
                  clockTime(run.finishedAt),
                  if (run.events > 0) count(run.events, 'event'),
                  ?run.error,
                ].join(' · '),
              ),
            ),
      ],
    );
  }

  static IconData _iconOf(UploadOutcome outcome) => switch (outcome) {
    UploadOutcome.uploaded => Icons.cloud_done_outlined,
    UploadOutcome.nothing => Icons.cloud_queue,
    UploadOutcome.offline => Icons.wifi_off,
    UploadOutcome.failed => Icons.error_outline,
    UploadOutcome.keyRejected => Icons.key_off_outlined,
  };
}

extension on EventState {
  (IconData, String, Color) style(AppColors colors) => switch (this) {
    EventState.pending => (Icons.schedule, 'Pending', colors.pending),
    EventState.sending => (
      Icons.cloud_upload_outlined,
      'Sending',
      colors.sending,
    ),
    EventState.sent => (Icons.cloud_done_outlined, 'Sent', colors.sent),
    EventState.failed => (Icons.error_outline, 'Failed', colors.failed),
  };
}
