import 'package:flutter/material.dart';
import '../../../../app/constants/app_strings.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../app/widgets/info_card.dart';
import '../../../../core/models/recipe_model.dart';

class RecipeSummaryCard extends StatelessWidget {
  final RecipeModel? recipe;
  const RecipeSummaryCard({super.key, this.recipe});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: AppStrings.selectedRecipe,
      icon: Icons.science_outlined,
      child: recipe != null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe!.name, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 4),
                Text(
                  'Tube: ${recipe!.tubeSize}  •  '
                  '${recipe!.temperatureFormatted}  •  '
                  '${recipe!.sealTimeFormatted}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            )
          : Text(
              AppStrings.noRecipeSelected,
              style: AppTextStyles.bodyMedium,
            ),
    );
  }
}
