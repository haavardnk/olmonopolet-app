import 'package:flutter/material.dart';

import '../models/changelog.dart';

const List<ChangelogVersion> changelogVersions = [
  ChangelogVersion(
    version: '2.3.0',
    title: 'Hva er nytt?',
    entries: [
      ChangelogEntry(
        icon: Icons.person_outline,
        title: 'Logg inn med konto',
        description: 'Du kan nå logge inn med Google, Apple eller e-post. '
            'Åpne menyen og trykk «Logg inn» for å komme i gang.',
      ),
      ChangelogEntry(
        icon: Icons.check_circle_outline,
        title: 'Marker øl som smakt',
        description:
            'Trykk på haken på produktkortet eller i produktdetaljer for å markere en øl som smakt. '
            'Filtrer på smakt/ikke smakt i filterpanelet.',
      ),
    ],
  ),
];
