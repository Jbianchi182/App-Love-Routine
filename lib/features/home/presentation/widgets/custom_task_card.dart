import 'dart:ui';
import 'package:flutter/material.dart';

class CustomTaskCard extends StatelessWidget {
  final String title;
  final String time;
  final String? backgroundImagePath;
  final bool isCompleted;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckboxChanged;

  final double? imageAlignmentY;
  final double? fontSize;

  const CustomTaskCard({
    super.key,
    required this.title,
    required this.time,
    this.backgroundImagePath,
    this.isCompleted = false,
    this.onTap,
    this.onCheckboxChanged,
    this.imageAlignmentY,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 100, // Compact height
          decoration: BoxDecoration(
            image: backgroundImagePath != null
                ? DecorationImage(
                    image: AssetImage(backgroundImagePath!),
                    fit: BoxFit.cover,
                    alignment: Alignment(
                      0,
                      imageAlignmentY ?? 0,
                    ), // User alignment
                  )
                : const DecorationImage(
                    image: NetworkImage('https://via.placeholder.com/400x200'),
                    fit: BoxFit.cover,
                  ),
            gradient: backgroundImagePath == null
                ? LinearGradient(
                    colors: [Colors.purple.shade200, Colors.blue.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Stack(
            children: [
              // gradient overlay for text readability
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize ?? 16,
                              shadows: const [
                                Shadow(blurRadius: 2, color: Colors.black45),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            time,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: isCompleted,
                      onChanged: onCheckboxChanged,
                      activeColor: Theme.of(context).colorScheme.primary,
                      checkColor: Colors.white,
                      side: const BorderSide(color: Colors.white70, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
