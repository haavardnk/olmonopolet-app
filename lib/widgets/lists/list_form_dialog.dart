import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/user_list.dart';
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
  late ListType _selectedType;
  DateTime? _eventDate;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.existingList?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.existingList?.description ?? '');
    _selectedType = widget.existingList?.listType ?? ListType.standard;
    _eventDate = widget.existingList?.eventDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool get _isEditing => widget.existingList != null;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DragHandle(topMargin: true),
            _buildHeader(colors),
            _buildForm(colors),
          ],
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
                      ? 'Endre navn, type eller beskrivelse'
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
            _buildTypeRow(colors),
            if (_selectedType == ListType.event) ...[
              SizedBox(height: 12.h),
              _buildDatePicker(colors),
            ],
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

  Widget _buildTypeRow(ColorScheme colors) {
    return Row(
      children: ListType.values.map((type) {
        final isSelected = _selectedType == type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.w),
            child: _buildTypeChip(type, isSelected, colors),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeChip(ListType type, bool isSelected, ColorScheme colors) {
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
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
              type.icon,
              size: 20.r,
              color: isSelected
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
            ),
            SizedBox(height: 4.h),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(ColorScheme colors) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _eventDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() => _eventDate = picked);
        }
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: 18.r, color: colors.onSurfaceVariant),
            SizedBox(width: 10.w),
            Text(
              _eventDate != null
                  ? '${_eventDate!.day}.${_eventDate!.month}.${_eventDate!.year}'
                  : 'Velg dato',
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
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop({
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'listType': _selectedType,
      'eventDate': _eventDate,
    });
  }
}
