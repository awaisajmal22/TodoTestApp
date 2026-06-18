import 'dart:async';
import 'dart:collection';

import '../../domain/entities/todo_item.dart';
import '../../domain/repositories/todo_repository.dart';

class InMemoryTodoRepository implements TodoRepository {
  InMemoryTodoRepository() {
    _seed();
  }

  final Map<String, TodoItem> _todos = LinkedHashMap<String, TodoItem>();
  final StreamController<List<TodoItem>> _controller =
      StreamController<List<TodoItem>>.broadcast();
  int _nextId = 0;

  @override
  Stream<List<TodoItem>> watchTodos() {
    _controller.add(_snapshot());
    return _controller.stream;
  }

  @override
  Future<void> addTodo(String title) async {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Todo title cannot be empty');
    }

    final id = 'local-${_nextId++}';
    _todos[id] = TodoItem(
      id: id,
      title: normalized,
      createdAt: DateTime.now(),
      isCompleted: false,
    );
    _emit();
  }

  @override
  Future<void> toggleTodo(String id, bool isCompleted) async {
    final current = _todos[id];
    if (current == null) {
      return;
    }

    _todos[id] = current.copyWith(isCompleted: isCompleted);
    _emit();
  }

  @override
  Future<void> deleteTodo(String id) async {
    _todos.remove(id);
    _emit();
  }

  void _seed() {
    final now = DateTime.now();
    _todos['local-0'] = TodoItem(
      id: 'local-0',
      title: 'Design the launch screen',
      createdAt: now.subtract(const Duration(hours: 4)),
      isCompleted: true,
    );
    _todos['local-1'] = TodoItem(
      id: 'local-1',
      title: 'Sync todos with Firebase',
      createdAt: now.subtract(const Duration(hours: 2)),
      isCompleted: false,
    );
    _todos['local-2'] = TodoItem(
      id: 'local-2',
      title: 'Polish animations and states',
      createdAt: now.subtract(const Duration(minutes: 30)),
      isCompleted: false,
    );
    _nextId = 3;
  }

  List<TodoItem> _snapshot() => _todos.values.toList(growable: false);

  void _emit() {
    _controller.add(_snapshot());
  }
}