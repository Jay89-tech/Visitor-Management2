import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

class QRService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate QR data for a visit
  String generateQRData(String visitId) {
    final data = {
      'visitId': visitId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'type': 'visitor_checkin',
    };
    return jsonEncode(data);
  }

  // Validate QR code data
  Future<QRValidationResult> validateQRCode(String qrData) async {
    try {
      // Parse QR data
      final Map<String, dynamic> data = jsonDecode(qrData);

      if (data['type'] != 'visitor_checkin') {
        return QRValidationResult(
          isValid: false,
          message: 'Invalid QR code type',
        );
      }

      final visitId = data['visitId'] as String?;
      if (visitId == null) {
        return QRValidationResult(
          isValid: false,
          message: 'Invalid QR code data',
        );
      }

      // Get visit from Firestore
      final visitDoc = await _firestore.collection('visits').doc(visitId).get();

      if (!visitDoc.exists) {
        return QRValidationResult(
          isValid: false,
          message: 'Visit not found',
        );
      }

      final visitData = visitDoc.data()!;

      // Check if visit is approved
      if (visitData['status'] != 'approved') {
        return QRValidationResult(
          isValid: false,
          message: 'Visit is not approved',
        );
      }

      // Check if visit date is today
      final visitDate = (visitData['visitDate'] as Timestamp).toDate();
      final now = DateTime.now();
      final isToday = visitDate.year == now.year &&
          visitDate.month == now.month &&
          visitDate.day == now.day;

      if (!isToday) {
        return QRValidationResult(
          isValid: false,
          message: 'Visit is not scheduled for today',
        );
      }

      // Check time window (2 hours before to 2 hours after expected arrival)
      final expectedArrival =
          (visitData['expectedArrivalTime'] as Timestamp).toDate();
      final twoHoursBefore = expectedArrival.subtract(const Duration(hours: 2));
      final twoHoursAfter = expectedArrival.add(const Duration(hours: 2));

      if (now.isBefore(twoHoursBefore) || now.isAfter(twoHoursAfter)) {
        return QRValidationResult(
          isValid: false,
          message: 'Outside check-in time window',
        );
      }

      // Check if already checked in
      final checkInQuery = await _firestore
          .collection('checkins')
          .where('visitId', isEqualTo: visitId)
          .get();

      if (checkInQuery.docs.isNotEmpty) {
        return QRValidationResult(
          isValid: false,
          message: 'Already checked in',
        );
      }

      return QRValidationResult(
        isValid: true,
        message: 'Valid QR code',
        visitId: visitId,
        visitData: visitData,
      );
    } catch (e) {
      debugPrint('Error validating QR code: $e');
      return QRValidationResult(
        isValid: false,
        message: 'Error validating QR code: ${e.toString()}',
      );
    }
  }

  // Process check-in
  Future<CheckInResult> processCheckIn({
    required String visitId,
    required String verifiedBy,
    String? location,
  }) async {
    try {
      // Validate QR first
      final validation = await validateQRCode(
        generateQRData(visitId),
      );

      if (!validation.isValid) {
        return CheckInResult(
          success: false,
          message: validation.message,
        );
      }

      // Create check-in record
      final checkInData = {
        'visitId': visitId,
        'visitorId': validation.visitData!['visitorId'],
        'checkInTime': FieldValue.serverTimestamp(),
        'checkInLocation': location ?? 'Main Entrance',
        'verifiedBy': verifiedBy,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final checkInRef =
          await _firestore.collection('checkins').add(checkInData);

      // Update visit status
      await _firestore.collection('visits').doc(visitId).update({
        'checkedIn': true,
        'checkInId': checkInRef.id,
        'actualArrivalTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return CheckInResult(
        success: true,
        message: 'Check-in successful',
        checkInId: checkInRef.id,
      );
    } catch (e) {
      debugPrint('Error processing check-in: $e');
      return CheckInResult(
        success: false,
        message: 'Error processing check-in: ${e.toString()}',
      );
    }
  }

  // Process check-out
  Future<CheckOutResult> processCheckOut({
    required String checkInId,
    String? location,
  }) async {
    try {
      // Get check-in record
      final checkInDoc =
          await _firestore.collection('checkins').doc(checkInId).get();

      if (!checkInDoc.exists) {
        return CheckOutResult(
          success: false,
          message: 'Check-in record not found',
        );
      }

      final checkInData = checkInDoc.data()!;

      // Check if already checked out
      if (checkInData['checkOutTime'] != null) {
        return CheckOutResult(
          success: false,
          message: 'Already checked out',
        );
      }

      // Update check-in record
      await _firestore.collection('checkins').doc(checkInId).update({
        'checkOutTime': FieldValue.serverTimestamp(),
        'checkOutLocation': location ?? 'Main Entrance',
      });

      // Update visit
      await _firestore.collection('visits').doc(checkInData['visitId']).update({
        'checkedOut': true,
        'actualDepartureTime': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return CheckOutResult(
        success: true,
        message: 'Check-out successful',
      );
    } catch (e) {
      debugPrint('Error processing check-out: $e');
      return CheckOutResult(
        success: false,
        message: 'Error processing check-out: ${e.toString()}',
      );
    }
  }
}

// Result classes
class QRValidationResult {
  final bool isValid;
  final String message;
  final String? visitId;
  final Map<String, dynamic>? visitData;

  QRValidationResult({
    required this.isValid,
    required this.message,
    this.visitId,
    this.visitData,
  });
}

class CheckInResult {
  final bool success;
  final String message;
  final String? checkInId;

  CheckInResult({
    required this.success,
    required this.message,
    this.checkInId,
  });
}

class CheckOutResult {
  final bool success;
  final String message;

  CheckOutResult({
    required this.success,
    required this.message,
  });
}
