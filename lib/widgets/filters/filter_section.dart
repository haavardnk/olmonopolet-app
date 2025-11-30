import 'package:flutter/material.dart';

class FilterSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? resetLabel;
  final VoidCallback? onReset;
  final Widget child;
  final EdgeInsets padding;

  const FilterSection({
    super.key,
    required this.title,
    this.subtitle,
    this.resetLabel,
    this.onReset,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 6),
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    if (subtitle != null) ...[
                      const SizedBox(width: 6),
                      Text(subtitle!, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
              if (onReset != null && resetLabel != null)
                GestureDetector(
                  onTap: onReset,
                  child: Text(resetLabel!, style: TextStyle(fontSize: 12, color: colors.primary)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}
