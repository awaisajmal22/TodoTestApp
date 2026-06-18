// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:todoapp/app.dart';
import 'package:todoapp/features/auth/data/repositories/in_memory_auth_repository.dart';
import 'package:todoapp/features/todos/data/repositories/in_memory_todo_repository.dart';
import 'package:todoapp/features/todos/domain/usecases/add_todo.dart';
import 'package:todoapp/features/todos/domain/usecases/delete_todo.dart';
import 'package:todoapp/features/todos/domain/usecases/toggle_todo.dart';
import 'package:todoapp/features/todos/domain/usecases/watch_todos.dart';

void main() {
  testWidgets('renders the todo screen', (tester) async {
    final repository = InMemoryTodoRepository();

    await tester.pumpWidget(
      TodoApp(
        authRepository: InMemoryAuthRepository(),
        syncLabel: 'Local preview mode',
        watchTodos: WatchTodos(repository),
        addTodo: AddTodo(repository),
        toggleTodo: ToggleTodo(repository),
        deleteTodo: DeleteTodo(repository),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Todo Flow'), findsOneWidget);
    expect(find.text('Add todo'), findsOneWidget);
  });
}
