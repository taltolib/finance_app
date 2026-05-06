import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class KanbanColumn {
  String id;
  String title;
  Color color;
  List<KanbanCard> cards;

  KanbanColumn({
    required this.id,
    required this.title,
    required this.color,
    required this.cards,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'color': color.value,
      'cards': cards.map((card) => card.toMap()).toList(),
    };
  }

  factory KanbanColumn.fromMap(Map<String, dynamic> map) {
    return KanbanColumn(
      id: map['id'],
      title: map['title'],
      color: Color(map['color']),
      cards: (map['cards'] as List).map((cardMap) => KanbanCard.fromMap(cardMap)).toList(),
    );
  }
}

class KanbanCard {
  String id;
  String? transactionId;
  Color cardColor;
  String? note;
  String status;
  DateTime createdAt;

  KanbanCard({
    required this.id,
    this.transactionId,
    required this.cardColor,
    this.note,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'cardColor': cardColor.value,
      'note': note,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory KanbanCard.fromMap(Map<String, dynamic> map) {
    return KanbanCard(
      id: map['id'],
      transactionId: map['transactionId'],
      cardColor: Color(map['cardColor']),
      note: map['note'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}