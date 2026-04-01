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
  String? _selectedMaterial;

  List<String> get _materials =>
      _ctrl.recipes.map((recipe) => recipe.material).toSet().toList()..sort();

  List<String> get _materialOptions => ['All Materials', ..._materials];

  List<RecipeModel> get _filteredRecipes {
    if (_selectedMaterial == null) return _ctrl.recipes;
    return _ctrl.recipes.where((recipe) => recipe.material == _selectedMaterial).toList();
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
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final selectedMaterialIndex =
        _selectedMaterial == null ? 0 : _materialOptions.indexOf(_selectedMaterial!);

    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        final filteredRecipes = _filteredRecipes;
        RecipeModel? selectedRecipe;

        if (_ctrl.selected != null) {
          for (final recipe in filteredRecipes) {
            if (recipe.id == _ctrl.selected!.id) {
              selectedRecipe = recipe;
              break;
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(r.scaled(12)),
                decoration: BoxDecoration(
                  color: r.bgDark(),
                  borderRadius: BorderRadius.circular(r.scaled(AppSizes.cardRadius)),
                  border: Border.all(color: r.borderDark(), width: 2),
                ),
                child: SpinBox(
                  label: 'Filter by Material',
                  options: _materialOptions,
                  initialIndex: selectedMaterialIndex < 0 ? 0 : selectedMaterialIndex,
                  onChanged: (index) {
                    setState(() {
                      _selectedMaterial = index == 0 ? null : _materialOptions[index];
                      final nextFilteredRecipes = _filteredRecipes;
                      if (nextFilteredRecipes.isEmpty) return;

                      if (_ctrl.selected == null ||
                          !nextFilteredRecipes.any(
                            (recipe) => recipe.id == _ctrl.selected!.id,
                          )) {
                        _ctrl.select(nextFilteredRecipes.first);
                      }
                    });
                  },
                  r: r,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    if (filteredRecipes.isEmpty)
                      InfoCard(
                        title: 'No Recipes',
                        icon: Icons.search_off_rounded,
                        child: Text(
                          'No recipes match the selected material filter.',
                          style: AppTextStyles.bodyMedium,
                        ),
                      )
                    else
                      ...filteredRecipes.map((recipe) {
                        final selected = recipe.id == _ctrl.selected?.id;

                        return Card(
                          color: selected
                              ? (isDarkTheme
                                  ? AppColors.selectedSurface.withValues(alpha: 0.78)
                                  : AppColors.primaryLight.withValues(alpha: 0.15))
                              : null,
                          shadowColor: isDarkTheme ? AppColors.activeAccent : null,
                          child: ListTile(
                            leading: Icon(
                              recipe.isLocked ? Icons.lock : Icons.science,
                              color: selected
                                  ? (isDarkTheme ? AppColors.activeAccent : AppColors.primary)
                                  : (isDarkTheme ? AppColors.inactiveAccent : null),
                            ),
                            title: Text(recipe.name, style: AppTextStyles.bodyLarge),
                            subtitle: Text(
                              '${recipe.material} | ${recipe.tubeSize} | ${recipe.temperatureFormatted} | ${recipe.sealTimeFormatted}',
                              style: AppTextStyles.caption,
                            ),
                            selected: selected,
                            onTap: () => _ctrl.select(recipe),
                          ),
                        );
                      }),
                    if (selectedRecipe != null) ...[
                      const SizedBox(height: AppSizes.sm),
                      InfoCard(
                        title: AppStrings.recipeDetails,
                        icon: Icons.info_outline,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow('Name', selectedRecipe.name),
                            _DetailRow('Material', selectedRecipe.material),
                            _DetailRow('Tube Size', selectedRecipe.tubeSize),
                            _DetailRow('Temperature', selectedRecipe.temperatureFormatted),
                            _DetailRow('Seal Time', selectedRecipe.sealTimeFormatted),
                            _DetailRow('Locked', selectedRecipe.isLocked ? 'Yes' : 'No'),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Text(label, style: AppTextStyles.bodyMedium),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              softWrap: true,
              style: AppTextStyles.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}
