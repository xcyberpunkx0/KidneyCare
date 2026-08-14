import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_x.dart';
import '../../../patient/data/repository_impl/patient_repository_impl.dart';
import '../controllers/capture_flow_controller.dart';
import '../widgets/camera_step.dart';
import '../widgets/crop_step.dart';
import '../widgets/extracting_step.dart';
import '../widgets/review_step.dart';

/// Full-screen capture flow: camera → crop → extract → review → save.
class CaptureFlowPage extends ConsumerWidget {
  const CaptureFlowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureFlowProvider);
    final controller = ref.read(captureFlowProvider.notifier);
    final patientName =
        ref.watch(patientProvider).value?.name.split(' ').last;

    ref.listen(captureFlowProvider, (previous, next) {
      if (next.step == CaptureStep.saved &&
          previous?.step != CaptureStep.saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.savedToTimeline)),
        );
        context.pop();
      }
      final failure = next.failure;
      if (failure != null && failure != previous?.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
        controller.dismissFailure();
      }
    });

    return Scaffold(
      backgroundColor: CaptureChrome.background,
      body: SafeArea(
        child: switch (state.step) {
          CaptureStep.camera => CameraStep(
              onCancel: () => context.pop(),
              onShutter: controller.takePhoto,
              onGallery: controller.pickFromGallery,
            ),
          CaptureStep.cropping => CropStep(
              imageBytes: state.pickedBytes!,
              onRetake: controller.retake,
              onCropped: controller.confirmCrop,
            ),
          CaptureStep.extracting =>
            ExtractingStep(patientName: patientName),
          CaptureStep.review ||
          CaptureStep.saving ||
          CaptureStep.saved =>
            ReviewStep(
              state: state,
              onEdit: controller.editField,
              onChooseAlternative: controller.chooseAlternative,
              onSave: controller.save,
            ),
        },
      ),
    );
  }
}
