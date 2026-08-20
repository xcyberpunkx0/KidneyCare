import 'dart:async';

import 'package:flutter/material.dart';

Timer? _dismissTimer;

/// Shows a snackbar that always leaves on its own after three seconds.
///
/// Flutter keeps a snackbar with an action on screen indefinitely while
/// any accessibility service is running, so the built-in timeout can't
/// be trusted for the undo bubbles — this closes them from our own
/// timer instead. Each call replaces the previous bubble and its timer,
/// so a stale timer can never dismiss a newer message.
void showAppSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  _dismissTimer?.cancel();
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: actionLabel == null || onAction == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction),
      ),
    );
  _dismissTimer = Timer(
    const Duration(seconds: 3),
    messenger.hideCurrentSnackBar,
  );
}
