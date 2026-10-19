import 'package:flutter/material.dart';
import '../api.dart';
import '../widgets/common.dart';
import 'home_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  bool _busy = false;
  int _countdown = 0;

  @override
  void dispose() {
    _tab.dispose();
    _email.dispose();
    _password.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_email.text.trim().isEmpty) {
      showToast(context, '请输入QQ邮箱', error: true);
      return;
    }
    setState(() => _busy = true);
    final r = await Api.sendCode(_email.text.trim());
    setState(() => _busy = false);
    if (!mounted) return;
    showToast(context, '${r['msg'] ?? ''}', error: r['ok'] != true);
    if (r['ok'] == true) {
      setState(() => _countdown = 60);
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return false;
        setState(() => _countdown--);
        return _countdown > 0;
      });
    }
  }

  Future<void> _login() async {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      showToast(context, '请输入邮箱和密码', error: true);
      return;
    }
    setState(() => _busy = true);
    final r = await Api.login(_email.text.trim(), _password.text);
    setState(() => _busy = false);
    if (!mounted) return;
    if (r['ok'] == true) {
      await Api.setToken(r['token']);
      await Api.fetchMe();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeShell()));
    } else {
      showToast(context, '${r['msg'] ?? '登录失败'}', error: true);
    }
  }

  Future<void> _register() async {
    if (_email.text.trim().isEmpty ||
        _code.text.trim().isEmpty ||
        _password.text.isEmpty) {
      showToast(context, '请完整填写注册信息', error: true);
      return;
    }
    setState(() => _busy = true);
    final r = await Api.register(
        _email.text.trim(), _code.text.trim(), _password.text);
    setState(() => _busy = false);
    if (!mounted) return;
    if (r['ok'] == true) {
      await Api.setToken(r['token']);
      await Api.fetchMe();
      if (!mounted) return;
      showToast(context, '注册成功');
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeShell()));
    } else {
      showToast(context, '${r['msg'] ?? '注册失败'}', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [scheme.primary, scheme.secondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withOpacity(0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      )
                    ],
                  ),
                  child: const Icon(Icons.rocket_launch_rounded,
                      color: Colors.white, size: 44),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text('星河软件站',
                    style:
                        TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text('发现优质应用，分享你的宝藏',
                    style: TextStyle(
                        fontSize: 14, color: scheme.onSurfaceVariant)),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tab,
                  indicator: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  labelColor: scheme.onPrimaryContainer,
                  unselectedLabelColor: scheme.onSurfaceVariant,
                  tabs: const [Tab(text: '登录'), Tab(text: '注册')],
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'QQ邮箱',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
              ),
              const SizedBox(height: 14),
              if (_tab.index == 1) ...[
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _code,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '6位验证码',
                        prefixIcon: Icon(Icons.sms_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 52,
                    child: FilledButton.tonal(
                      onPressed: _busy || _countdown > 0 ? null : _sendCode,
                      child: Text(_countdown > 0 ? '${_countdown}s' : '发送'),
                    ),
                  ),
                ]),
                const SizedBox(height: 14),
              ],
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '密码',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : (_tab.index == 0 ? _login : _register),
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(_tab.index == 0 ? '登录' : '注册'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
