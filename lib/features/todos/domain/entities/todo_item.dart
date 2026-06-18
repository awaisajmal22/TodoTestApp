import 'package:equatable/equatable.dart';

class TodoItem extends Equatable {
  const TodoItem({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final DateTime createdAt;
  final bool isCompleted;

  TodoItem copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    bool? isCompleted,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, createdAt, isCompleted];
}
