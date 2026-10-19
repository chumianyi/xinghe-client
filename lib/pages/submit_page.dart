import 'package:flutter/material.dart';
import '../api.dart';
import '../widgets/common.dart';
import 'login_page.dart';

class SubmitPage extends StatefulWidget {
  const SubmitPage({super.key});
  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final _name = TextEditingController();
  final _version = TextEditingController();
  final _size = TextEditingController();
  final _desc = TextEditingController();
  final _downloadUrl = TextEditingController();
  final _iconUrl = TextEditingController();
  String _category = '工具';
  double _price = 0;
  bool _busy = false;

  final _categories = const [
    '工具', '社交', '娱乐', '教育', '效率', '生活', '游戏', '摄影', '音乐', '其他'
  ];

  @override
  void dispose() {
    _name.dispose();
    _version.dispose();
    _size.dispose();
    _desc.dispose();
    _downloadUrl.dispose();
    _iconUrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (Api.token == null) {
      showToast(context, '请先登录后再投稿', error: true);
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const LoginPage()));
      return;
    }
    if (_name.text.trim().isEmpty ||
        _version.text.trim().isEmpty ||
        _size.text.trim().isEmpty ||
        _desc.text.trim().isEmpty ||
        _downloadUrl.text.trim().isEmpty) {
      showToast(context, '请完整填写应用信息', error: true);
      return;
    }
    setState(() => _busy = true);
    final r = await Api.submitApp({
      'name': _name.text.trim(),
      'version': _version.text.trim(),
      'size': _size.text.trim(),
      'desc': _desc.text.trim(),
      'category': _category,
      'download_url': _downloadUrl.text.trim(),
      'icon_url': _iconUrl.text.trim(),
      'coins_price': _price.round(),
    });
    setState(() => _busy = false);
    if (!mounted) return;
    showToast(context, '${r['msg'] ?? ''}', error: r['ok'] != true);
    if (r['ok'] == true) {
      _name.clear();
      _version.clear();
      _size.clear();
      _desc.clear();
      _downloadUrl.clear();
      _iconUrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('投稿应用')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Icon(Icons.upload_file_rounded,
                    size: 40, color: scheme.primary),
                const SizedBox(height: 8),
                Text('投稿需 1 金币押金，审核通过后退还并奖励 2 金币',
                    style: TextStyle(
                        fontSize: 13, color: scheme.onSurfaceVariant)),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
                labelText: '应用名称 *', prefixIcon: Icon(Icons.apps_rounded)),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _version,
                decoration: const InputDecoration(
                    labelText: '版本号 *', hintText: '1.0.0'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _size,
                decoration: const InputDecoration(
                    labelText: '安装包大小 *', hintText: '25MB'),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
                labelText: '分类', prefixIcon: Icon(Icons.category_outlined)),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? '工具'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _downloadUrl,
            decoration: const InputDecoration(
              labelText: '蓝奏云 / 123网盘链接 *',
              hintText: 'https://xxx.lanzoub.com/abc',
              prefixIcon: Icon(Icons.link_rounded),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _iconUrl,
            decoration: const InputDecoration(
              labelText: '应用图标 URL（选填）',
              prefixIcon: Icon(Icons.image_outlined),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '应用简介 *',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('售价金币：${_price.round()} 金币',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Slider(
                      value: _price,
                      min: 0,
                      max: 3,
                      divisions: 3,
                      label: '${_price.round()}',
                      onChanged: (v) => setState(() => _price = v),
                    ),
                  ]),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('提交投稿'),
          ),
        ],
      ),
    );
  }
}
