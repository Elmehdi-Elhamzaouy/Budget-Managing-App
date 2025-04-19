// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AISuggestionsCard extends StatelessWidget {
  final String insight;

  const AISuggestionsCard({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    // Get the current theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isDarkMode ? Colors.blue.shade700 : Colors.blue.shade100,
          width: 1.5,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isDarkMode
                    ? [
                      Colors.blue.shade900.withOpacity(0.3),
                      Colors.grey.shade900,
                      Colors.blue.shade900.withOpacity(0.2),
                    ]
                    : [
                      Colors.blue.shade50.withOpacity(0.9),
                      Colors.white,
                      Colors.blue.shade50.withOpacity(0.4),
                    ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDarkMode
                              ? [Colors.blue.shade700, Colors.blue.shade900]
                              : [Colors.blue.shade300, Colors.blue.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:
                            isDarkMode
                                ? Colors.black.withOpacity(0.3)
                                : Colors.blue.shade200.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Financial Tip',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color:
                              isDarkMode
                                  ? Colors.blue.shade100
                                  : Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 60,
                        decoration: BoxDecoration(
                          color:
                              isDarkMode
                                  ? Colors.blue.shade200
                                  : Colors.blue.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? Colors.grey.shade800.withOpacity(0.7)
                        : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDarkMode ? Colors.blue.shade700 : Colors.blue.shade100,
                ),
              ),
              child: Text(
                insight,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color:
                      isDarkMode ? Colors.grey.shade100 : Colors.grey.shade800,
                  height: 1.5,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color:
                      isDarkMode ? Colors.blue.shade200 : Colors.blue.shade400,
                ),
                const SizedBox(width: 8),
                Text(
                  'Powered by AI Gemini',
                  style: TextStyle(
                    color:
                        isDarkMode
                            ? Colors.blue.shade200
                            : Colors.blue.shade400,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
