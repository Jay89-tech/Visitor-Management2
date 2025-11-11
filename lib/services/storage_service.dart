import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Upload profile photo
  Future<String?> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      final fileName = 'profile_$userId${path.extension(imageFile.path)}';
      final ref = _storage.ref().child('profiles').child(fileName);

      final uploadTask = ref.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('Profile photo uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile photo: $e');
      return null;
    }
  }

  // Upload document
  Future<String?> uploadDocument(
    String userId,
    File documentFile,
    String documentType,
  ) async {
    try {
      final fileName =
          '${documentType}_$userId${path.extension(documentFile.path)}';
      final ref =
          _storage.ref().child('documents').child(userId).child(fileName);

      final uploadTask = ref.putFile(
        documentFile,
        SettableMetadata(
          customMetadata: {
            'userId': userId,
            'documentType': documentType,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('Document uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading document: $e');
      return null;
    }
  }

  // Delete file
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      debugPrint('File deleted: $fileUrl');
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  // Get download progress
  Stream<TaskSnapshot> getUploadProgress(UploadTask task) {
    return task.snapshotEvents;
  }

  // Get file metadata
  Future<FullMetadata?> getFileMetadata(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      return await ref.getMetadata();
    } catch (e) {
      debugPrint('Error getting file metadata: $e');
      return null;
    }
  }

  // List user files
  Future<List<Reference>> listUserFiles(String userId) async {
    try {
      final ref = _storage.ref().child('documents').child(userId);
      final result = await ref.listAll();
      return result.items;
    } catch (e) {
      debugPrint('Error listing user files: $e');
      return [];
    }
  }

  // Upload with progress callback
  Future<String?> uploadWithProgress(
    File file,
    String path,
    Function(double progress) onProgress,
  ) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);

      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });

      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading with progress: $e');
      return null;
    }
  }
}
