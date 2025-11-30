import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;

import '../../services/api.dart';

class UntappdMatchSheet extends StatefulWidget {
  final http.Client client;
  final int productId;

  const UntappdMatchSheet({
    super.key,
    required this.client,
    required this.productId,
  });

  static void show(BuildContext context, http.Client client, int productId) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => UntappdMatchSheet(
        client: client,
        productId: productId,
      ),
    );
  }

  @override
  State<UntappdMatchSheet> createState() => _UntappdMatchSheetState();
}

class _UntappdMatchSheetState extends State<UntappdMatchSheet> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_urlController.text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await ApiHelper.submitUntappdMatch(
        widget.client,
        widget.productId,
        _urlController.text,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Takk! Forslaget ditt er sendt inn.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Kunne ikke sende forslag. Prøv igjen senere.',
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(colors),
          _buildHeader(colors),
          _buildForm(colors),
        ],
      ),
    );
  }

  Widget _buildHandle(ColorScheme colors) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: colors.onSurfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(2.r),
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
              Icons.link,
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
                  'Foreslå Untappd-match',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Lim inn lenke til riktig øl',
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
          children: [
            TextFormField(
              autocorrect: false,
              autofocus: true,
              controller: _urlController,
              keyboardType: TextInputType.url,
              style: TextStyle(fontSize: 14.sp),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vennligst skriv inn Untappd link';
                }
                if (!value.contains('https://untappd.com/b/') &&
                    !value.contains('https://untp.beer/')) {
                  return 'Ugyldig Untappd link';
                }
                return null;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                hintText: 'https://untappd.com/b/...',
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.sports_bar_outlined,
                  color: colors.onSurfaceVariant,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onPrimary,
                        ),
                      )
                    : Text(
                        'Send inn forslag',
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
}
