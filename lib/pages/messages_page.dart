import 'package:flutter/material.dart';
import '../api.dart';
import '../models.dart';
import '../widgets/common.dart';
import 'login_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});
  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  List<MessageItem> _list = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (Api.token == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);
    final r = await Api.fetchMessages();
    if (!mounted) return;
    setState(() {
      _list = (r['messages'] as List? ?? [])
          .map((e) => MessageItem.fromJson(e as Map<String, dynamic>))
          .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (Api.token == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('消息通知')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.lock_outline_rounded,
                size: 64, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            const Text('登录后查看你的应用收到的评论'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage())),
              child: const Text('去登录'),
            ),
          ]),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息通知'),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _list.isEmpty
                ? ListView(children: const [
                    SizedBox(height: 200),
                    Center(child: Text('暂无新消息')),
                  ])
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final m = _list[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Icon(Icons.mark_chat_unread_rounded,
                                      size: 18, color: scheme.primary),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '你的应用「${m.appName}」收到新评论',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ]),
                                const SizedBox(height: 8),
                                Text('${m.fromUser} 评分 ${m.rating} 星：${m.content}',
                                    style: const TextStyle(height: 1.5)),
                                const SizedBox(height: 6),
                                Text(
                                  m.time.replaceFirst('T', ' ').substring(0,
                                      m.time.length > 16 ? 16 : m.time.length),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onSurfaceVariant),
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
