import 'package:flutter/material.dart';
import '../api.dart';
import '../widgets/common.dart';
import 'login_page.dart';
import 'admin_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _me;
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
    final r = await Api.fetchMe();
    if (!mounted) return;
    setState(() {
      _me = r;
      _loading = false;
    });
  }

  Future<void> _checkin() async {
    final r = await Api.checkin();
    if (!mounted) return;
    showToast(context, '${r['msg'] ?? ''}', error: r['ok'] != true);
    if (r['ok'] == true) _load();
  }

  Future<void> _logout() async {
    await Api.setToken(null);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  Future<void> _editProfile() async {
    final name = TextEditingController(text: '${_me?['name'] ?? ''}');
    final bio = TextEditingController(text: '${_me?['bio'] ?? ''}');
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('编辑资料'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: name,
              decoration: const InputDecoration(labelText: '昵称')),
          const SizedBox(height: 12),
          TextField(
              controller: bio,
              decoration: const InputDecoration(labelText: '个性签名')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('保存')),
        ],
      ),
    );
    if (ok == true) {
      final r = await Api.updateProfile(name: name.text.trim(), bio: bio.text.trim());
      if (!mounted) return;
      showToast(context, '${r['msg'] ?? ''}', error: r['ok'] != true);
      if (r['ok'] == true) _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (Api.token == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('我的')),
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.account_circle_outlined,
                size: 80, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            const Text('登录后同步你的金币与投稿'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginPage())),
              child: const Text('登录 / 注册'),
            ),
          ]),
        ),
      );
    }
    final name = '${_me?['name'] ?? '星河用户'}';
    final email = '${_me?['email'] ?? ''}';
    final bio = '${_me?['bio'] ?? ''}';
    final rawCoins = _me?['coins'];
    final int coins = rawCoins is int
        ? rawCoins
        : int.tryParse('$rawCoins') ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout_rounded)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: scheme.primary,
                        child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(email,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(bio.isEmpty ? '这个人很懒，什么都没写' : bio,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onSurfaceVariant)),
                            ]),
                      ),
                      IconButton(
                          onPressed: _editProfile,
                          icon: const Icon(Icons.edit_outlined)),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 12),
                        child: Column(children: [
                          Icon(Icons.monetization_on_rounded,
                              size: 28, color: scheme.tertiary),
                          const SizedBox(height: 6),
                          Text('$coins',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const Text('我的金币',
                              style: TextStyle(fontSize: 12)),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 12),
                        child: Column(children: [
                          Icon(Icons.card_giftcard_rounded,
                              size: 28, color: scheme.primary),
                          const SizedBox(height: 6),
                          FilledButton.tonal(
                            onPressed: _checkin,
                            style: FilledButton.styleFrom(
                                minimumSize: const Size(120, 36),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12)),
                            child: const Text('每日签到'),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 16),
                Card(
                  child: Column(children: [
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings_outlined),
                      title: const Text('后台管理'),
                      subtitle: const Text('管理员登录 / 审核投稿 / 站点统计'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => const AdminPage())),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline_rounded),
                      title: const Text('关于星河软件站'),
                      subtitle: const Text('版本 1.0.0 · 应用分享平台'),
                    ),
                  ]),
                ),
              ],
            ),
    );
  }
}
