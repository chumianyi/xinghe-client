import 'package:flutter/material.dart';
import '../api.dart';
import '../models.dart';
import '../widgets/common.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _loggedIn = false;
  bool _busy = false;
  final _user = TextEditingController();
  final _pwd = TextEditingController();
  Map<String, dynamic>? _stats;
  List<PendingItem> _pending = [];

  @override
  void dispose() {
    _user.dispose();
    _pwd.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _busy = true);
    final r = await Api.adminLogin(_user.text.trim(), _pwd.text);
    setState(() => _busy = false);
    if (!mounted) return;
    if (r['ok'] == true) {
      setState(() => _loggedIn = true);
      _loadAll();
    } else {
      showToast(context, '${r['msg'] ?? '登录失败'}', error: true);
    }
  }

  Future<void> _loadAll() async {
    final results = await Future.wait([Api.adminStats(), Api.adminPending()]);
    if (!mounted) return;
    setState(() {
      _stats = results[0];
      _pending = (results[1]['pending'] as List? ?? [])
          .map((e) => PendingItem.fromJson(e as Map<String, dynamic>))
          .toList();
    });
  }

  Future<void> _approve(String id) async {
    final r = await Api.adminApprove(id);
    if (!mounted) return;
    showToast(context, '${r['msg'] ?? ''}', error: r['ok'] != true);
    if (r['ok'] == true) _loadAll();
  }

  Future<void> _reject(String id) async {
    final r = await Api.adminReject(id);
    if (!mounted) return;
    showToast(context, '${r['msg'] ?? ''}', error: r['ok'] != true);
    if (r['ok'] == true) _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('后台管理')),
      body: !_loggedIn
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 40),
                Icon(Icons.shield_outlined, size: 64, color: scheme.primary),
                const SizedBox(height: 16),
                const Center(child: Text('管理员登录',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                const SizedBox(height: 24),
                TextField(
                  controller: _user,
                  decoration: const InputDecoration(
                      labelText: '管理员账号',
                      prefixIcon: Icon(Icons.badge_outlined)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _pwd,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: '密码',
                      prefixIcon: Icon(Icons.lock_outline_rounded)),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _busy ? null : _login,
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('登录'),
                ),
              ],
            )
          : RefreshIndicator(
              onRefresh: _loadAll,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Row(children: [
                    _statCard('应用总数', '${_stats?['total_apps'] ?? 0}',
                        Icons.apps_rounded),
                    const SizedBox(width: 10),
                    _statCard('待审核', '${_stats?['pending_count'] ?? 0}',
                        Icons.hourglass_top_rounded),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    _statCard('用户数', '${_stats?['total_users'] ?? 0}',
                        Icons.people_alt_outlined),
                    const SizedBox(width: 10),
                    _statCard('总下载量', '${_stats?['total_downloads'] ?? 0}',
                        Icons.download_rounded),
                  ]),
                  const SizedBox(height: 20),
                  const Text('待审核投稿',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (_pending.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('没有待审核的投稿')),
                    )
                  else
                    ..._pending.map((p) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text('v${p.version} · ${p.size}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: scheme.onSurfaceVariant)),
                                  const SizedBox(height: 2),
                                  Text('投稿人：${p.submittedBy}',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: scheme.onSurfaceVariant)),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _reject(p.id),
                                        icon: const Icon(Icons.close_rounded),
                                        label: const Text('拒绝'),
                                        style: OutlinedButton.styleFrom(
                                            foregroundColor: scheme.error),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: () => _approve(p.id),
                                        icon: const Icon(Icons.check_rounded),
                                        label: const Text('通过'),
                                      ),
                                    ),
                                  ]),
                                ]),
                          ),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}
