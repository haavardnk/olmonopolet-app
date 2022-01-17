import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _search = TextEditingController();
  late Filter filters;

  @override
  void initState() {
    filters = Provider.of<Filter>(context, listen: false);
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: Colors.grey[100]!,
          width: 1.0,
        )),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      height: kToolbarHeight,
      child: TextFormField(
        controller: _search,
        textAlignVertical: TextAlignVertical.bottom,
        maxLines: 1,
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        onChanged: (textValue) {
          setState(() {
            filters.setSearch(textValue);
          });
        },
        decoration: InputDecoration(
          fillColor: Colors.grey[100],
          filled: true,
          hintText: 'Søk',
          prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
          suffixIcon: (_search.text == '')
              ? null
              : GestureDetector(
                  onTap: () {
                    setState(() {
                      _search = TextEditingController(text: '');
                      filters.setSearch('');
                    });
                  },
                  child: Icon(Icons.close, color: Colors.grey[500])),
          focusedBorder: UnderlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              borderSide: BorderSide(color: Colors.grey[200]!)),
          enabledBorder: UnderlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
        ),
      ),
    );
  }
}
