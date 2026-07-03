import 'package:flutter/material.dart';

import '../models/changelog.dart';

const List<ChangelogVersion> changelogVersions = [
  ChangelogVersion(
    version: '3.2.0',
    title: 'Hva er nytt?',
    entries: [
      ChangelogEntry(
        icon: Icons.qr_code_scanner_outlined,
        title: 'Strekkodeskanner',
        description:
            'Skann strekkoden på et produkt for å finne ølet raskere i appen.',
      ),
    ],
  ),
  ChangelogVersion(
    version: '3.1.1',
    title: 'Hva er nytt?',
    entries: [
      ChangelogEntry(
        icon: Icons.group_outlined,
        title: 'Følg andres lister',
        description:
            'Abonner på delte lister fra andre brukere. '
            'Åpne en delt lenke og følg listen for å ha den tilgjengelig.',
      ),
      ChangelogEntry(
        icon: Icons.tune_outlined,
        title: 'Mer listefleksibilitet',
        description:
            'Tilpass hver liste akkurat slik du vil – velg hvilke felter som vises, '
            'eller bruk en av forhåndsinnstillingene som utgangspunkt.',
      ),
    ],
  ),
  ChangelogVersion(
    version: '3.1.0',
    title: 'Hva er nytt?',
    entries: [
      ChangelogEntry(
        icon: Icons.repeat_outlined,
        title: 'Abonner på Untappd-lister',
        description:
            'Abonner på offentlige Untappd-lister for å få dem synkronisert automatisk. '
            'Importer via Untappd-seksjonen under lister.',
      ),
      ChangelogEntry(
        icon: Icons.trending_up,
        title: 'Sorter etter verdi for pengene',
        description:
            'Ny sortering basert på vurdering og literpris. '
            'Verdiscoren vises også på produktkortet.',
      ),
    ],
  ),
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
