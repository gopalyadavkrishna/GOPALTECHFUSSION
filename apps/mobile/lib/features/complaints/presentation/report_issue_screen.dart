import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:power_alert/app/providers.dart';
import 'package:power_alert/domain/models/complaint.dart';
import 'package:power_alert/shared/widgets/app_navigation_scaffold.dart';

class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  IssueType _issueType = IssueType.noPower;
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() => _submitting = true);
    try {
      final complaint = await ref
          .read(complaintRepositoryProvider)
          .create(
            issueType: _issueType,
            description: _descriptionController.text.trim(),
            areaId: 'indiranagar',
            areaName: 'Indiranagar, Bengaluru',
            latitude: 12.9784,
            longitude: 77.6408,
          );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle_rounded, color: Colors.green),
          title: const Text('Complaint submitted'),
          content: Text(
            'Ticket ${complaint.id} was created. We will notify you as the '
            'repair progresses.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      _descriptionController.clear();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => AppNavigationScaffold(
    currentIndex: 3,
    appBar: AppBar(
      title: const Text(
        'Report an issue',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
    ),
    body: Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current location',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          'Indiranagar, Bengaluru',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('Change')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'What happened?',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: constraints.maxWidth > 600 ? 4 : 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.35,
              ),
              itemCount: IssueType.values.length,
              itemBuilder: (context, index) {
                final type = IssueType.values[index];
                final selected = type == _issueType;
                return FilterChip(
                  selected: selected,
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(
                      type.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),
                  onSelected: (_) => setState(() => _issueType = type),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _descriptionController,
            minLines: 4,
            maxLines: 7,
            maxLength: 1000,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Describe the issue',
              hintText: 'Include when it started and any safety observations.',
              alignLabelWithHint: true,
            ),
            validator: (value) => (value?.trim().length ?? 0) < 10
                ? 'Add at least 10 characters.'
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            'Attachments',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _AttachmentButton(
                icon: Icons.photo_camera_rounded,
                label: 'Photo',
                onTap: () {},
              ),
              _AttachmentButton(
                icon: Icons.videocam_rounded,
                label: 'Video',
                onTap: () {},
              ),
              _AttachmentButton(
                icon: Icons.mic_rounded,
                label: 'Voice',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
            label: Text(_submitting ? 'Submitting...' : 'Submit complaint'),
          ),
          const SizedBox(height: 12),
          const Text(
            'For fire, electrocution, or a fallen live wire, move away '
            'from the hazard and contact emergency services immediately.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class _AttachmentButton extends StatelessWidget {
  const _AttachmentButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap,
    icon: Icon(icon),
    label: Text(label),
  );
}
