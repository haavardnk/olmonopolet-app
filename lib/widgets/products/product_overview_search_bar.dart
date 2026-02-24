import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/filter.dart';

class ProductOverviewSearchBar extends StatefulWidget {
  final bool isRelease;

  const ProductOverviewSearchBar({super.key, this.isRelease = false});

  @override
  State<ProductOverviewSearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<ProductOverviewSearchBar> {
  TextEditingController _search = TextEditingController();
  late Filter filters;

  @override
  void initState() {
    filters = Provider.of<Filter>(context, listen: false);
    _search.text = widget.isRelease ? filters.releaseSearch : filters.search;
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    setState(() {
      if (widget.isRelease) {
        filters.setReleaseSearch(text);
      } else {
        filters.setSearch(text);
      }
    });
  }

  void _onClear() {
    setState(() {
      _search = TextEditingController(text: '');
      if (widget.isRelease) {
        filters.setReleaseSearch('');
      } else {
        filters.setSearch('');
      }
    });
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
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: widget.isRelease ? 'Søk i lansering' : 'Søk',
            isDense: true,
            contentPadding: EdgeInsets.zero,
            prefixIcon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            suffixIcon: (_search.text == '')
                ? null
                : GestureDetector(
                    onTap: _onClear,
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
