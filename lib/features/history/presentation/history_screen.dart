import 'package:flutter/material.dart';
import '../../../app/constants/app_sizes.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../controller/history_controller.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final HistoryController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = HistoryController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            children: [
              // Filter bar
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['All', 'Pass', 'Fail'].map((f) {
                    final selected = _ctrl.resultFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: selected,
                        selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
                        onSelected: (_) => _ctrl.setResultFilter(f),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              // Table header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _HeaderCell(AppStrings.dateColumn, flex: 2),
                    _HeaderCell(AppStrings.recipeColumn, flex: 2),
                    _HeaderCell(AppStrings.resultColumn, flex: 1),
                    _HeaderCell(AppStrings.operatorColumn, flex: 2),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Rows
              Expanded(
                child: ListView.builder(
                  itemCount: _ctrl.filteredRecords.length,
                  itemBuilder: (context, i) {
                    final r = _ctrl.filteredRecords[i];
                    final isPass = r.result == 'Pass';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.divider,
                            width: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${r.timestamp.month}/${r.timestamp.day} '
                              '${r.timestamp.hour.toString().padLeft(2, '0')}:'
                              '${r.timestamp.minute.toString().padLeft(2, '0')}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(r.recipeName,
                                style: AppTextStyles.bodyMedium),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              r.result,
                              style: AppTextStyles.statusLabel.copyWith(
                                color: isPass
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(r.operatorName,
                                style: AppTextStyles.bodyMedium),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String label;
  final int flex;
  const _HeaderCell(this.label, {this.flex = 1});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(label, style: AppTextStyles.caption.copyWith(
        fontWeight: FontWeight.w600,
      )),
    );
  }
}
