class RepairModel {
  final int id;
  final String customerId;
  final String deviceModel;
  final String issueDescription;
  final String? imageUrl;
  final String status;
  final String? aiDiagnosticReport;
  final double estimatedCost;
  final int? technicianId;
  final int? repairServiceId;
  final DateTime appointmentDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  RepairModel({
    required this.id,
    required this.customerId,
    required this.deviceModel,
    required this.issueDescription,
    this.imageUrl,
    required this.status,
    this.aiDiagnosticReport,
    required this.estimatedCost,
    this.technicianId,
    this.repairServiceId,
    required this.appointmentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RepairModel.fromJson(Map<String, dynamic> json) {
    return RepairModel(
      id: json['id'] ?? 0,
      customerId: json['customerId']?.toString() ?? '',
      deviceModel: json['deviceModel']?.toString() ?? '',
      issueDescription: json['issueDescription']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      aiDiagnosticReport: json['aiDiagnosticReport']?.toString(),
      estimatedCost:
          double.tryParse(json['estimatedCost']?.toString() ?? '') ?? 0,
      technicianId: json['technicianId'],
      repairServiceId: json['repairServiceId'],
      appointmentDate:
          DateTime.tryParse(json['appointmentDate']?.toString() ?? '') ??
          DateTime.now(),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
