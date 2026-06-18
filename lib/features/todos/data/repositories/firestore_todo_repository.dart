import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/todo_item.dart';
import '../../domain/repositories/todo_repository.dart';

class FirestoreTodoRepository implements TodoRepository {
  FirestoreTodoRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('todos');

  @override
  Stream<List<TodoItem>> watchTodos() {
    return _collection
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map(_fromDocument).toList(growable: false),
        );
  }

  @override
  Future<void> addTodo(String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Todo title cannot be empty');
    }

    return _collection.add({
      'title': normalized,
      'isCompleted': false,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  @override
  Future<void> toggleTodo(String id, bool isCompleted) {
    return _collection.doc(id).update({'isCompleted': isCompleted});
  }

  @override
  Future<void> deleteTodo(String id) {
    return _collection.doc(id).delete();
  }

  TodoItem _fromDocument(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return TodoItem(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled task',
      createdAt: _extractCreatedAt(data['createdAt']),
      isCompleted: data['isCompleted'] as bool? ?? false,
    );
  }

  DateTime _extractCreatedAt(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.now();
  }
}