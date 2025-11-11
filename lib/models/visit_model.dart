import 'package:cloud_firestore/cloud_firestore.dart';

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
  final String? hostEmail;
  final DateTime visitDate;
  final DateTime expectedArrivalTime;
  final DateTime expectedDepartureTime;
  final DateTime? actualArrivalTime;
  final DateTime? actualDepartureTime;
  final String status; // pending, approved, denied, cancelled
  final String? qrCode;
  final String? notes;
  final bool checkedIn;
  final bool checkedOut;
  final String? checkInId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? approvedBy;
  final String? approvedByName;
  final DateTime? approvedAt;
  final String? denialReason;
  final String? deniedBy;
  final DateTime? deniedAt;

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
    this.hostEmail,
    required this.visitDate,
    required this.expectedArrivalTime,
    required this.expectedDepartureTime,
    this.actualArrivalTime,
    this.actualDepartureTime,
    required this.status,
    this.qrCode,
    this.notes,
    this.checkedIn = false,
    this.checkedOut = false,
    this.checkInId,
    required this.createdAt,
    required this.updatedAt,
    this.approvedBy,
    this.approvedByName,
    this.approvedAt,
    this.denialReason,
    this.deniedBy,
    this.deniedAt,
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
      hostEmail: data['hostEmail'],
      visitDate: (data['visitDate'] as Timestamp).toDate(),
      expectedArrivalTime: (data['expectedArrivalTime'] as Timestamp).toDate(),
      expectedDepartureTime:
          (data['expectedDepartureTime'] as Timestamp).toDate(),
      actualArrivalTime: (data['actualArrivalTime'] as Timestamp?)?.toDate(),
      actualDepartureTime:
          (data['actualDepartureTime'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'pending',
      qrCode: data['qrCode'],
      notes: data['notes'],
      checkedIn: data['checkedIn'] ?? false,
      checkedOut: data['checkedOut'] ?? false,
      checkInId: data['checkInId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      approvedBy: data['approvedBy'],
      approvedByName: data['approvedByName'],
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      denialReason: data['denialReason'],
      deniedBy: data['deniedBy'],
      deniedAt: (data['deniedAt'] as Timestamp?)?.toDate(),
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
      'hostEmail': hostEmail,
      'visitDate': Timestamp.fromDate(visitDate),
      'expectedArrivalTime': Timestamp.fromDate(expectedArrivalTime),
      'expectedDepartureTime': Timestamp.fromDate(expectedDepartureTime),
      'actualArrivalTime': actualArrivalTime != null
          ? Timestamp.fromDate(actualArrivalTime!)
          : null,
      'actualDepartureTime': actualDepartureTime != null
          ? Timestamp.fromDate(actualDepartureTime!)
          : null,
      'status': status,
      'qrCode': qrCode,
      'notes': notes,
      'checkedIn': checkedIn,
      'checkedOut': checkedOut,
      'checkInId': checkInId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'approvedBy': approvedBy,
      'approvedByName': approvedByName,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'denialReason': denialReason,
      'deniedBy': deniedBy,
      'deniedAt': deniedAt != null ? Timestamp.fromDate(deniedAt!) : null,
    };
  }

  // Computed properties
  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isDenied => status == 'denied';
  bool get isCancelled => status == 'cancelled';

  bool get isToday {
    final now = DateTime.now();
    return visitDate.year == now.year &&
        visitDate.month == now.month &&
        visitDate.day == now.day;
  }

  bool get isPast {
    return visitDate.isBefore(DateTime.now());
  }

  bool get isFuture {
    return visitDate.isAfter(DateTime.now());
  }

  bool get canCheckIn {
    if (!isApproved || !isToday || checkedIn) return false;
    final now = DateTime.now();
    final twoHoursBefore =
        expectedArrivalTime.subtract(const Duration(hours: 2));
    final twoHoursAfter = expectedArrivalTime.add(const Duration(hours: 2));
    return now.isAfter(twoHoursBefore) && now.isBefore(twoHoursAfter);
  }

  bool get canCheckOut {
    return checkedIn && !checkedOut;
  }

  Duration? get actualDuration {
    if (actualArrivalTime == null || actualDepartureTime == null) return null;
    return actualDepartureTime!.difference(actualArrivalTime!);
  }

  Duration get expectedDuration {
    return expectedDepartureTime.difference(expectedArrivalTime);
  }

  String get statusDisplayText {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'denied':
        return 'Denied';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  VisitModel copyWith({
    String? id,
    String? visitorId,
    String? visitorName,
    String? visitorEmail,
    String? visitorPhone,
    String? visitorCompany,
    String? purposeOfVisit,
    String? hostName,
    String? hostDepartment,
    String? hostEmail,
    DateTime? visitDate,
    DateTime? expectedArrivalTime,
    DateTime? expectedDepartureTime,
    DateTime? actualArrivalTime,
    DateTime? actualDepartureTime,
    String? status,
    String? qrCode,
    String? notes,
    bool? checkedIn,
    bool? checkedOut,
    String? checkInId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? approvedBy,
    String? approvedByName,
    DateTime? approvedAt,
    String? denialReason,
    String? deniedBy,
    DateTime? deniedAt,
  }) {
    return VisitModel(
      id: id ?? this.id,
      visitorId: visitorId ?? this.visitorId,
      visitorName: visitorName ?? this.visitorName,
      visitorEmail: visitorEmail ?? this.visitorEmail,
      visitorPhone: visitorPhone ?? this.visitorPhone,
      visitorCompany: visitorCompany ?? this.visitorCompany,
      purposeOfVisit: purposeOfVisit ?? this.purposeOfVisit,
      hostName: hostName ?? this.hostName,
      hostDepartment: hostDepartment ?? this.hostDepartment,
      hostEmail: hostEmail ?? this.hostEmail,
      visitDate: visitDate ?? this.visitDate,
      expectedArrivalTime: expectedArrivalTime ?? this.expectedArrivalTime,
      expectedDepartureTime:
          expectedDepartureTime ?? this.expectedDepartureTime,
      actualArrivalTime: actualArrivalTime ?? this.actualArrivalTime,
      actualDepartureTime: actualDepartureTime ?? this.actualDepartureTime,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      notes: notes ?? this.notes,
      checkedIn: checkedIn ?? this.checkedIn,
      checkedOut: checkedOut ?? this.checkedOut,
      checkInId: checkInId ?? this.checkInId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedByName: approvedByName ?? this.approvedByName,
      approvedAt: approvedAt ?? this.approvedAt,
      denialReason: denialReason ?? this.denialReason,
      deniedBy: deniedBy ?? this.deniedBy,
      deniedAt: deniedAt ?? this.deniedAt,
    );
  }
}
