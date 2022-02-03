import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);
  static const routeName = '/about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Om Ølmonopolet',
          style: TextStyle(color: Theme.of(context).textTheme.headline6!.color),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme:
            Theme.of(context).appBarTheme.iconTheme, //change your color here
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Informasjon',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              "Ølmonopolet er en app som samler data fra Vinmonopolet og Untappd. "
              "På grunn av grenser på de respektive API'ene kan vi ikke levere sanntidsdata. "
              "I praksis betyr dette at vi har en egen server som kontinuerlig henter "
              "informasjon om øl, ratinger, checkins med mer.",
            ),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Data fra Vinmonopolet',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Data fra Vinmonopolet blir oppdatert en gang i døgnet. "
              "Det inkluderer informasjon om øl, utvalg og lagerstatus. "
              "Når på døgnet denne dataen blir oppdatert varierer og er spredt utover døgnet.",
            ),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Data fra Untappd',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Data fra Untappd blir oppdatert kontinuerlig gjennom hele døgnet. "
              "Dette gjøres fordi Untappd har en ganske lav API grense. "
              "Derfor blir øl oppdatert rullerende etter hvilken som ble oppdatert sist, "
              "med ekstra prioritet til nye øl og øl med få innsjekkinger. "
              "Når du først logger inn med Untappd vil alle dine checkins bli hentet av serveren. "
              "Dersom du har under 5000 innsjekkinger vil alle dine innsjekkinger bli hentet innen 10 minutt, "
              "ellers vil det ta noen timer. Etter dette blir alle nye innsjekkinger hentet en gang i døgnet.",
            ),
            const SizedBox(
              height: 16,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: const Text(
                'Vilkår',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Som du sikkert skjønner er denne applikasjonen 100% avhengig av ekstern data. "
              "Det vil si at dersom data tilgjengeligheten av en eller annen grunn skulle "
              "forsvinne fra en av de eksterne datakildene vil denne applikasjonen slutte å fungere.",
            ),
          ],
        ),
      ),
    );
  }
}
