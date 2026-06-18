import '../entities/todo_item.dart';

abstract class TodoRepository {
  Stream<List<TodoItem>> watchTodos();
  Future<void> addTodo(String title);
  Future<void> toggleTodo(String id, bool isCompleted);
  Future<void> deleteTodo(String id);
}
