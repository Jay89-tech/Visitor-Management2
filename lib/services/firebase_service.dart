import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

class FirebaseService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Get FCM Token
  Future<String?> getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Request Notification Permissions
  Future<bool> requestNotificationPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('Error requesting notification permissions: $e');
      return false;
    }
  }

  // Call Cloud Function - Validate QR Code
  Future<Map<String, dynamic>> validateQRCode({
    required String visitId,
    required String location,
  }) async {
    try {
      final result = await _functions.httpsCallable('validateQRCode').call({
        'visitId': visitId,
        'location': location,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      print('Error validating QR code: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Call Cloud Function - Check Out
  Future<Map<String, dynamic>> checkOutVisitor({
    required String checkInId,
    String? location,
  }) async {
    try {
      final result = await _functions.httpsCallable('checkOutVisitor').call({
        'checkInId': checkInId,
        'location': location,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      print('Error checking out: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // Call Cloud Function - Verify Visit
  Future<Map<String, dynamic>> verifyVisit({
    required String visitId,
  }) async {
    try {
      final result = await _functions
          .httpsCallable('verifyVisit')
          .call({'visitId': visitId});

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      print('Error verifying visit: $e');
      return {
        'valid': false,
        'error': e.toString(),
      };
    }
  }

  // Firestore - Get Visitor Profile
  Future<DocumentSnapshot?> getVisitorProfile(String userId) async {
    try {
      return await _firestore.collection('visitors').doc(userId).get();
    } catch (e) {
      print('Error getting visitor profile: $e');
      return null;
    }
  }

  // Firestore - Update FCM Token
  Future<void> updateFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('visitors').doc(userId).update({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating FCM token: $e');
    }
  }

  // Firestore - Get Notifications
  Stream<QuerySnapshot> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots();
  }

  // Firestore - Mark Notification as Read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Firestore - Get Check-In History
  Future<QuerySnapshot> getCheckInHistory(String visitorId) async {
    return await _firestore
        .collection('qr_checkins')
        .where('visitorId', isEqualTo: visitorId)
        .orderBy('checkInTime', descending: true)
        .limit(20)
        .get();
  }
}
