import 'package:cloud_firestore/cloud_firestore.dart';
import 'base_model.dart';

enum CustomerStatus {
  active,
  inactive,
  archived;

  String get displayName {
    switch (this) {
      case CustomerStatus.active:
        return 'Active';
      case CustomerStatus.inactive:
        return 'Inactive';
      case CustomerStatus.archived:
        return 'Archived';
    }
  }
}

class CustomerModel extends BaseModel with SoftDeletable, Assignable, Notable {
  final String name;
  final String email;
  final String phone;
  final String? address;
  final CustomerStatus status;
  final String? source;
  final Map<String, dynamic>? metadata;
  
  // SoftDeletable
  @override
  final bool isDeleted;
  @override
  final DateTime? deletedAt;
  @override
  final String? deletedBy;
  
  // Assignable
  @override
  final String? assignedTo;
  @override
  final String? teamId;
  
  // Notable
  @override
  final List<Note> notes;

  CustomerModel({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
    required this.name,
    required this.email,
    required this.phone,
    this.address,
    this.status = CustomerStatus.active,
    this.source,
    this.metadata,
    this.isDeleted = false,
    this.deletedAt,
    this.deletedBy,
    this.assignedTo,
    this.teamId,
    this.notes = const [],
    super.isActive = true,
  });

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'status': status.name,
      'source': source,
      'metadata': metadata,
      ...toSoftDeleteMap(),
      ...toAssignableMap(),
      ...toNotableMap(),
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String,
      address: map['address'] as String?,
      status: CustomerStatus.values.firstWhere(
        (e) => e.name == (map['status'] as String),
        orElse: () => CustomerStatus.active,
      ),
      source: map['source'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      isDeleted: map['isDeleted'] as bool? ?? false,
      deletedAt: BaseModel.timestampToDateTime(map['deletedAt']),
      deletedBy: map['deletedBy'] as String?,
      assignedTo: map['assignedTo'] as String?,
      teamId: map['teamId'] as String?,
      notes: (map['notes'] as List<dynamic>?)
          ?.map((e) => Note.fromMap(e as Map<String, dynamic>))
          .toList() ??
          [],
      createdAt: BaseModel.timestampToDateTime(map['createdAt']) ?? DateTime.now(),
      updatedAt: BaseModel.timestampToDateTime(map['updatedAt']) ?? DateTime.now(),
      createdBy: map['createdBy'] as String,
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    CustomerStatus? status,
    String? source,
    Map<String, dynamic>? metadata,
    bool? isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    String? assignedTo,
    String? teamId,
    List<Note>? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    bool? isActive,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      status: status ?? this.status,
      source: source ?? this.source,
      metadata: metadata ?? this.metadata,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      deletedBy: deletedBy ?? this.deletedBy,
      assignedTo: assignedTo ?? this.assignedTo,
      teamId: teamId ?? this.teamId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
    );
  }
}
