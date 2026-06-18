import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/todo_item.dart';
import '../bloc/todos_bloc.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key, required this.syncLabel});

  final String syncLabel;

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<TodosBloc>().add(const TodosSubscriptionRequested());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitTodo() {
    context.read<TodosBloc>().add(TodosTitleSubmitted(_controller.text));
    _controller.clear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TodosBloc, TodosState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        final message = state.errorMessage;
        if (message == null || message.isEmpty) {
          return;
        }

        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFF101426),
            ),
          );
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEFF3FF), Color(0xFFFDFDFF), Color(0xFFF7F4FF)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -70,
                right: -40,
                child: _GlowBlob(
                  color: const Color(0xFF5B7CFF).withOpacity(0.16),
                  size: 180,
                ),
              ),
              Positioned(
                top: 180,
                left: -50,
                child: _GlowBlob(
                  color: const Color(0xFF00B8A9).withOpacity(0.14),
                  size: 140,
                ),
              ),
              SafeArea(
                child: BlocBuilder<TodosBloc, TodosState>(
                  builder: (context, state) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final layout = _ResponsiveLayout.fromWidth(
                          constraints.maxWidth,
                        );
                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: layout.contentMaxWidth,
                            ),
                            child: CustomScrollView(
                              physics: const BouncingScrollPhysics(),
                              slivers: [
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                    layout.horizontalPadding,
                                    layout.topPadding,
                                    layout.horizontalPadding,
                                    14,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: _Header(
                                      syncLabel: widget.syncLabel,
                                      state: state,
                                      isCompact: layout.isCompact,
                                    ),
                                  ),
                                ),
                                SliverPadding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: layout.horizontalPadding,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: _StatsRow(
                                      state: state,
                                      isCompact: layout.isCompact,
                                    ),
                                  ),
                                ),
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                    layout.horizontalPadding,
                                    20,
                                    layout.horizontalPadding,
                                    12,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: _Composer(
                                      controller: _controller,
                                      focusNode: _focusNode,
                                      onAdd: _submitTodo,
                                      isCompact: layout.isCompact,
                                    ),
                                  ),
                                ),
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                    layout.horizontalPadding,
                                    0,
                                    layout.horizontalPadding,
                                    14,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: _FilterBar(state: state),
                                  ),
                                ),
                                SliverPadding(
                                  padding: EdgeInsets.fromLTRB(
                                    layout.horizontalPadding,
                                    0,
                                    layout.horizontalPadding,
                                    24,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 280,
                                      ),
                                      child: state.visibleTodos.isEmpty
                                          ? const _EmptyState(
                                              key: ValueKey('empty'),
                                            )
                                          : _TodoList(
                                              key: const ValueKey('todo-list'),
                                              todos: state.visibleTodos,
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResponsiveLayout {
  const _ResponsiveLayout({
    required this.isCompact,
    required this.contentMaxWidth,
    required this.horizontalPadding,
    required this.topPadding,
  });

  final bool isCompact;
  final double contentMaxWidth;
  final double horizontalPadding;
  final double topPadding;

  factory _ResponsiveLayout.fromWidth(double width) {
    if (width < 600) {
      return const _ResponsiveLayout(
        isCompact: true,
        contentMaxWidth: 560,
        horizontalPadding: 16,
        topPadding: 8,
      );
    }
    if (width < 1024) {
      return const _ResponsiveLayout(
        isCompact: false,
        contentMaxWidth: 860,
        horizontalPadding: 24,
        topPadding: 12,
      );
    }
    return const _ResponsiveLayout(
      isCompact: false,
      contentMaxWidth: 1120,
      horizontalPadding: 32,
      topPadding: 18,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.syncLabel,
    required this.state,
    required this.isCompact,
  });

  final String syncLabel;
  final TodosState state;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2457FF), Color(0xFF6A8BFF)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2457FF).withOpacity(0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Todo Flow', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'A calm, animated task board with Firebase-backed sync.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            PopupMenuButton<_HeaderAction>(
              tooltip: 'Account options',
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (action) async {
                switch (action) {
                  case _HeaderAction.profile:
                    Navigator.of(context).pushNamed(AppRoutes.profile);
                    break;
                  case _HeaderAction.logout:
                    await context.read<AuthCubit>().signOut();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem<_HeaderAction>(
                  value: _HeaderAction.profile,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.person_outline_rounded),
                    title: Text('Profile'),
                  ),
                ),
                PopupMenuItem<_HeaderAction>(
                  value: _HeaderAction.logout,
                  child: ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.logout_rounded),
                    title: Text('Logout'),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _Badge(label: syncLabel),
        const SizedBox(height: 12),
        Text(
          '${state.activeCount} tasks left to finish',
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF101426),
          ),
        ),
      ],
    );
  }
}

enum _HeaderAction { profile, logout }

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state, required this.isCompact});

  final TodosState state;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Column(
        children: [
          _StatCard(
            label: 'Total',
            value: state.totalCount.toString(),
            icon: Icons.view_list_rounded,
            tint: const Color(0xFF2457FF),
          ),
          const SizedBox(height: 12),
          _StatCard(
            label: 'Done',
            value: state.completedCount.toString(),
            icon: Icons.check_circle_rounded,
            tint: const Color(0xFF18A566),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Total',
            value: state.totalCount.toString(),
            icon: Icons.view_list_rounded,
            tint: const Color(0xFF2457FF),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Done',
            value: state.completedCount.toString(),
            icon: Icons.check_circle_rounded,
            tint: const Color(0xFF18A566),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.tint,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18204A).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: tint, size: 18),
              const SizedBox(width: 8),
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 28),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.onAdd,
    required this.isCompact,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onAdd;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withOpacity(0.75)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18204A).withOpacity(0.06),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Capture a new task',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (isCompact)
            Column(
              children: [
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => onAdd(),
                  decoration: InputDecoration(
                    hintText: 'Write a todo you actually want to finish',
                    filled: true,
                    fillColor: const Color(0xFFF4F7FF),
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add todo'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => onAdd(),
                    decoration: InputDecoration(
                      hintText: 'Write a todo you actually want to finish',
                      filled: true,
                      fillColor: const Color(0xFFF4F7FF),
                      prefixIcon: const Icon(Icons.edit_note_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: onAdd,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add todo'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.state});

  final TodosState state;

  @override
  Widget build(BuildContext context) {
    final filters = <TodoFilter, String>{
      TodoFilter.all: 'All',
      TodoFilter.active: 'Open',
      TodoFilter.completed: 'Done',
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final entry in filters.entries)
          _FilterChip(
            label: entry.value,
            selected: state.filter == entry.key,
            onSelected: () {
              context.read<TodosBloc>().add(TodosFilterChanged(entry.key));
            },
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      label: Text(label),
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      labelStyle: TextStyle(
        color: selected ? Colors.white : const Color(0xFF101426),
        fontWeight: FontWeight.w700,
      ),
      selectedColor: const Color(0xFF2457FF),
      backgroundColor: Colors.white.withOpacity(0.82),
      side: BorderSide(color: Colors.white.withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    );
  }
}

class _TodoList extends StatelessWidget {
  const _TodoList({super.key, required this.todos});

  final List<TodoItem> todos;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 1000
            ? 2
            : constraints.maxWidth >= 700
            ? 2
            : 1;
        final itemHeight = crossAxisCount == 1 ? 96.0 : 112.0;

        if (crossAxisCount == 1) {
          return Column(
            children: [
              for (final todo in todos) ...[
                _TodoTile(todo: todo),
                const SizedBox(height: 12),
              ],
            ],
          );
        }

        return GridView.builder(
          itemCount: todos.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: itemHeight,
          ),
          itemBuilder: (context, index) => _TodoTile(todo: todos[index]),
        );
      },
    );
  }
}

class _TodoTile extends StatelessWidget {
  const _TodoTile({required this.todo});

  final TodoItem todo;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5E77),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<TodosBloc>().add(TodosDeleted(todo.id));
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.88),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: todo.isCompleted
                ? const Color(0xFF18A566).withOpacity(0.18)
                : Colors.white.withOpacity(0.7),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF18204A).withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                context.read<TodosBloc>().add(
                  TodosToggled(id: todo.id, isCompleted: !todo.isCompleted),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: todo.isCompleted
                      ? const Color(0xFF18A566)
                      : const Color(0xFFF0F3FF),
                ),
                child: Icon(
                  todo.isCompleted
                      ? Icons.check_rounded
                      : Icons.circle_outlined,
                  size: 18,
                  color: todo.isCompleted
                      ? Colors.white
                      : const Color(0xFF2457FF),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: todo.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: todo.isCompleted
                          ? const Color(0xFF8290A9)
                          : const Color(0xFF101426),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(todo.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<TodosBloc>().add(TodosDeleted(todo.id));
              },
              icon: const Icon(Icons.delete_outline_rounded),
              color: const Color(0xFF8290A9),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final meridiem = dateTime.hour >= 12 ? 'PM' : 'AM';
    return 'Created at $hour:$minute $meridiem';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18204A).withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2457FF), Color(0xFF88A2FF)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Nothing here yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a task to see the animated list, Firebase sync, and completion tracking in action.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF101426),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0.01)]),
      ),
    );
  }
}
