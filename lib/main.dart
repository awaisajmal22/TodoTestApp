import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/data/repositories/in_memory_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/todos/data/repositories/firestore_todo_repository.dart';
import 'features/todos/data/repositories/in_memory_todo_repository.dart';
import 'features/todos/domain/repositories/todo_repository.dart';
import 'features/todos/domain/usecases/add_todo.dart';
import 'features/todos/domain/usecases/delete_todo.dart';
import 'features/todos/domain/usecases/toggle_todo.dart';
import 'features/todos/domain/usecases/watch_todos.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AuthRepository authRepository;
  TodoRepository repository;
  String syncLabel;

  try {
    await Firebase.initializeApp();
    authRepository = FirebaseAuthRepository();
    repository = FirestoreTodoRepository();
    syncLabel = 'Firebase sync active';
  } catch (_) {
    authRepository = InMemoryAuthRepository();
    repository = InMemoryTodoRepository();
    syncLabel = 'Local preview mode';
  }

  runApp(
    TodoApp(
      authRepository: authRepository,
      syncLabel: syncLabel,
      watchTodos: WatchTodos(repository),
      addTodo: AddTodo(repository),
      toggleTodo: ToggleTodo(repository),
      deleteTodo: DeleteTodo(repository),
    ),
  );
}
