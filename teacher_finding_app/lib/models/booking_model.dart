/// Booking (Class Session) Model
class Booking {
  final String id;
  final String requestId;
  final String studentId;
  final String teacherId;
  final String subject;
  final DateTime scheduledDate;
  final double durationHours;
  final String status; // scheduled, completed, cancelled
  final String? notes;
  final String? teacherName;
  final String? studentName;
  final double? feePerHour;
  final bool hasReview;
  final String? paymentStatus; // unpaid, paid, cancelled
  final String? createdAt;

  Booking({
    required this.id,
    required this.requestId,
    required this.studentId,
    required this.teacherId,
    required this.subject,
    required this.scheduledDate,
    required this.durationHours,
    required this.status,
    this.notes,
    this.teacherName,
    this.studentName,
    this.feePerHour,
    this.hasReview = false,
    this.paymentStatus,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      requestId: json['request_id'],
      studentId: json['student_id'],
      teacherId: json['teacher_id'],
      subject: json['subject'] ?? '',
      scheduledDate: DateTime.parse(json['scheduled_date']),
      durationHours: double.tryParse(json['duration_hours']?.toString() ?? '1') ?? 1.0,
      status: json['status'] ?? 'scheduled',
      notes: json['notes'],
      teacherName: json['teacher_name'],
      studentName: json['student_name'],
      feePerHour: double.tryParse(json['fee_per_hour']?.toString() ?? '0'),
      hasReview: json['has_review'] == true,
      paymentStatus: json['payment_status'],
      createdAt: json['created_at'],
    );
  }

  bool get isScheduled => status == 'scheduled';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';
}
