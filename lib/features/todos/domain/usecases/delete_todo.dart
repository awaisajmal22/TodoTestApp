import '../repositories/todo_repository.dart';

class DeleteTodo {
  const DeleteTodo(this.repository);

  final TodoRepository repository;

  Future<void> call(String id) => repository.deleteTodo(id);
}
