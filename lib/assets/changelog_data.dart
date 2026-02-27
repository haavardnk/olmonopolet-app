import 'package:flutter/material.dart';

import '../models/changelog.dart';

const List<ChangelogVersion> changelogVersions = [
  ChangelogVersion(
    version: '3.0.1',
    title: 'Hva er nytt?',
    entries: [
      ChangelogEntry(
        icon: Icons.person_outline,
        title: 'Logg inn med konto',
        description:
            'Du kan nå logge inn med Google, Apple eller e-post. '
            'Åpne menyen og trykk «Logg inn» for å komme i gang.',
      ),
      ChangelogEntry(
        icon: Icons.check_circle_outline,
        title: 'Marker øl som smakt',
        description:
            'Trykk på haken på produktkortet eller i produktdetaljer for å markere en øl som smakt. '
            'Filtrer på smakt/ikke smakt i filterpanelet.',
      ),
      ChangelogEntry(
        icon: Icons.upload_file_outlined,
        title: 'Importer Untappd-data',
        description:
            'Importer Untappd CSV- eller JSON-eksport under Untappd-seksjonen i profilen din.',
      ),
      ChangelogEntry(
        icon: Icons.rss_feed,
        title: 'Untappd RSS-synkronisering',
        description:
            'Koble Untappd-kontoen din via RSS for å synkronisere de siste innsjekkingene dine. '
            'Sett det opp under Untappd-seksjonen i profilen din.',
      ),
      ChangelogEntry(
        icon: Icons.list_alt,
        title: 'Egendefinerte lister',
        description:
            'Opprett flere lister med ulike typer: standard, handleliste, kjeller og arrangement. '
            'Listene synkroniseres med kontoen din og kan deles via lenke.',
      ),
      ChangelogEntry(
        icon: Icons.link,
        title: 'Dyplinking',
        description:
            'Lenker til produkter, slipp og delte lister åpner nå direkte i appen.',
      ),
      ChangelogEntry(
        icon: Icons.share_outlined,
        title: 'Deling',
        description:
            'Del produkter, ølslipp og lister med venner direkte fra appen.',
      ),
      ChangelogEntry(
        icon: Icons.local_drink_outlined,
        title: 'Kategorifilter',
        description: 'Filtrer produkter etter kategori: Øl, Mjød eller Sider.',
      ),
    ],
  ),
];
