import 'package:flutter/material.dart';

class ChangelogEntry {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const ChangelogEntry({
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });
}

class ChangelogVersion {
  final String version;
  final String title;
  final List<ChangelogEntry> entries;

  const ChangelogVersion({
    required this.version,
    required this.title,
    required this.entries,
  });
}
