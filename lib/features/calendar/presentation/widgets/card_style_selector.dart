import 'package:flutter/material.dart';
import 'package:love_routine_app/config/card_styles.dart';

class CardStyleSelector extends StatelessWidget {
  final String? selectedStyle;
  final ValueChanged<String> onStyleSelected;

  const CardStyleSelector({
    super.key,
    required this.selectedStyle,
    required this.onStyleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estilo do Card',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: CardStyles.styles.entries.map((entry) {
                final key = entry.key;
                final asset = entry.value;
                final isSelected =
                    selectedStyle == key ||
                    (selectedStyle == null && key == 'default');

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => onStyleSelected(key),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 3,
                              )
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              asset,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: _getColorForStyle(key),
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white54,
                                  ),
                                );
                              },
                            ),
                            if (isSelected)
                              Center(
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  child: const Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Color _getColorForStyle(String key) {
    switch (key) {
      case 'coffee':
        return Colors.brown;
      case 'gym':
        return Colors.red;
      case 'shopping':
        return Colors.purple;
      case 'work':
        return Colors.blueGrey;
      case 'bills':
        return Colors.green;
      case 'nature':
        return Colors.lightGreen;
      case 'abstract':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}
