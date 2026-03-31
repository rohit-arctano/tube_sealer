import 'package:flutter/material.dart';
import 'package:tube_sealer/core/models/recipe_model.dart';
import '../../../app/constants/app_sizes.dart';
import '../../../app/constants/app_strings.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../app/widgets/info_card.dart';
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
    return ListenableBuilder(
      listenable: _ctrl,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            children: [
              // Material filter dropdown
              DropdownButtonFormField<String?>(
                initialValue: _selectedMaterial,
                decoration: const InputDecoration(
                  labelText: 'Filter by Material',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Materials'),
                  ),
                  ..._materials.map((material) => DropdownMenuItem<String?>(
                        value: material,
                        child: Text(material),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedMaterial = value;
                    // Reset selection if filtered out
                    if (_ctrl.selected != null &&
                        !_filteredRecipes.contains(_ctrl.selected)) {
                      _ctrl.select( _filteredRecipes.first);
                    }
                  });
                },
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
