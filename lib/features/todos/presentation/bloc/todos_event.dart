part of 'todos_bloc.dart';

sealed class TodosEvent extends Equatable {
  const TodosEvent();

  @override
  List<Object?> get props => [];
}

final class TodosSubscriptionRequested extends TodosEvent {
  const TodosSubscriptionRequested();
}

final class TodosFilterChanged extends TodosEvent {
  const TodosFilterChanged(this.filter);

  final TodoFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class TodosTitleSubmitted extends TodosEvent {
  const TodosTitleSubmitted(this.title);

  final String title;

  @override
  List<Object?> get props => [title];
}

final class TodosToggled extends TodosEvent {
  const TodosToggled({required this.id, required this.isCompleted});

  final String id;
  final bool isCompleted;

  @override
  List<Object?> get props => [id, isCompleted];
}

final class TodosDeleted extends TodosEvent {
  const TodosDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
