import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/auth.dart';
import '../../providers/filter.dart';
import '../../providers/http_client.dart';
import '../../services/api.dart';
import '../../utils/exceptions.dart';
import 'barcode_scanner_sheet.dart';

class ProductOverviewSearchBar extends StatefulWidget {
  final bool isRelease;

  const ProductOverviewSearchBar({super.key, this.isRelease = false});

  @override
  State<ProductOverviewSearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<ProductOverviewSearchBar> {
  TextEditingController _search = TextEditingController();
  late Filter filters;
  bool _isScanning = false;

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

  Future<void> _onScan() async {
    if (_isScanning) return;

    final barcode = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerSheet()),
    );
    if (barcode == null || barcode.isEmpty || !mounted) return;

    setState(() => _isScanning = true);

    final client = Provider.of<HttpClient>(context, listen: false).apiClient;
    final auth = Provider.of<Auth>(context, listen: false);

    try {
      final token = auth.isSignedIn ? await auth.getIdToken() : null;
      final product = await ApiHelper.getProductByBarcode(
        client,
        barcode,
        token: token,
      );
      if (!mounted) return;
      context.push('/products/${product.id}', extra: product);
    } on NotFoundException {
      _showSnackBar('Fant ingen øl med denne strekkoden');
    } on NetworkException {
      _showSnackBar('Ingen internettforbindelse');
    } on ServerException {
      _showSnackBar('Strekkodesøk er midlertidig utilgjengelig');
    } on ApiException {
      _showSnackBar('Strekkodesøk feilet');
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final scanButton = _isScanning
        ? const Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        : IconButton(
            icon: Icon(Icons.qr_code_scanner, color: colors.onSurfaceVariant),
            tooltip: 'Skann strekkode',
            onPressed: _onScan,
          );

    return SizedBox(
      height: 40,
      child: Material(
        borderRadius: BorderRadius.circular(20),
        color: colors.surfaceContainerHighest,
        child: TextFormField(
          controller: _search,
          maxLines: 1,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(fontSize: 16),
          onChanged: _onChanged,
          decoration: InputDecoration(
            hintText: widget.isRelease ? 'Søk i lansering' : 'Søk',
            isDense: true,
            contentPadding: EdgeInsets.zero,
            prefixIcon: Icon(Icons.search, color: colors.onSurfaceVariant),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_search.text != '')
                  GestureDetector(
                    onTap: _onClear,
                    child: Icon(Icons.close, color: colors.onSurfaceVariant),
                  ),
                scanButton,
              ],
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
