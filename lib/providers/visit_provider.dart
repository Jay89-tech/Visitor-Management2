import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../models/visitor_model.dart';

class VisitProvider with ChangeNotifier {
  final FirebaseService _firebaseService;

  List<VisitModel> _visits = [];
  bool _isLoading = false;
  String? _errorMessage;

  VisitProvider(this._firebaseService) {
    _initializeListener();
  }

  // Getters
  List<VisitModel> get visits => _visits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<VisitModel> get pendingVisits =>
      _visits.where((v) => v.status == 'pending').toList();

  List<VisitModel> get approvedVisits =>
      _visits.where((v) => v.status == 'approved').toList();

  List<VisitModel> get deniedVisits =>
      _visits.where((v) => v.status == 'denied').toList();

  List<VisitModel> get todayVisits {
    final now = DateTime.now();
    return _visits.where((v) {
      return v.visitDate.year == now.year &&
          v.visitDate.month == now.month &&
          v.visitDate.day == now.day;
    }).toList();
  }

  List<VisitModel> get upcomingVisits {
    final now = DateTime.now();
    return _visits.where((v) {
      return v.visitDate.isAfter(now) && v.status == 'approved';
    }).toList()
      ..sort((a, b) => a.visitDate.compareTo(b.visitDate));
  }

  int get pendingVisitsCount => pendingVisits.length;
  int get approvedVisitsCount => approvedVisits.length;
  int get todayVisitsCount => todayVisits.length;
  int get totalVisitsCount => _visits.length;

  void _initializeListener() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    FirebaseFirestore.instance
        .collection('visits')
        .where('visitorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _visits =
          snapshot.docs.map((doc) => VisitModel.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  Future<void> loadVisits() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('visits')
          .where('visitorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      _visits =
          snapshot.docs.map((doc) => VisitModel.fromFirestore(doc)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load visits: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createVisit({
    required String purposeOfVisit,
    required String hostName,
    required String hostDepartment,
    required DateTime visitDate,
    required DateTime expectedArrivalTime,
    required DateTime expectedDepartureTime,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get visitor profile
      final visitorDoc = await FirebaseFirestore.instance
          .collection('visitors')
          .doc(user.uid)
          .get();

      if (!visitorDoc.exists) {
        throw Exception('Visitor profile not found');
      }

      final visitor = VisitorModel.fromFirestore(visitorDoc);

      final visit = VisitModel(
        id: '', // Will be auto-generated
        visitorId: user.uid,
        visitorName: visitor.fullName,
        visitorEmail: visitor.email,
        visitorPhone: visitor.phone,
        visitorCompany: visitor.company,
        purposeOfVisit: purposeOfVisit,
        hostName: hostName,
        hostDepartment: hostDepartment,
        visitDate: visitDate,
        expectedArrivalTime: expectedArrivalTime,
        expectedDepartureTime: expectedDepartureTime,
        status: 'pending',
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance.collection('visits').add(visit.toMap());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create visit: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelVisit(String visitId) async {
    try {
      await FirebaseFirestore.instance
          .collection('visits')
          .doc(visitId)
          .update({
        'status': 'denied',
        'denialReason': 'Cancelled by visitor',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel visit: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  VisitModel? getVisitById(String id) {
    try {
      return _visits.firstWhere((visit) => visit.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
