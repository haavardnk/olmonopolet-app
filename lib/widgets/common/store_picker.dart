import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/store.dart';

final _clearSentinel = Store(id: '', name: '');

Future<Store?> showStorePicker(
  BuildContext context, {
  required List<Store> stores,
  String? selectedStoreId,
  bool allowClear = false,
}) async {
  return showModalBottomSheet<Store?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.3,
      expand: false,
      builder: (_, controller) => _StorePickerContent(
        stores: stores,
        selectedStoreId: selectedStoreId,
        scrollController: controller,
        allowClear: allowClear,
      ),
    ),
  );
}

class _StorePickerContent extends StatefulWidget {
  final List<Store> stores;
  final String? selectedStoreId;
  final ScrollController scrollController;
  final bool allowClear;

  const _StorePickerContent({
    required this.stores,
    required this.selectedStoreId,
    required this.scrollController,
    required this.allowClear,
  });

  @override
  State<_StorePickerContent> createState() => _StorePickerContentState();
}

class _StorePickerContentState extends State<_StorePickerContent> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Store> get _filtered => _query.isEmpty
      ? widget.stores
      : widget.stores
          .where((s) => s.name.toLowerCase().contains(_query))
          .toList();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final stores = _filtered;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 12.h),
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: colors.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
          child: Text(
            'Velg butikk',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Søk etter butikk...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
            ),
            onChanged: (v) => setState(() => _query = v.toLowerCase()),
          ),
        ),
        SizedBox(height: 8.h),
        if (widget.allowClear && widget.selectedStoreId != null)
          ListTile(
            leading: const Icon(Icons.clear),
            title: const Text('Fjern butikkvalg'),
            onTap: () => Navigator.pop(context, _clearSentinel),
          ),
        Expanded(
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: stores.length,
            itemBuilder: (_, index) {
              final store = stores[index];
              final isSelected = store.id == widget.selectedStoreId;
              return ListTile(
                leading: isSelected
                    ? Icon(Icons.check_circle, color: colors.primary)
                    : const Icon(Icons.store_outlined),
                title: Text(store.name),
                subtitle: store.distance != null
                    ? Text(
                        '${store.distance!.toStringAsFixed(1)} km',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colors.onSurfaceVariant,
                        ),
                      )
                    : null,
                selected: isSelected,
                onTap: () => Navigator.pop(context, store),
              );
            },
          ),
        ),
      ],
    );
  }
}
