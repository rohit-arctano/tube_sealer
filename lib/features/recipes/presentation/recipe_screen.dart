import 'package:flutter/material.dart';
import 'package:tube_sealer/core/models/recipe_model.dart';
import '../../../app/constants/app_sizes.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/info_card.dart';
import '../../../core/config/display_config.dart';
import '../../../core/services/responsive_service.dart';
import '../../../widget/components/ui_components.dart';
import '../controller/recipe_controller.dart';

class RecipeScreen extends StatefulWidget {
 
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  late final RecipeController _ctrl;
  String? _selectedMaterial; // null means all materials

  List<String> get _materials => [
    'Silicone (Liveo™ Pharma 50)',
    'Silicone (Pumpsil®)',
    'Silicone (STHT-C®)',
    'TPE (AdvantaFlex®)',
    'TPE (C-Flex®)',
    'TPE (Tuflux® TPE)',
  ];

  List<String> get _materialOptions => ['All Materials', ..._materials];

  List<RecipeModel> get _filteredRecipes {
    if (_selectedMaterial == null) return _ctrl.recipes;
    return _ctrl.recipes.where((r) => r.material == _selectedMaterial).toList();
  }

  @override
  void initState() {
    super.initState();
    _ctrl = RecipeController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(displayConfig, MediaQuery.of(context).size);
    final selectedMaterialIndex =
        _selectedMaterial == null ? 0 : _materialOptions.indexOf(_selectedMaterial!);

    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            children: [
              // Match the login screen dropdown styling for material filtering.
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(r.scaled(12)),
                decoration: BoxDecoration(
                  color: r.bgDark(),
                  border: Border.all(color: r.borderDark(), width: 2),
                ),
                child: SpinBox(
                  label: 'Filter by Material',
                  options: _materialOptions,
                  initialIndex: selectedMaterialIndex < 0 ? 0 : selectedMaterialIndex,
                  onChanged: (index) {
                    setState(() {
                      _selectedMaterial = index == 0 ? null : _materialOptions[index];
                      if (_ctrl.selected != null &&
                          !_filteredRecipes.contains(_ctrl.selected)) {
                        _ctrl.select(_filteredRecipes.first);
                      }
                    });
                  },
                  r: r,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              // Recipe list — takes remaining space
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredRecipes.length,
                  itemBuilder: (context, i) {
                    final r = _filteredRecipes[i];
                    final selected = r.id == _ctrl.selected?.id;
                    return Card(
                      color: selected
                          ? AppColors.primaryLight.withValues(alpha: 0.15)
                          : null,
                      child: ListTile(
                        leading: Icon(
                          r.isLocked ? Icons.lock : Icons.science,
                          color: selected ? AppColors.primary : null,
                        ),
                        title: Text(r.name, style: AppTextStyles.bodyLarge),
                        subtitle: Text(
                          '${r.material}  •  ${r.tubeSize}  •  ${r.temperatureFormatted}  •  ${r.sealTimeFormatted}',
                          style: AppTextStyles.caption,
                        ),
                        selected: selected,
                        onTap: () => _ctrl.select(r),
                      ),
                    );
                  },
                ),
              ),
              // Details panel — natural height, no Expanded
              if (_ctrl.selected != null) ...[
                const SizedBox(height: AppSizes.sm),
                InfoCard(
                  title: AppStrings.recipeDetails,
                  icon: Icons.info_outline,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow('Name', _ctrl.selected!.name),
                      _DetailRow('Material', _ctrl.selected!.material),
                      _DetailRow('Tube Size', _ctrl.selected!.tubeSize),
                      _DetailRow('Temperature',
                          _ctrl.selected!.temperatureFormatted),
                      _DetailRow('Seal Time',
                          _ctrl.selected!.sealTimeFormatted),
                      _DetailRow('Locked',
                          _ctrl.selected!.isLocked ? 'Yes' : 'No'),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium),
          Text(value, style: AppTextStyles.bodyLarge),
        ],
      ),
    );
  }
}
