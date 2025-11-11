import 'package:cloud_firestore/cloud_firestore.dart';

class VisitorModel {
  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String company;
  final String? photoUrl;
  final String? fcmToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  VisitorModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.company,
    this.photoUrl,
    this.fcmToken,
    required this.createdAt,
    required this.updatedAt,
  });

  // From Firestore
  factory VisitorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VisitorModel(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      company: data['company'] ?? '',
      photoUrl: data['photoUrl'],
      fcmToken: data['fcmToken'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // To Map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'company': company,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Copy With
  VisitorModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? company,
    String? photoUrl,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VisitorModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class VisitModel {
  final String id;
  final String visitorId;
  final String visitorName;
  final String visitorEmail;
  final String visitorPhone;
  final String visitorCompany;
  final String purposeOfVisit;
  final String hostName;
  final String hostDepartment;
  final DateTime visitDate;
  final DateTime expectedArrivalTime;
  final DateTime expectedDepartureTime;
  final String status; // pending, approved, denied
  final String? qrCode;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? denialReason;

  VisitModel({
    required this.id,
    required this.visitorId,
    required this.visitorName,
    required this.visitorEmail,
    required this.visitorPhone,
    required this.visitorCompany,
    required this.purposeOfVisit,
    required this.hostName,
    required this.hostDepartment,
    required this.visitDate,
    required this.expectedArrivalTime,
    required this.expectedDepartureTime,
    required this.status,
    this.qrCode,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.approvedBy,
    this.approvedAt,
    this.denialReason,
  });

  factory VisitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VisitModel(
      id: doc.id,
      visitorId: data['visitorId'] ?? '',
      visitorName: data['visitorName'] ?? '',
      visitorEmail: data['visitorEmail'] ?? '',
      visitorPhone: data['visitorPhone'] ?? '',
      visitorCompany: data['visitorCompany'] ?? '',
      purposeOfVisit: data['purposeOfVisit'] ?? '',
      hostName: data['hostName'] ?? '',
      hostDepartment: data['hostDepartment'] ?? '',
      visitDate: (data['visitDate'] as Timestamp).toDate(),
      expectedArrivalTime: (data['expectedArrivalTime'] as Timestamp).toDate(),
      expectedDepartureTime:
          (data['expectedDepartureTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      qrCode: data['qrCode'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      approvedBy: data['approvedBy'],
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      denialReason: data['denialReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'visitorId': visitorId,
      'visitorName': visitorName,
      'visitorEmail': visitorEmail,
      'visitorPhone': visitorPhone,
      'visitorCompany': visitorCompany,
      'purposeOfVisit': purposeOfVisit,
      'hostName': hostName,
      'hostDepartment': hostDepartment,
      'visitDate': Timestamp.fromDate(visitDate),
      'expectedArrivalTime': Timestamp.fromDate(expectedArrivalTime),
      'expectedDepartureTime': Timestamp.fromDate(expectedDepartureTime),
      'status': status,
      'qrCode': qrCode,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'denialReason': denialReason,
    };
  }

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isDenied => status == 'denied';
  bool get isToday {
    final now = DateTime.now();
    return visitDate.year == now.year &&
        visitDate.month == now.month &&
        visitDate.day == now.day;
  }

  bool get canCheckIn {
    if (!isApproved || !isToday) return false;
    final now = DateTime.now();
    final twoHoursBefore =
        expectedArrivalTime.subtract(const Duration(hours: 2));
    final twoHoursAfter = expectedArrivalTime.add(const Duration(hours: 2));
    return now.isAfter(twoHoursBefore) && now.isBefore(twoHoursAfter);
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String? relatedVisitId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedVisitId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      relatedVisitId: data['relatedVisitId'],
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

class CheckInModel {
  final String id;
  final String visitId;
  final String visitorId;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final String checkInLocation;
  final String? checkOutLocation;
  final String verifiedBy;
  final DateTime createdAt;

  CheckInModel({
    required this.id,
    required this.visitId,
    required this.visitorId,
    required this.checkInTime,
    this.checkOutTime,
    required this.checkInLocation,
    this.checkOutLocation,
    required this.verifiedBy,
    required this.createdAt,
  });

  factory CheckInModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CheckInModel(
      id: doc.id,
      visitId: data['visitId'] ?? '',
      visitorId: data['visitorId'] ?? '',
      checkInTime: (data['checkInTime'] as Timestamp).toDate(),
      checkOutTime: (data['checkOutTime'] as Timestamp?)?.toDate(),
      checkInLocation: data['checkInLocation'] ?? '',
      checkOutLocation: data['checkOutLocation'],
      verifiedBy: data['verifiedBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

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
}
