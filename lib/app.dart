import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/todos/domain/usecases/add_todo.dart';
import 'features/todos/domain/usecases/delete_todo.dart';
import 'features/todos/domain/usecases/toggle_todo.dart';
import 'features/todos/domain/usecases/watch_todos.dart';
import 'features/todos/presentation/bloc/todos_bloc.dart';
import 'features/todos/presentation/pages/todo_home_page.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({
    super.key,
    required this.syncLabel,
    required this.watchTodos,
    required this.addTodo,
    required this.toggleTodo,
    required this.deleteTodo,
  });

  final String syncLabel;
  final WatchTodos watchTodos;
  final AddTodo addTodo;
  final ToggleTodo toggleTodo;
  final DeleteTodo deleteTodo;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo Flow',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.home,
      onGenerateRoute: (settings) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => BlocProvider(
            create: (_) => TodosBloc(
              watchTodos: watchTodos,
              addTodo: addTodo,
              toggleTodo: toggleTodo,
              deleteTodo: deleteTodo,
            ),
            child: TodoHomePage(syncLabel: syncLabel),
          ),
        );
      },
    );
  }
}

class AppRoutes {
  static const home = '/';
  static const dashboard = '/dashboard';
}
