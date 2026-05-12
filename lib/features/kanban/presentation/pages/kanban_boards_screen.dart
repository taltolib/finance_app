import 'package:flutter/material.dart';

import '../widgets/archived_boards_view.dart';
import '../widgets/board_view.dart';
import '../widgets/boards_home_view.dart';
import '../widgets/kanban_theme.dart';

enum KanbanScreenState {
  boards,
  currentBoard,
  archived,
}

class KanbanBoardsScreen extends StatefulWidget {
  const KanbanBoardsScreen({super.key});

  @override
  State<KanbanBoardsScreen> createState() => _KanbanBoardsScreenState();
}

class _KanbanBoardsScreenState extends State<KanbanBoardsScreen> {
  KanbanScreenState _screen = KanbanScreenState.boards;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: KanbanBackground(
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _buildScreen(),
          ),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case KanbanScreenState.boards:
        return BoardsHomeView(
          key: const ValueKey('boards'),
          onOpenCurrent: () {
            setState(() => _screen = KanbanScreenState.currentBoard);
          },
          onOpenArchived: () {
            setState(() => _screen = KanbanScreenState.archived);
          },
        );

      case KanbanScreenState.currentBoard:
        return BoardView(
          key: const ValueKey('currentBoard'),
          onBack: () {
            setState(() => _screen = KanbanScreenState.boards);
          },
        );

      case KanbanScreenState.archived:
        return ArchivedBoardsView(
          key: const ValueKey('archived'),
          onBack: () {
            setState(() => _screen = KanbanScreenState.boards);
          },
        );
    }
  }
}