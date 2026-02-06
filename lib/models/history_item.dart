enum HistoryType { face, document }

class HistoryItem {
  final int? id;
  final String filePath;
  final HistoryType type;
  final int faceCount;
  final DateTime createdAt;

  HistoryItem({
    this.id,
    required this.filePath,
    required this.type,
    this.faceCount = 0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'file_path': filePath,
    'type': type.index,
    'face_count': faceCount,
    'created_at': createdAt.millisecondsSinceEpoch,
  };

  factory HistoryItem.fromMap(Map<String, dynamic> map) => HistoryItem(
    id: map['id'],
    filePath: map['file_path'],
    type: HistoryType.values[map['type']],
    faceCount: map['face_count'],
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
  );
}
