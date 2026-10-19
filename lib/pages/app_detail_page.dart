import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'login_page.dart';

class AppDetailPage extends StatefulWidget {
  final AppItem app;
  const AppDetailPage({super.key, required this.app});
  @override
  State<AppDetailPage> createState() => _AppDetailPageState();
}

class _AppDetailPageState extends State<AppDetailPage> {
  List<CommentItem> _comments = [];
  double _avgRating = 0;
  bool _loading = true;
  bool _downloading = false;
  final _comment = TextEditingController();
  int _rating = 5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await Api.fetchComments(widget.app.id);
    if (!mounted) return;
    setState(() {
      _comments = (r['comments'] as List? ?? [])
          .map((e) => CommentItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _avgRating = (r['avg_rating'] is num)
          ? (r['avg_rating'] as num).toDouble()
          : 0;
      _loading = false;
    });
  }

  Future<void> _download() async {
    if (Api.token == null) {
      showToast(context, '请先登录后再下载', error: true);
      Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    setState(() => _downloading = true);
    final r = await Api.download(widget.app.id);
    setState(() => _downloading = false);
    if (!mounted) return;
    if (r['ok'] == true) {
      final url = '${r['download_url'] ?? ''}';
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('下载链接已获取'),
          content: SelectableText(url,
              style: const TextStyle(fontSize: 13, height: 1.5)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
            FilledButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: url));
                Navigator.pop(context);
                showToast(context, '链接已复制到剪贴板');
              },
              child: const Text('复制链接'),
            ),
          ],
        ),
      );
    } else {
      showToast(context, '${r['msg'] ?? '下载失败'}', error: true);
    }
  }

  Future<void> _submitComment() async {
    if (Api.token == null) {
      showToast(context, '请先登录', error: true);
      return;
    }
    if (_comment.text.trim().isEmpty) {
      showToast(context, '评论内容不能为空', error: true);
      return;
    }
    final r = await Api.comment(widget.app.id, _comment.text.trim(), _rating);
    if (!mounted) return;
    if (r['ok'] == true) {
      showToast(context, '评论成功');
      _comment.clear();
      _load();
    } else {
      showToast(context, '${r['msg'] ?? '评论失败'}', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final a = widget.app;
    return Scaffold(
      appBar: AppBar(title: Text(a.name)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Row(children: [
            AppIconImage(app: a, size: 84),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(children: [
                    StarRating(rating: _avgRating, size: 18),
                    const SizedBox(width: 6),
                    Text(_avgRating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 13)),
                  ]),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, children: [
                    _meta(Icons.person_outline_rounded, a.uploader),
                    _meta(Icons.sell_outlined, a.category),
                    _meta(Icons.straighten_rounded, a.size),
                    _meta(Icons.tag_rounded, 'v${a.version}'),
                  ]),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _downloading ? null : _download,
                icon: _downloading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.download_rounded),
                label: Text(a.coinsPrice > 0
                    ? '下载 (${a.coinsPrice}金币)'
                    : '免费下载'),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          Text('应用简介',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface)),
          const SizedBox(height: 8),
          Text(a.desc.isEmpty ? '暂无简介' : a.desc,
              style: TextStyle(
                  fontSize: 14, height: 1.6, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 20),
          Row(children: [
            const Text('用户评论',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('共 ${_comments.length} 条',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
          ]),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    const Text('我的评分：'),
                    ...List.generate(5, (i) {
                      return IconButton(
                        icon: Icon(
                          i < _rating
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: scheme.tertiary,
                        ),
                        onPressed: () => setState(() => _rating = i + 1),
                      );
                    }),
                  ]),
                  TextField(
                    controller: _comment,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: '分享你的使用体验...',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _submitComment,
                      style: FilledButton.styleFrom(
                          minimumSize: const Size(120, 44)),
                      child: const Text('发表'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_comments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('还没有评论，来抢沙发')),
            )
          else
            ..._comments.map((c) => _CommentTile(c: c)),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text) {
    final scheme = Theme.of(context).colorScheme;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 13, color: scheme.onSurfaceVariant),
      const SizedBox(width: 3),
      Text(text, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
    ]);
  }
}

class _CommentTile extends StatelessWidget {
  final CommentItem c;
  const _CommentTile({required this.c});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: scheme.primaryContainer,
                child: Text(c.username.isNotEmpty ? c.username[0].toUpperCase() : '?',
                    style: TextStyle(
                        fontSize: 13, color: scheme.onPrimaryContainer)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(c.username,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              StarRating(rating: c.rating.toDouble(), size: 14),
            ]),
            const SizedBox(height: 8),
            Text(c.content, style: const TextStyle(fontSize: 14, height: 1.5)),
            const SizedBox(height: 6),
            Text(c.createdAt.replaceFirst('T', ' ').substring(0,
                c.createdAt.length > 16 ? 16 : c.createdAt.length),
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
