import 'package:flutter/material.dart';
import '../api.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});
  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  List<Map<String, dynamic>> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await Api.fetchRanking();
    if (!mounted) return;
    setState(() {
      _list = (r['ranking'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('下载排行榜')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _list.isEmpty
                ? ListView(children: const [
                    SizedBox(height: 200),
                    Center(child: Text('暂无排行数据')),
                  ])
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final item = _list[i];
                      final rank = i + 1;
                      Color rankColor;
                      if (rank == 1) {
                        rankColor = const Color(0xFFFFB300);
                      } else if (rank == 2) {
                        rankColor = const Color(0xFF90A4AE);
                      } else if (rank == 3) {
                        rankColor = const Color(0xFFCD7F32);
                      } else {
                        rankColor = scheme.onSurfaceVariant;
                      }
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(children: [
                            SizedBox(
                              width: 36,
                              child: Text('$rank',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: rank <= 3 ? 22 : 16,
                                      fontWeight: FontWeight.bold,
                                      color: rankColor)),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(colors: [
                                  scheme.primary,
                                  scheme.secondary,
                                ]),
                              ),
                              child: Center(
                                child: Text(
                                  '${item['name'] ?? '?'}'.isNotEmpty
                                      ? '${item['name']}'[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${item['name'] ?? ''}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    Icon(Icons.download_rounded,
                                        size: 13,
                                        color: scheme.onSurfaceVariant),
                                    const SizedBox(width: 3),
                                    Text('${item['download_count'] ?? 0} 次下载',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: scheme.onSurfaceVariant)),
                                  ]),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
