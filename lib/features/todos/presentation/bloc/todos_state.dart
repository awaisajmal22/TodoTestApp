part of 'todos_bloc.dart';

enum TodosStatus { initial, success, failure }

enum TodoFilter { all, active, completed }

class TodosState extends Equatable {
  const TodosState({
    this.status = TodosStatus.initial,
    this.todos = const <TodoItem>[],
    this.filter = TodoFilter.all,
    this.errorMessage,
  });

  final TodosStatus status;
  final List<TodoItem> todos;
  final TodoFilter filter;
  final String? errorMessage;

  List<TodoItem> get visibleTodos {
    switch (filter) {
      case TodoFilter.all:
        return todos;
      case TodoFilter.active:
        return todos.where((todo) => !todo.isCompleted).toList(growable: false);
      case TodoFilter.completed:
        return todos.where((todo) => todo.isCompleted).toList(growable: false);
    }
  }

  int get totalCount => todos.length;
  int get completedCount => todos.where((todo) => todo.isCompleted).length;
  int get activeCount => totalCount - completedCount;

  TodosState copyWith({
    TodosStatus? status,
    List<TodoItem>? todos,
    TodoFilter? filter,
    String? errorMessage,
  }) {
    return TodosState(
      status: status ?? this.status,
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, todos, filter, errorMessage];
}
