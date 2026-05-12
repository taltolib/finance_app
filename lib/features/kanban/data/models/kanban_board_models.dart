class KanbanCardModel {
  final String id; /// id карточки
  final String place;///откуда
  final double amount;/// сколко (сумма)
  final String date;///2026-01-06
  final String columnId; /// id колонки

  const KanbanCardModel({
    required this.id,
    required this.place,
    required this.amount,
    required this.date,
    required this.columnId,
  });

  KanbanCardModel copyWith({
    String? id,
    String? place,
    double? amount,
    String? date,
    String? columnId,
  }) {
    return KanbanCardModel(
      id: id ?? this.id,
      place: place ?? this.place,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      columnId: columnId ?? this.columnId,
    );
  }
}

class KanbanColumnModel {
  final String id;
  final String title;
  final bool isSystem;
  final List<KanbanCardModel> cards;

  const KanbanColumnModel({
    required this.id,
    required this.title,
    required this.isSystem,
    required this.cards,
  });

  KanbanColumnModel copyWith({
    String? id,
    String? title,
    bool? isSystem,
    List<KanbanCardModel>? cards,
  }) {
    return KanbanColumnModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isSystem: isSystem ?? this.isSystem,
      cards: cards ?? this.cards,
    );
  }
}

class ArchivedBoardModel {
  final String id;
  final String title;
  final String month;

  const ArchivedBoardModel({
    required this.id,
    required this.title,
    required this.month,
  });
}

class KanbanDragData {
  final String cardId;
  final String fromColumnId;

  const KanbanDragData({
    required this.cardId,
    required this.fromColumnId,
  });
}

const archivedBoards = <ArchivedBoardModel>[
  ArchivedBoardModel(id: '1', title: 'Доска января', month: 'Январь 2025'),
  ArchivedBoardModel(id: '2', title: 'Доска февраля', month: 'Февраль 2025'),
  ArchivedBoardModel(id: '3', title: 'Доска марта', month: 'Март 2025'),
  ArchivedBoardModel(id: '4', title: 'Доска апреля', month: 'Апрель 2025'),
];

// List<KanbanCardModel> mockTransactions() {
//   return const [
//     KanbanCardModel(
//       id: 't1',
//       place: 'Korzinka.uz',
//       amount: -52000,
//       date: '06 май в 10:12',
//       columnId: 'unsorted',
//     ),
//     KanbanCardModel(
//       id: 't2',
//       place: 'Payme',
//       amount: -15000,
//       date: '05 май в 18:44',
//       columnId: 'unsorted',
//     ),
//     KanbanCardModel(
//       id: 't3',
//       place: 'Uzum Market',
//       amount: -34500,
//       date: '04 май в 09:30',
//       columnId: 'unsorted',
//     ),
//     KanbanCardModel(
//       id: 't4',
//       place: 'Makro',
//       amount: -89000,
//       date: '03 май в 14:22',
//       columnId: 'unsorted',
//     ),
//     KanbanCardModel(
//       id: 't5',
//       place: 'Alibaba',
//       amount: -120000,
//       date: '02 май в 11:05',
//       columnId: 'unsorted',
//     ),
//     KanbanCardModel(
//       id: 't6',
//       place: 'Subway',
//       amount: -25000,
//       date: '01 май в 13:15',
//       columnId: 'unsorted',
//     ),
//     KanbanCardModel(
//       id: 't7',
//       place: 'Beeline',
//       amount: -10000,
//       date: '01 май в 09:00',
//       columnId: 'unsorted',
//     ),
//   ];
// }
//
// List<KanbanColumnModel> initialKanbanColumns() {
//   return [
//     KanbanColumnModel(
//       id: 'unsorted',
//       title: 'Неразобранные',
//       isSystem: true,
//       cards: mockTransactions(),
//     ),
//     const KanbanColumnModel(
//       id: 'food',
//       title: 'Еда',
//       isSystem: false,
//       cards: [],
//     ),
//   ];
// }