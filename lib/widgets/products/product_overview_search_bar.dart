import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';

class ProductOverviewSearchBar extends StatefulWidget {
  const ProductOverviewSearchBar({super.key});

  @override
  State<ProductOverviewSearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<ProductOverviewSearchBar> {
  TextEditingController _search = TextEditingController();
  late Filter filters;

  @override
  void initState() {
    filters = Provider.of<Filter>(context, listen: false);
    _search.text = filters.search;
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: TextFormField(
          controller: _search,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            fontSize: 16,
          ),
          onChanged: (textValue) {
            setState(() {
              filters.setSearch(textValue);
            });
          },
          decoration: InputDecoration(
            hintText: 'Søk',
            isDense: true,
            contentPadding: EdgeInsets.zero,
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            suffixIcon: (_search.text == '')
                ? null
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _search = TextEditingController(text: '');
                        filters.setSearch('');
                      });
                    },
                    child: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
