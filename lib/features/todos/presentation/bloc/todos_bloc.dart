import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/todo_item.dart';
import '../../domain/usecases/add_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/toggle_todo.dart';
import '../../domain/usecases/watch_todos.dart';

part 'todos_event.dart';
part 'todos_state.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  TodosBloc({
    required WatchTodos watchTodos,
    required AddTodo addTodo,
    required ToggleTodo toggleTodo,
    required DeleteTodo deleteTodo,
  }) : _watchTodos = watchTodos,
       _addTodo = addTodo,
       _toggleTodo = toggleTodo,
       _deleteTodo = deleteTodo,
       super(const TodosState()) {
    on<TodosSubscriptionRequested>(_onSubscriptionRequested);
    on<TodosFilterChanged>(_onFilterChanged);
    on<TodosTitleSubmitted>(_onTitleSubmitted);
    on<TodosToggled>(_onToggled);
    on<TodosDeleted>(_onDeleted);
  }

  final WatchTodos _watchTodos;
  final AddTodo _addTodo;
  final ToggleTodo _toggleTodo;
  final DeleteTodo _deleteTodo;

  Future<void> _onSubscriptionRequested(
    TodosSubscriptionRequested event,
    Emitter<TodosState> emit,
  ) async {
    await emit.forEach<List<TodoItem>>(
      _watchTodos(),
      onData: (todos) => state.copyWith(
        status: TodosStatus.success,
        todos: todos,
        errorMessage: null,
      ),
      onError: (_, __) => state.copyWith(
        status: TodosStatus.failure,
        errorMessage: 'Could not load todos right now.',
      ),
    );
  }

  void _onFilterChanged(TodosFilterChanged event, Emitter<TodosState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onTitleSubmitted(
    TodosTitleSubmitted event,
    Emitter<TodosState> emit,
  ) async {
    final title = event.title.trim();
    if (title.isEmpty) {
      emit(state.copyWith(errorMessage: 'Enter a task before saving it.'));
      return;
    }

    try {
      await _addTodo(title);
    } catch (_) {
      emit(
        state.copyWith(
          errorMessage: 'Could not add the todo. Please try again.',
        ),
      );
    }
  }

  Future<void> _onToggled(TodosToggled event, Emitter<TodosState> emit) async {
    try {
      await _toggleTodo(event.id, event.isCompleted);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not update the todo.'));
    }
  }

  Future<void> _onDeleted(TodosDeleted event, Emitter<TodosState> emit) async {
    try {
      await _deleteTodo(event.id);
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not delete the todo.'));
    }
  }
}
