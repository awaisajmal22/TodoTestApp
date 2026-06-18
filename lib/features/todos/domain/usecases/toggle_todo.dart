import '../repositories/todo_repository.dart';

class ToggleTodo {
  const ToggleTodo(this.repository);

  final TodoRepository repository;

  Future<void> call(String id, bool isCompleted) =>
      repository.toggleTodo(id, isCompleted);
}
