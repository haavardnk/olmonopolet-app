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
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => ListFormDialog(existingList: list),
    );
    if (result == null) return false;

    await listsProvider.updateList(
      list.id,
      name: result['name'] as String,
      description: result['description'] as String,
      listType: result['listType'] as ListType,
      eventDate: result['eventDate'] as DateTime?,
    );
    return true;
  }

  static Future<bool> delete(
    BuildContext context,
    UserList list,
    ListsProvider listsProvider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Slett liste'),
        content: Text('Er du sikker på at du vil slette "${list.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Avbryt'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Slett'),
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
