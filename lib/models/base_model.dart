import 'package:cloud_firestore/cloud_firestore.dart';

abstract class BaseModel {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final bool isActive;

  BaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.isActive = true,
  });

  Map<String, dynamic> toMap();

  Map<String, dynamic> toFirestore() {
    return {
      ...toMap(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'isActive': isActive,
    };
  }

  static DateTime? timestampToDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  static Map<String, dynamic> processTimestamps(Map<String, dynamic> data) {
    return {
      ...data,
      'createdAt': timestampToDateTime(data['createdAt']) ?? DateTime.now(),
      'updatedAt': timestampToDateTime(data['updatedAt']) ?? DateTime.now(),
    };
  }
}

mixin SoftDeletable {
  bool get isDeleted;
  DateTime? get deletedAt;
  String? get deletedBy;

  Map<String, dynamic> toSoftDeleteMap() {
    return {
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
      'deletedBy': deletedBy,
    };
  }
}

mixin Assignable {
  String? get assignedTo;
  String? get teamId;

  Map<String, dynamic> toAssignableMap() {
    return {
      'assignedTo': assignedTo,
      'teamId': teamId,
    };
  }
}

mixin Approvable {
  bool get requiresApproval;
  bool get isApproved;
  String? get approvedBy;
  DateTime? get approvedAt;
  String? get approvalNotes;

  Map<String, dynamic> toApprovableMap() {
    return {
      'requiresApproval': requiresApproval,
      'isApproved': isApproved,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt,
      'approvalNotes': approvalNotes,
    };
  }
}

mixin Attachable {
  List<String> get attachments;

  Map<String, dynamic> toAttachableMap() {
    return {
      'attachments': attachments,
    };
  }
}

mixin Notable {
  List<Note> get notes;

  Map<String, dynamic> toNotableMap() {
    return {
      'notes': notes.map((note) => note.toMap()).toList(),
    };
  }
}

class Note {
  final String id;
  final String content;
  final String createdBy;
  final DateTime createdAt;
  final bool isPrivate;

  Note({
    required this.id,
    required this.content,
    required this.createdBy,
    required this.createdAt,
    this.isPrivate = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'isPrivate': isPrivate,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      content: map['content'] as String,
      createdBy: map['createdBy'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isPrivate: map['isPrivate'] as bool? ?? false,
    );
  }
}

abstract class BaseService<T extends BaseModel> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collection;

  BaseService(this.collection);

  CollectionReference<Map<String, dynamic>> get collectionRef => 
      _firestore.collection(collection);

  Future<String> add(T model) async {
    final doc = await collectionRef.add(model.toFirestore());
    return doc.id;
  }

  Future<void> update(String id, T model) async {
    await collectionRef.doc(id).update(model.toFirestore());
  }

  Future<void> delete(String id) async {
    await collectionRef.doc(id).delete();
  }

  Future<T?> get(String id);

  Stream<List<T>> streamAll({
    String? orderBy,
    bool descending = false,
    int? limit,
    Map<String, dynamic>? filters,
  }) {
    Query<Map<String, dynamic>> query = collectionRef;

    if (filters != null) {
      filters.forEach((field, value) {
        if (value is List) {
          query = query.where(field, whereIn: value);
        } else {
          query = query.where(field, isEqualTo: value);
        }
      });
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return fromMap(BaseModel.processTimestamps(data));
      }).toList();
    });
  }

  T fromMap(Map<String, dynamic> map);
}
