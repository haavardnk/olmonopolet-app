import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as p;

import 'package:url_launcher/url_launcher.dart';

import '../models/user_list.dart';
import '../providers/auth.dart';
import '../providers/lists.dart';
import '../utils/environment.dart';
import '../widgets/drawer/app_drawer.dart';
import '../widgets/lists/list_card.dart';
import '../widgets/lists/list_form_dialog.dart';
import '../widgets/lists/list_actions.dart';
import '../utils/crash_reporter.dart';

class ListsTab extends StatefulWidget {
  const ListsTab({super.key});

  @override
  State<ListsTab> createState() => _ListsTabState();
}

class _ListsTabState extends State<ListsTab> with WidgetsBindingObserver {
  int _localCartCount = 0;
  bool? _wasAuthenticated;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      final auth = Provider.of<Auth>(context, listen: false);
      if (auth.isSignedIn) {
        Provider.of<ListsProvider>(context, listen: false).fetchLists();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isNowAuthenticated = Provider.of<Auth>(context).isSignedIn;
    if (_wasAuthenticated == isNowAuthenticated) return;
    _wasAuthenticated = isNowAuthenticated;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isNowAuthenticated) {
        _onSignedIn();
      } else {
        _onSignedOut();
      }
    });
  }

  Future<void> _onSignedIn() async {
    if (!mounted) return;
    final listsProvider = Provider.of<ListsProvider>(context, listen: false);
    if (!listsProvider.listsLoaded) {
      await listsProvider.fetchLists();
    }
    if (mounted) {
      await listsProvider.migrateCartIfNeeded();
    }
    if (mounted) setState(() => _localCartCount = 0);
  }

  Future<void> _onSignedOut() async {
    if (!mounted) return;
    await _checkLocalCart();
  }

  Future<void> _checkLocalCart() async {
    try {
      final dbPath = await sql.getDatabasesPath();
      final cartDbPath = p.join(dbPath, 'cart.db');
      if (!await sql.databaseExists(cartDbPath)) {
        if (mounted) setState(() => _localCartCount = 0);
        return;
      }
      final db = await sql.openDatabase(cartDbPath);
      final rows = await db.query('cart');
      await db.close();
      if (mounted) setState(() => _localCartCount = rows.length);
    } catch (e, st) {
      CrashReporter.recordError(e, st);
      if (mounted) setState(() => _localCartCount = 0);
    }
  }

  void _showAddMenu() {
    final colors = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    size: 20.r,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  'Ny liste',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Opprett en handleliste, lagerliste eller annet',
                  style: TextStyle(fontSize: 12.sp, color: colors.onSurfaceVariant),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _createList();
                },
              ),
              SizedBox(height: 4.h),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_download_outlined,
                    size: 20.r,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  'Importer fra Untappd',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Abonner på en Untappd-liste',
                  style: TextStyle(fontSize: 12.sp, color: colors.onSurfaceVariant),
                ),
                trailing: Icon(
                  Icons.open_in_new,
                  size: 16.r,
                  color: colors.onSurfaceVariant,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final auth = context.read<Auth>();
                  String? token;
                  try {
                    token = await auth.getIdToken(forceRefresh: true);
                  } catch (e, st) {
                    CrashReporter.recordError(e, st);
                  }
                  final base = '${Environment.appBaseUrl}/lists/import';
                  final url = token != null ? '$base?token=$token' : base;
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createList() async {
    final result = await showListFormSheet(context);
    if (result == null || !mounted) return;

    final listsProvider = Provider.of<ListsProvider>(context, listen: false);
    await listsProvider.createList(
      name: result['name'] as String,
      description: result['description'] as String?,
      listType: result['listType'] as ListType,
      eventDate: result['eventDate'] as DateTime?,
    );
  }

  Future<void> _editList(UserList list) async {
    if (!mounted) return;
    final listsProvider = Provider.of<ListsProvider>(context, listen: false);
    await ListActions.edit(context, list, listsProvider);
  }

  Future<void> _deleteList(UserList list) async {
    if (!mounted) return;
    final listsProvider = Provider.of<ListsProvider>(context, listen: false);
    await ListActions.delete(context, list, listsProvider);
  }

  void _shareList(UserList list) {
    ListActions.share(list);
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const FittedBox(
          fit: BoxFit.contain,
          child: Text('Lister'),
        ),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: auth.isSignedIn
          ? FloatingActionButton(
              onPressed: _showAddMenu,
              child: const Icon(Icons.add),
            )
          : null,
      body: auth.isSignedIn ? _buildListsView() : _buildSignInPrompt(),
    );
  }

  Widget _buildSignInPrompt() {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.list_alt_outlined,
                size: 40.r,
                color: colors.primary,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Logg inn for å bruke lister',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Hold oversikt med handlelister, lagerlister og mer.',
              style: TextStyle(
                fontSize: 14.sp,
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (_localCartCount > 0) ...[
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 16.r,
                        color: colors.primary,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        'Du har $_localCartCount produkter i handlelisten som vil bli overført ved innlogging.',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 24.h),
            FilledButton.icon(
              onPressed: () => context.push('/sign-in'),
              icon: const Icon(Icons.login),
              label: const Text('Logg inn'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListsView() {
    return Consumer<ListsProvider>(
      builder: (context, listsProvider, _) {
        if (listsProvider.loading && !listsProvider.listsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        if (listsProvider.error != null && !listsProvider.listsLoaded) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(listsProvider.error!),
                SizedBox(height: 12.h),
                FilledButton(
                  onPressed: () => listsProvider.fetchLists(),
                  child: const Text('Prøv igjen'),
                ),
              ],
            ),
          );
        }

        if (listsProvider.lists.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => listsProvider.fetchLists(),
          child: AnimatedReorderableListView<UserList>(
            items: listsProvider.lists,
            padding: EdgeInsets.only(top: 8.h, bottom: 80.h),
            buildDefaultDragHandles: false,
            enterTransition: [FadeIn(duration: const Duration(milliseconds: 200))],
            exitTransition: [FadeIn(duration: const Duration(milliseconds: 200))],
            insertDuration: const Duration(milliseconds: 200),
            removeDuration: const Duration(milliseconds: 200),
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final ids =
                  listsProvider.lists.map((l) => l.id).toList();
              final movedId = ids.removeAt(oldIndex);
              ids.insert(newIndex, movedId);
              listsProvider.reorderLists(ids);
            },
            isSameItem: (a, b) => a.id == b.id,
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.transparent,
                child: child,
              );
            },
            itemBuilder: (context, index) {
              final list = listsProvider.lists[index];
              return ListCard(
                key: ValueKey(list.id),
                list: list,
                dragIndex: index,
                onEdit: () => _editList(list),
                onDelete: () => _deleteList(list),
                onShare: () => _shareList(list),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.playlist_add,
                size: 40.r,
                color: colors.primary,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Ingen lister ennå',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Trykk + for å opprette din første liste.',
              style: TextStyle(
                fontSize: 14.sp,
                color: colors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
