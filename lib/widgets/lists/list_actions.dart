import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/user_list.dart';
import '../../providers/lists.dart';
import '../../utils/environment.dart';
import '../lists/list_form_dialog.dart';

class ListActions {
  static Future<bool> edit(
    BuildContext context,
    UserList list,
    ListsProvider listsProvider,
  ) async {
    final result = await showListFormSheet(context, existingList: list);
    if (result == null) return false;

    final clearDate = result['clearEventDate'] as bool? ?? false;

    await listsProvider.updateList(
      list.id,
      name: result['name'] as String,
      description: result['description'] as String,
      showQuantity: result['showQuantity'] as bool,
      showStore: result['showStore'] as bool,
      showVintage: result['showVintage'] as bool,
      showPrices: result['showPrices'] as bool,
      showNotes: result['showNotes'] as bool,
      eventDate: result['eventDate'] as DateTime?,
      clearEventDate: clearDate,
    );
    return true;
  }

  static Future<bool> delete(
    BuildContext context,
    UserList list,
    ListsProvider listsProvider,
  ) async {
    final isUntappd = list.isUntappd;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isUntappd ? 'Avslutt abonnement' : 'Slett liste'),
        content: Text(
          isUntappd
              ? 'Er du sikker på at du vil avslutte abonnementet på "${list.name}"?'
              : 'Er du sikker på at du vil slette "${list.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isUntappd ? 'Avslutt abonnement' : 'Slett'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    return listsProvider.deleteList(list.id);
  }

  static void share(UserList list) {
    final url = '${Environment.appBaseUrl}/lists/shared/${list.shareToken}';
    SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
  }
}
