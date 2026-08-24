import 'package:flutter/material.dart';

class BooksPerMonthChart extends StatelessWidget {
  const BooksPerMonthChart({required this.values, super.key});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    const labels = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A'];
    return Container(
      height: 196,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          values.length,
          (index) => Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: 22,
                    height: values[index] * 25,
                    decoration: BoxDecoration(
                      color: index == values.length - 1
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: .25),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(labels[index], style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
