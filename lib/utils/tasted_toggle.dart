import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/http_client.dart';
import '../services/api.dart';
import '../models/product.dart';
import '../utils/crash_reporter.dart';

Future<Product?> toggleTasted(BuildContext context, Product product) async {
  final auth = Provider.of<Auth>(context, listen: false);
  if (!auth.isSignedIn) return null;
  final token = await auth.getIdToken();
  if (token == null) return null;
  final http.Client client =
      Provider.of<HttpClient>(context, listen: false).apiClient;
  try {
    if (product.userTasted) {
      await ApiHelper.unmarkTasted(client, product.id, token);
    } else {
      await ApiHelper.markTasted(client, product.id, token);
    }
    return product.copyWith(userTasted: !product.userTasted);
  } catch (e, st) {
    CrashReporter.recordError(e, st, reason: 'toggleTasted failed');
    rethrow;
  }
}
