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
  final VoidCallback? onDelete;

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
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 60, // Reduced height as requested
          decoration: BoxDecoration(
            color: backgroundImagePath == null ? Colors.white : null,
            image: backgroundImagePath != null
                ? DecorationImage(
                    image: AssetImage(backgroundImagePath!),
                    fit: BoxFit.cover,
                    alignment: Alignment(0, imageAlignmentY ?? 0),
                  )
                : null,
          ),
          child: Stack(
            children: [
              if (backgroundImagePath != null)
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            time,
                            style: TextStyle(
                              color: backgroundImagePath == null ? Colors.black54 : Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '•',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: backgroundImagePath == null ? Colors.black87 : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize ?? 15,
                                shadows: backgroundImagePath == null 
                                  ? null 
                                  : const [Shadow(blurRadius: 2, color: Colors.black45)],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                      side: BorderSide(
                        color: backgroundImagePath == null ? Colors.grey : Colors.white70, 
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    if (onDelete != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: backgroundImagePath == null ? Colors.black54 : Colors.white,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onSelected: (value) {
                          if (value == 'delete') onDelete!();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Excluir', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
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
