import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../todos/domain/usecases/add_todo.dart';
import '../../../todos/domain/usecases/delete_todo.dart';
import '../../../todos/domain/usecases/toggle_todo.dart';
import '../../../todos/domain/usecases/watch_todos.dart';
import '../../../todos/presentation/bloc/todos_bloc.dart';
import '../../../todos/presentation/pages/todo_home_page.dart';
import '../cubit/auth_cubit.dart';
import 'auth_splash_page.dart';
import 'login_page.dart';

class AuthGatePage extends StatelessWidget {
  const AuthGatePage({
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
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const AuthSplashPage();
        }

        if (!state.isAuthenticated) {
          return const LoginPage();
        }

        return BlocProvider(
          create: (_) => TodosBloc(
            watchTodos: watchTodos,
            addTodo: addTodo,
            toggleTodo: toggleTodo,
            deleteTodo: deleteTodo,
          )..add(const TodosSubscriptionRequested()),
          child: TodoHomePage(syncLabel: syncLabel),
        );
      },
    );
  }
}
