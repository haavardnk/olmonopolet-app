import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';

class ProductOverviewReleaseSearchBar extends StatefulWidget {
  const ProductOverviewReleaseSearchBar({super.key});

  @override
  State<ProductOverviewReleaseSearchBar> createState() =>
      _ReleaseSearchBarState();
}

class _ReleaseSearchBarState extends State<ProductOverviewReleaseSearchBar> {
  TextEditingController _search = TextEditingController();
  late Filter filters;

  @override
  void initState() {
    filters = Provider.of<Filter>(context, listen: false);
    _search.text = filters.releaseSearch;
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
              filters.setReleaseSearch(textValue);
            });
          },
          decoration: InputDecoration(
            hintText: 'Søk i lansering',
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
                        filters.setReleaseSearch('');
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
