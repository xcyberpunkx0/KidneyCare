import 'package:flutter/material.dart';

/// Create/edit a claim draft. Placeholder — Task 10 fills in the form.
class ClaimEditPage extends StatelessWidget {
  const ClaimEditPage({super.key, this.claimId});

  /// Id of the draft claim being edited; null when creating a new one.
  final String? claimId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}
