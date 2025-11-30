import 'package:flutter/material.dart';

const _kBorderRadius = 10.0;
const _kDialogRadius = 16.0;
const _kDialogMaxWidth = 400.0;
const _kDialogMaxHeight = 500.0;

class MultiSelectDropdown<T> extends StatelessWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabel;
  final String? Function(T)? itemSubtitle;
  final Widget Function(T)? itemLeading;
  final String hintText;
  final String searchHint;
  final String Function(List<T>) selectedLabel;
  final Widget? Function(BuildContext, List<T>)? selectedDisplayBuilder;
  final ValueChanged<List<T>> onChanged;
  final Future<List<T>> Function()? asyncItems;
  final Widget? headerWidget;

  const MultiSelectDropdown({
    super.key,
    this.items = const [],
    required this.selectedItems,
    required this.itemLabel,
    this.itemSubtitle,
    this.itemLeading,
    required this.hintText,
    this.searchHint = 'Søk...',
    required this.selectedLabel,
    this.selectedDisplayBuilder,
    required this.onChanged,
    this.asyncItems,
    this.headerWidget,
  });

  @override
  Widget build(BuildContext context) {
    final customDisplay = selectedDisplayBuilder?.call(context, selectedItems);
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _showDialog(context),
      borderRadius: BorderRadius.circular(_kBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(_kBorderRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: customDisplay ??
                  Text(
                    selectedLabel(selectedItems),
                    style: TextStyle(
                      fontSize: 13,
                      color: selectedItems.isNotEmpty
                          ? colors.onSurface
                          : colors.onSurfaceVariant,
                    ),
                  ),
            ),
            Icon(Icons.expand_more, size: 20, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Future<void> _showDialog(BuildContext context) async {
    await showDialog<List<T>>(
      context: context,
      builder: (_) => _MultiSelectDialogContent<T>(
        items: items,
        selectedItems: selectedItems,
        itemLabel: itemLabel,
        itemSubtitle: itemSubtitle,
        itemLeading: itemLeading,
        searchHint: searchHint,
        asyncItems: asyncItems,
        headerWidget: headerWidget,
        onChanged: onChanged,
      ),
    );
  }
}

class _MultiSelectDialogContent<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;
  final String Function(T) itemLabel;
  final String? Function(T)? itemSubtitle;
  final Widget Function(T)? itemLeading;
  final String searchHint;
  final Future<List<T>> Function()? asyncItems;
  final Widget? headerWidget;
  final ValueChanged<List<T>> onChanged;

  const _MultiSelectDialogContent({
    required this.items,
    required this.selectedItems,
    required this.itemLabel,
    this.itemSubtitle,
    this.itemLeading,
    required this.searchHint,
    this.asyncItems,
    this.headerWidget,
    required this.onChanged,
  });

  @override
  State<_MultiSelectDialogContent<T>> createState() =>
      _MultiSelectDialogContentState<T>();
}

class _MultiSelectDialogContentState<T>
    extends State<_MultiSelectDialogContent<T>> {
  final _searchController = TextEditingController();
  var _searchQuery = '';
  late List<T> _items;
  late List<T> _selected;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _selected = List.from(widget.selectedItems);
    _isLoading = widget.asyncItems != null && _items.isEmpty;
    if (_isLoading) _loadAsyncItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadAsyncItems() {
    widget.asyncItems!().then((items) {
      if (mounted) setState(() { _items = items; _isLoading = false; });
    });
  }

  List<T> get _filteredItems => _searchQuery.isEmpty
      ? _items
      : _items.where((i) => widget.itemLabel(i).toLowerCase().contains(_searchQuery)).toList();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final filtered = _filteredItems;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kDialogRadius)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: _kDialogMaxWidth, maxHeight: _kDialogMaxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12).copyWith(left: 16, right: 16),
              child: Column(
                children: [
                  if (widget.headerWidget != null) ...[
                    widget.headerWidget!,
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Flexible(child: _buildList(filtered, colors)),
            Divider(height: 1, color: colors.outlineVariant),
            _buildFooter(filtered),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<T> items, ColorScheme colors) {
    if (_isLoading) {
      return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
    }
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('Ingen resultater funnet', style: TextStyle(color: colors.onSurfaceVariant)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final isSelected = _selected.contains(item);
        final subtitle = widget.itemSubtitle?.call(item);
        return ListTile(
          dense: true,
          leading: widget.itemLeading?.call(item),
          title: Text(widget.itemLabel(item)),
          subtitle: subtitle != null ? Text(subtitle) : null,
          trailing: isSelected ? Icon(Icons.check_circle, color: colors.primary) : null,
          onTap: () => setState(() => isSelected ? _selected.remove(item) : _selected.add(item)),
        );
      },
    );
  }

  Widget _buildFooter(List<T> filtered) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () => setState(() {
                for (var item in filtered) {
                  if (!_selected.contains(item)) _selected.add(item);
                }
              }),
              child: const Text('Velg alle'),
            )
          else if (_selected.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _selected.clear()),
              child: const Text('Nullstill'),
            ),
          const Spacer(),
          FilledButton(
            onPressed: () {
              widget.onChanged(_selected);
              Navigator.pop(context);
            },
            child: const Text('Ferdig'),
          ),
        ],
      ),
    );
  }
}

class SingleSelectDropdown<T> extends StatelessWidget {
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemLabel;
  final String hintText;
  final ValueChanged<T?> onChanged;

  const SingleSelectDropdown({
    super.key,
    required this.items,
    this.selectedItem,
    required this.itemLabel,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => _showDialog(context),
      borderRadius: BorderRadius.circular(_kBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.outline),
          borderRadius: BorderRadius.circular(_kBorderRadius),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedItem != null ? itemLabel(selectedItem as T) : hintText,
                style: TextStyle(
                  fontSize: 13,
                  color: selectedItem != null ? colors.onSurface : colors.onSurfaceVariant,
                ),
              ),
            ),
            Icon(Icons.expand_more, size: 20, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Future<void> _showDialog(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_kDialogRadius)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: _kDialogMaxWidth, maxHeight: 400),
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final item = items[i];
              final isSelected = item == selectedItem;
              return ListTile(
                dense: true,
                title: Text(itemLabel(item)),
                trailing: isSelected ? Icon(Icons.check_circle, color: colors.primary) : null,
                onTap: () {
                  onChanged(item);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
