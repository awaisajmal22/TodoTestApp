import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/auth_gate_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/profile_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/todos/domain/usecases/add_todo.dart';
import 'features/todos/domain/usecases/delete_todo.dart';
import 'features/todos/domain/usecases/toggle_todo.dart';
import 'features/todos/domain/usecases/watch_todos.dart';

class TodoApp extends StatelessWidget {
  const TodoApp({
    super.key,
    required this.authRepository,
    required this.syncLabel,
    required this.watchTodos,
    required this.addTodo,
    required this.toggleTodo,
    required this.deleteTodo,
  });

  final AuthRepository authRepository;
  final String syncLabel;
  final WatchTodos watchTodos;
  final AddTodo addTodo;
  final ToggleTodo toggleTodo;
  final DeleteTodo deleteTodo;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>.value(
      value: authRepository,
      child: BlocProvider(
        create: (_) => AuthCubit(authRepository)..bootstrap(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Todo Flow',
          theme: AppTheme.light(),
          initialRoute: AppRoutes.home,
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.home:
                return _fadeRoute(
                  settings,
                  AuthGatePage(
                    syncLabel: syncLabel,
                    watchTodos: watchTodos,
                    addTodo: addTodo,
                    toggleTodo: toggleTodo,
                    deleteTodo: deleteTodo,
                  ),
                );
              case AppRoutes.login:
                return _fadeRoute(settings, const LoginPage());
              case AppRoutes.signup:
                return _fadeRoute(settings, const SignupPage());
              case AppRoutes.profile:
                return _fadeRoute(settings, const ProfilePage());
              default:
                return _fadeRoute(
                  settings,
                  AuthGatePage(
                    syncLabel: syncLabel,
                    watchTodos: watchTodos,
                    addTodo: addTodo,
                    toggleTodo: toggleTodo,
                    deleteTodo: deleteTodo,
                  ),
                );
            }
          },
        ),
      ),
    );
  }

  PageRouteBuilder<void> _fadeRoute(RouteSettings settings, Widget child) {
    return PageRouteBuilder<void>(
      settings: settings,
      pageBuilder: (_, animation, __) => child,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0.03),
              end: Offset.zero,
            ).animate(fade),
            child: child,
          ),
        );
      },
    );
  }
}

class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const profile = '/profile';
}
