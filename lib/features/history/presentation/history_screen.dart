import 'package:flutter/material.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/config/display_config.dart';
import '../../../core/services/responsive_service.dart';
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
    final r = Responsive(displayConfig, MediaQuery.of(context).size);

    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            r.scaled(10),
            0,
            r.scaled(10),
            r.scaled(10),
          ),
          child: Column(
            children: [
              SizedBox(
                height: r.scaled(42),
                child: Row(
                  children: ['All', 'Pass', 'Fail'].map((filter) {
                    final selected = _ctrl.resultFilter == filter;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: r.scaled(6)),
                        child: InkWell(
                          onTap: () => _ctrl.setResultFilter(filter),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : AppColors.surface,
                              border: Border.all(color: AppColors.divider, width: 2),
                            ),
                            child: Text(
                              filter,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: selected
                                    ? AppColors.textOnPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: r.scaled(10)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.scaled(10),
                  vertical: r.scaled(10),
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  border: Border.all(color: AppColors.divider, width: 2),
                ),
                child: Row(
                  children: const [
                    _HeaderCell(AppStrings.dateColumn, flex: 2),
                    _HeaderCell(AppStrings.recipeColumn, flex: 2),
                    _HeaderCell(AppStrings.resultColumn, flex: 1),
                    _HeaderCell(AppStrings.operatorColumn, flex: 2),
                  ],
                ),
              ),
              SizedBox(height: r.scaled(4)),
              Expanded(
                child: ListView.builder(
                  itemCount: _ctrl.filteredRecords.length,
                  itemBuilder: (context, i) {
                    final record = _ctrl.filteredRecords[i];
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.scaled(10),
                        vertical: r.scaled(10),
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: AppColors.divider, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${record.timestamp.month}/${record.timestamp.day} '
                              '${record.timestamp.hour.toString().padLeft(2, '0')}:'
                              '${record.timestamp.minute.toString().padLeft(2, '0')}',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(record.recipeName, style: AppTextStyles.bodyMedium),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(record.result, style: AppTextStyles.bodyMedium),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(record.operatorName, style: AppTextStyles.bodyMedium),
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
      child: Text(
        label,
        style: AppTextStyles.caption,
      ),
    );
  }
}
