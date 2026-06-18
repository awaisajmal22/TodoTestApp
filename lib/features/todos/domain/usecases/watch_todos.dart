import '../entities/todo_item.dart';
import '../repositories/todo_repository.dart';

class WatchTodos {
  const WatchTodos(this.repository);

  final TodoRepository repository;

  Stream<List<TodoItem>> call() => repository.watchTodos();
}