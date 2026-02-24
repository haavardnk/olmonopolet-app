import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/product.dart';
import '../../providers/http_client.dart';
import '../../services/app_launcher.dart';
import './untappd_match_sheet.dart';

class ProductActionMenu extends StatelessWidget {
  final Product product;
  final bool compact;

  const ProductActionMenu({
    super.key,
    required this.product,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopupMenuButton<int>(
      padding: compact ? EdgeInsets.zero : const EdgeInsets.all(8),
      constraints: compact ? const BoxConstraints() : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: compact
          ? Container(
              padding: EdgeInsets.all(5.r),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.more_horiz,
                size: 16.r,
                color: colors.onSurfaceVariant,
              ),
            )
          : null,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              const Icon(Icons.report_outlined),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  product.rating != null
                      ? 'Rapporter feil Untappd match'
                      : 'Foreslå untappd match',
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              const Icon(Icons.sports_bar_outlined),
              SizedBox(width: 12.w),
              const Text('Åpne i Untappd'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              const Icon(Icons.open_in_browser),
              SizedBox(width: 12.w),
              const Text('Åpne i Vinmonopolet'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 0) {
          final client =
              Provider.of<HttpClient>(context, listen: false).apiClient;
          UntappdMatchSheet.show(context, client, product.id);
        } else if (value == 1) {
          AppLauncher.launchUntappd(product);
        } else if (value == 2 && product.vmpUrl != null) {
          launchUrl(Uri.parse(product.vmpUrl!));
        }
      },
    );
  }
}
