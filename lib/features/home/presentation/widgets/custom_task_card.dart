import 'dart:ui';
import 'package:flutter/material.dart';

class CustomTaskCard extends StatelessWidget {
  final String title;
  final String time;
  final String? backgroundImagePath;
  final bool isCompleted;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onCheckboxChanged;

  const CustomTaskCard({
    super.key,
    required this.title,
    required this.time,
    this.backgroundImagePath,
    this.isCompleted = false,
    this.onTap,
    this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            image: backgroundImagePath != null
                ? DecorationImage(
                    image: AssetImage(
                      backgroundImagePath!,
                    ), // Ensure asset exists or handle error
                    fit: BoxFit.cover,
                  )
                : const DecorationImage(
                    image: NetworkImage(
                      'https://via.placeholder.com/400x200',
                    ), // Fallback
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
              // Glassmorphism Content Area
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      color: Colors.black.withOpacity(
                        0.3,
                      ), // Semi-transparent dark overlay
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                            activeColor: Colors.white,
                            checkColor: Colors.black,
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
