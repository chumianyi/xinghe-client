import 'package:flutter/material.dart';
import '../api.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'app_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AppItem> _apps = [];
  bool _loading = true;
  String _keyword = '';
  String _category = '全部';
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await Api.fetchApps();
    if (!mounted) return;
    final list = (r['apps'] as List? ?? [])
        .map((e) => AppItem.fromJson(e as Map<String, dynamic>))
        .toList();
    setState(() {
      _apps = list;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String>{'全部'}
      ..addAll(_apps.map((e) => e.category).where((c) => c.isNotEmpty));
    final filtered = _apps.where((a) {
      final matchCat = _category == '全部' || a.category == _category;
      final matchKw = _keyword.isEmpty ||
          a.name.toLowerCase().contains(_keyword.toLowerCase()) ||
          a.desc.toLowerCase().contains(_keyword.toLowerCase());
      return matchCat && matchKw;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('星河应用'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            TextField(
              controller: _search,
              onChanged: (v) => setState(() => _keyword = v),
              decoration: InputDecoration(
                hintText: '搜索应用名称或描述',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _keyword.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _search.clear();
                          setState(() => _keyword = '');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: categories.map((c) {
                  final selected = c == _category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (filtered.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: Text('没有找到相关应用')),
              )
            else
              ...filtered.map((a) => _AppCard(app: a)),
          ],
        ),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final AppItem app;
  const _AppCard({required this.app});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AppDetailPage(app: app))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              AppIconImage(app: app, size: 60),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(app.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                      if (app.coinsPrice > 0) CoinChip(coins: app.coinsPrice),
                    ]),
                    const SizedBox(height: 4),
                    Text(app.desc,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13, color: scheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.star_rounded,
                          size: 14, color: scheme.tertiary),
                      const SizedBox(width: 2),
                      Text(app.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Icon(Icons.download_rounded,
                          size: 14, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Text('${app.downloadCount}',
                          style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 12),
                      Text('v${app.version}',
                          style: TextStyle(
                              fontSize: 12, color: scheme.onSurfaceVariant)),
                      const SizedBox(width: 8),
                      Text(app.size,
                          style: TextStyle(
                              fontSize: 12, color: scheme.onSurfaceVariant)),
                    ]),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
