import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../models/visitor_model.dart';

class NotificationProvider with ChangeNotifier {
  final FirebaseService _firebaseService;
  final NotificationService _notificationService;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  int _unreadCount = 0;

  NotificationProvider(this._firebaseService, this._notificationService) {
    _initializeListener();
  }

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _unreadCount;

  void _initializeListener() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    _firebaseService.getNotificationsStream(userId).listen((snapshot) {
      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    });
  }

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      _unreadCount = _notifications.where((n) => !n.isRead).length;
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firebaseService.markNotificationAsRead(notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final updated = _notifications[index];
        _notifications[index] = NotificationModel(
          id: updated.id,
          userId: updated.userId,
          title: updated.title,
          message: updated.message,
          type: updated.type,
          relatedVisitId: updated.relatedVisitId,
          isRead: true,
          createdAt: updated.createdAt,
        );
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final batch = FirebaseFirestore.instance.batch();

      for (var notification in _notifications.where((n) => !n.isRead)) {
        final docRef = FirebaseFirestore.instance
            .collection('notifications')
            .doc(notification.id);
        batch.update(docRef, {'isRead': true});
      }

      await batch.commit();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();

      _notifications.removeWhere((n) => n.id == notificationId);
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  void clearAll() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }
}
