import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/app_failure.dart';

/// Wraps the platform camera/gallery pickers. The system camera UI handles
/// focus, flash and permissions; we receive the untouched JPEG bytes.
class PhotoPicker {
  PhotoPicker(this._picker);

  final ImagePicker _picker;

  /// Returns null when the user cancels.
  Future<Uint8List?> takePhoto() => _pick(ImageSource.camera);

  Future<Uint8List?> pickFromGallery() => _pick(ImageSource.gallery);

  /// Multi-select from the gallery for batch import. Returns an empty
  /// list when the user cancels.
  Future<List<Uint8List>> pickManyFromGallery() async {
    try {
      final files = await _picker.pickMultiImage(
        maxWidth: 2400,
        imageQuality: 92,
      );
      return [for (final file in files) await file.readAsBytes()];
    } catch (error, stackTrace) {
      throw PermissionFailure(
        message: 'Photos could not be opened. Check photo permission in '
            'system settings.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<Uint8List?> _pick(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 2400,
        imageQuality: 92,
      );
      return file == null ? null : await file.readAsBytes();
    } catch (error, stackTrace) {
      throw PermissionFailure(
        message: source == ImageSource.camera
            ? 'The camera could not be opened. Check camera permission in '
                'system settings.'
            : 'Photos could not be opened. Check photo permission in '
                'system settings.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

final photoPickerProvider = Provider<PhotoPicker>((ref) {
  return PhotoPicker(ImagePicker());
});
