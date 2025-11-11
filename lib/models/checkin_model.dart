import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInModel {
  final String id;
  final String visitId;
  final String visitorId;
  final String visitorName;
  final String visitorCompany;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String checkInLocation;
  final String? checkOutLocation;
  final String verifiedBy;
  final String? verifiedByName;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CheckInModel({
    required this.id,
    required this.visitId,
    required this.visitorId,
    required this.visitorName,
    required this.visitorCompany,
    required this.checkInTime,
    this.checkOutTime,
    required this.checkInLocation,
    this.checkOutLocation,
    required this.verifiedBy,
    this.verifiedByName,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory CheckInModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CheckInModel(
      id: doc.id,
      visitId: data['visitId'] ?? '',
      visitorId: data['visitorId'] ?? '',
      visitorName: data['visitorName'] ?? '',
      visitorCompany: data['visitorCompany'] ?? '',
      checkInTime: (data['checkInTime'] as Timestamp).toDate(),
      checkOutTime: (data['checkOutTime'] as Timestamp?)?.toDate(),
      checkInLocation: data['checkInLocation'] ?? '',
      checkOutLocation: data['checkOutLocation'],
      verifiedBy: data['verifiedBy'] ?? '',
      verifiedByName: data['verifiedByName'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'visitId': visitId,
      'visitorId': visitorId,
      'visitorName': visitorName,
      'visitorCompany': visitorCompany,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'checkOutTime':
          checkOutTime != null ? Timestamp.fromDate(checkOutTime!) : null,
      'checkInLocation': checkInLocation,
      'checkOutLocation': checkOutLocation,
      'verifiedBy': verifiedBy,
      'verifiedByName': verifiedByName,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Computed properties
  bool get isCheckedOut => checkOutTime != null;

  Duration? get duration {
    if (checkOutTime == null) return null;
    return checkOutTime!.difference(checkInTime);
  }

  String get durationFormatted {
    if (duration == null) return 'In Progress';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  bool get isActive => !isCheckedOut;

  String get statusText {
    return isCheckedOut ? 'Checked Out' : 'Checked In';
  }

  CheckInModel copyWith({
    String? id,
    String? visitId,
    String? visitorId,
    String? visitorName,
    String? visitorCompany,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? checkInLocation,
    String? checkOutLocation,
    String? verifiedBy,
    String? verifiedByName,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CheckInModel(
      id: id ?? this.id,
      visitId: visitId ?? this.visitId,
      visitorId: visitorId ?? this.visitorId,
      visitorName: visitorName ?? this.visitorName,
      visitorCompany: visitorCompany ?? this.visitorCompany,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      checkInLocation: checkInLocation ?? this.checkInLocation,
      checkOutLocation: checkOutLocation ?? this.checkOutLocation,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedByName: verifiedByName ?? this.verifiedByName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
