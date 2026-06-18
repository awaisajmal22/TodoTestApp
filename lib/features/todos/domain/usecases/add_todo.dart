import '../repositories/todo_repository.dart';

class AddTodo {
  const AddTodo(this.repository);

  final TodoRepository repository;

  Future<void> call(String title) => repository.addTodo(title);
}
