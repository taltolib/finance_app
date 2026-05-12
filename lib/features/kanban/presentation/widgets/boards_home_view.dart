import 'package:flutter/material.dart';
import '../../../../core/theme/colors/app_colors.dart';
import '../../../../core/theme/colors/theme_custom.dart';
import '../../../../generated/fonts/app_fonts.dart';
import '../../../../shared/widgets/archive_tile_widget.dart';

class BoardsHomeView extends StatelessWidget {
  final VoidCallback onOpenCurrent;
  final VoidCallback onOpenArchived;

  const BoardsHomeView({
    super.key,
    required this.onOpenCurrent,
    required this.onOpenArchived,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppThemeColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Управление расходами',
              style: AppFonts.mulish.s24w700(color: colors.text)),
          const SizedBox(height: 60),
          Text(
            'Доски',
            style: AppFonts.mulish.s20w700(color: colors.text),
          ),
          const SizedBox(height: 20),
          ArchiveTileWidget(
            title: 'Текущий месяц',
            colorBackG: colors.background,
            titleColor: colors.text,
            onTap: onOpenCurrent,
            colorBorder:  colors.text.withOpacity(0.08),
            child: const Icon(
              Icons.dashboard_customize_outlined,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 20),
          ArchiveTileWidget(
            title: 'Архивированные',
            colorBackG: colors.background,
            titleColor: colors.text,
            onTap: onOpenArchived,
            colorBorder:  colors.text.withOpacity(0.08),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppColors.blue,
            ),
          ),
          const SizedBox(height: 24),
          // const _InfoCard(),
        ],
      ),
    );
  }
}

// class _InfoCard extends StatelessWidget {
//   const _InfoCard();
//
//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       'Все расходы месяца попадают в «Неразобранные» автоматически',
//       'Перетащите карточку в нужную колонку',
//       'Скролл → переход между колонками',
//       'Кнопка ⊖ отдаляет доску для обзора',
//     ];
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: KanbanUiColors.blue.withOpacity(0.06),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(
//           color: KanbanUiColors.blue.withOpacity(0.15),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Как работает разбор',
//             style: kanbanText(
//               size: 12,
//               weight: FontWeight.w700,
//               color: KanbanUiColors.blue,
//             ),
//           ),
//           const SizedBox(height: 6),
//           ...items.indexed.map(
//             (entry) {
//               final index = entry.$1;
//               final text = entry.$2;
//
//               return Padding(
//                 padding: const EdgeInsets.only(top: 6),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       '${index + 1}.',
//                       style: kanbanText(
//                         size: 12,
//                         weight: FontWeight.w700,
//                         color: KanbanUiColors.blue,
//                         height: 1.4,
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         text,
//                         style: kanbanText(
//                           size: 12,
//                           color: KanbanUiColors.textDim,
//                           height: 1.4,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
