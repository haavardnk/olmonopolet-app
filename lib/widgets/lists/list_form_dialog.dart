import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../models/user_list.dart';

class ListFormDialog extends StatefulWidget {
  final UserList? existingList;

  const ListFormDialog({super.key, this.existingList});

  @override
  State<ListFormDialog> createState() => _ListFormDialogState();
}

class _ListFormDialogState extends State<ListFormDialog> {
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isEditing = widget.existingList != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400.w),
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isEditing ? 'Rediger liste' : 'Ny liste',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 20.h),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Navn',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Navn er påkrevd';
                    }
                    return null;
                  },
                  autofocus: true,
                ),
                SizedBox(height: 12.h),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Beskrivelse (valgfritt)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Type',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildTypeGrid(colors),
                if (_selectedType == ListType.event) ...[
                  SizedBox(height: 12.h),
                  _buildDatePicker(context, colors),
                ],
                SizedBox(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Avbryt'),
                    ),
                    SizedBox(width: 8.w),
                    FilledButton(
                      onPressed: _submit,
                      child: Text(isEditing ? 'Lagre' : 'Opprett'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeGrid(ColorScheme colors) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8.h,
      crossAxisSpacing: 8.w,
      childAspectRatio: 2.5,
      children: ListType.values.map((type) {
        final isSelected = _selectedType == type;
        return _buildTypeOption(type, isSelected, colors);
      }).toList(),
    );
  }

  Widget _buildTypeOption(ListType type, bool isSelected, ColorScheme colors) {
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? colors.primaryContainer : colors.surfaceContainer,
          borderRadius: BorderRadius.circular(10.r),
          border: isSelected
              ? Border.all(color: colors.primary, width: 2)
              : Border.all(color: colors.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type.icon,
              size: 18.r,
              color: isSelected
                  ? colors.onPrimaryContainer
                  : colors.onSurfaceVariant,
            ),
            SizedBox(width: 6.w),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 12.sp,
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

  Widget _buildDatePicker(BuildContext context, ColorScheme colors) {
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
          border: Border.all(color: colors.outline),
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
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'listType': _selectedType,
      'eventDate': _eventDate,
    });
  }
}
