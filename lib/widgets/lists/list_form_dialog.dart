import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/user_list.dart';
import '../../models/list_preset.dart';
import '../common/drag_handle.dart';

Future<Map<String, dynamic>?> showListFormSheet(
  BuildContext context, {
  UserList? existingList,
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (_) => _ListFormSheet(existingList: existingList),
  );
}

class _ListFormSheet extends StatefulWidget {
  final UserList? existingList;

  const _ListFormSheet({this.existingList});

  @override
  State<_ListFormSheet> createState() => _ListFormSheetState();
}

class _ListFormSheetState extends State<_ListFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late bool _showQuantity;
  late bool _showStore;
  late bool _showVintage;
  late bool _showPrices;
  DateTime? _eventDate;
  bool _customExpanded = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingList?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingList?.description ?? '');
    _showQuantity = widget.existingList?.showQuantity ?? false;
    _showStore = widget.existingList?.showStore ?? false;
    _showVintage = widget.existingList?.showVintage ?? false;
    _showPrices = widget.existingList?.showPrices ?? true;
    _eventDate = widget.existingList?.eventDate;

    if (_isEditing) {
      final matched = matchPreset(
        showQuantity: _showQuantity,
        showStore: _showStore,
        showVintage: _showVintage,
        showPrices: _showPrices,
      );
      if (matched == null) _customExpanded = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingList != null;

  String? get _activePresetId {
    final matched = matchPreset(
      showQuantity: _showQuantity,
      showStore: _showStore,
      showVintage: _showVintage,
      showPrices: _showPrices,
    );
    return matched?.id;
  }

  void _applyPreset(ListPreset preset) {
    setState(() {
      _showQuantity = preset.showQuantity;
      _showStore = preset.showStore;
      _showVintage = preset.showVintage;
      _showPrices = preset.showPrices;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const DragHandle(topMargin: true),
              _buildHeader(colors),
              _buildForm(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _isEditing ? Icons.edit_outlined : Icons.playlist_add,
              color: colors.onPrimaryContainer,
              size: 24.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Rediger liste' : 'Ny liste',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  _isEditing
                      ? 'Endre navn, innstillinger eller beskrivelse'
                      : 'Opprett en ny liste',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(ColorScheme colors) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              style: TextStyle(fontSize: 14.sp),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Navn på listen',
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.label_outline,
                  color: colors.onSurfaceVariant,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Navn er påkrevd';
                }
                return null;
              },
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(fontSize: 14.sp),
              maxLines: 2,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Beskrivelse (valgfritt)',
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Icon(
                    Icons.notes_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Type',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8.h),
            _buildPresetRow(colors),
            SizedBox(height: 8.h),
            _buildCustomSection(colors),
            SizedBox(height: 12.h),
            _buildDatePicker(colors),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  _isEditing ? 'Lagre endringer' : 'Opprett liste',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetRow(ColorScheme colors) {
    return Row(
      children: listPresets.map((preset) {
        final isSelected = _activePresetId == preset.id;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: _buildPresetChip(preset, isSelected, colors),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPresetChip(ListPreset preset, bool isSelected, ColorScheme colors) {
    return GestureDetector(
      onTap: () => _applyPreset(preset),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryContainer
              : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10.r),
          border: isSelected
              ? Border.all(color: colors.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              preset.icon,
              size: 20.r,
              color: isSelected
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
            ),
            SizedBox(height: 4.h),
            Text(
              preset.label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomSection(ColorScheme colors) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _customExpanded = !_customExpanded),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.tune,
                  size: 18.r,
                  color: colors.onSurfaceVariant,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Tilpass',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  _customExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  size: 20.r,
                  color: colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (_customExpanded) ...[
          SizedBox(height: 8.h),
          _buildToggle(
            colors,
            label: 'Vis antall',
            icon: Icons.numbers,
            value: _showQuantity,
            onChanged: (v) => setState(() => _showQuantity = v),
          ),
          _buildToggle(
            colors,
            label: 'Vis butikkstatus',
            icon: Icons.storefront_outlined,
            value: _showStore,
            onChanged: (v) => setState(() => _showStore = v),
          ),
          _buildToggle(
            colors,
            label: 'Vis årgang',
            icon: Icons.calendar_today_outlined,
            value: _showVintage,
            onChanged: (v) => setState(() => _showVintage = v),
          ),
          _buildToggle(
            colors,
            label: 'Vis priser',
            icon: Icons.payments_outlined,
            value: _showPrices,
            onChanged: (v) => setState(() => _showPrices = v),
          ),
        ],
      ],
    );
  }

  Widget _buildToggle(
    ColorScheme colors, {
    required String label,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          SizedBox(width: 4.w),
          Icon(icon, size: 18.r, color: colors.onSurfaceVariant),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
          SizedBox(
            height: 32.h,
            child: Switch(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      setState(() => _eventDate = picked);
    }
  }

  Widget _buildDatePicker(ColorScheme colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        color: colors.surfaceContainerHighest,
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickDate,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 18.r, color: colors.onSurfaceVariant),
                      SizedBox(width: 10.w),
                      Text(
                        _eventDate != null
                            ? '${_eventDate!.day}.${_eventDate!.month}.${_eventDate!.year}'
                            : 'Arrangementdato (valgfritt)',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _eventDate != null
                              ? colors.onSurface
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_eventDate != null)
              IconButton(
                icon: Icon(Icons.close, size: 18.r),
                color: colors.onSurfaceVariant,
                visualDensity: VisualDensity.compact,
                tooltip: 'Fjern dato',
                onPressed: () => setState(() => _eventDate = null),
              ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'showQuantity': _showQuantity,
      'showStore': _showStore,
      'showVintage': _showVintage,
      'showPrices': _showPrices,
      'eventDate': _eventDate,
      'clearEventDate': _isEditing && widget.existingList?.eventDate != null && _eventDate == null,
    });
  }
}
