import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/auth.dart';
import '../../providers/http_client.dart';
import '../../services/api.dart';

class TastedBadge extends StatefulWidget {
  final Product product;
  final ValueChanged<Product> onToggled;

  const TastedBadge({
    required this.product,
    required this.onToggled,
    super.key,
  });

  @override
  State<TastedBadge> createState() => _TastedBadgeState();
}

class _TastedBadgeState extends State<TastedBadge> {
  bool _loading = false;

  Future<void> _toggle() async {
    if (_loading) return;
    final auth = Provider.of<Auth>(context, listen: false);
    if (!auth.isSignedIn) return;
    final token = await auth.getIdToken();
    if (token == null) return;
    final client = Provider.of<HttpClient>(context, listen: false).apiClient;
    setState(() => _loading = true);
    try {
      if (widget.product.userTasted) {
        await ApiHelper.unmarkTasted(client, widget.product.id, token);
      } else {
        await ApiHelper.markTasted(client, widget.product.id, token);
      }
      widget.onToggled(
        widget.product.copyWith(userTasted: !widget.product.userTasted),
      );
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    if (!auth.isSignedIn) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final tasted = widget.product.userTasted;

    return Positioned(
      top: 0,
      left: 0,
      child: GestureDetector(
        onTap: _toggle,
        child: Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: tasted
                ? colors.primary
                : colors.surfaceContainerHighest.withValues(alpha: 0.85),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8.r),
              bottomRight: Radius.circular(8.r),
            ),
          ),
          child: _loading
              ? SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: tasted ? colors.onPrimary : colors.onSurfaceVariant,
                  ),
                )
              : Icon(
                  tasted ? Icons.check : Icons.check_circle_outline,
                  size: 18.r,
                  color: tasted ? colors.onPrimary : colors.onSurfaceVariant,
                ),
        ),
      ),
    );
  }
}
