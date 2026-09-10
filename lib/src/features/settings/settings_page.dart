import 'package:flutter/material.dart';

import '../../core/alert_service.dart';
import '../../core/app_settings.dart';

// AI辅助生成：Codex.2026-04-28) 提供提醒方式、阈值和模型输入相关运行设置。
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  static const routeName = '/settings';

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _alerts = AlertService();
  AppSettings _settings = AppSettings.defaults;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final settings = await AppSettings.load();
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _loaded = true;
    });
  }

  // AI辅助生成：Codex.2026-04-28) 保存设置并立即同步到提醒服务。
  Future<void> _save(AppSettings settings) async {
    setState(() => _settings = settings);
    await settings.save();
    await _alerts.applySettings(settings);
  }

  Future<void> _testAlert() => _alerts.test(_settings);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('\u8f85\u52a9\u8bbe\u7f6e')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  value: _settings.voiceEnabled,
                  onChanged: (value) =>
                      _save(_settings.copyWith(voiceEnabled: value)),
                  secondary: const Icon(Icons.record_voice_over_rounded),
                  title: const Text('\u8bed\u97f3\u9884\u8b66'),
                  subtitle: const Text('\u5173\u95ed\u540e\u4e0d\u518d\u64ad\u62a5\u8bed\u97f3'),
                ),
                SwitchListTile(
                  value: _settings.vibrationEnabled,
                  onChanged: (value) =>
                      _save(_settings.copyWith(vibrationEnabled: value)),
                  secondary: const Icon(Icons.vibration_rounded),
                  title: const Text('\u9707\u52a8\u63d0\u9192'),
                  subtitle: const Text('\u5173\u95ed\u540e\u4e0d\u518d\u89e6\u53d1\u624b\u673a\u9707\u52a8'),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  child: FilledButton.icon(
                    onPressed: _testAlert,
                    icon: const Icon(Icons.campaign_rounded),
                    label: const Text('\u6d4b\u8bd5\u5f53\u524d\u63d0\u9192\u8bbe\u7f6e'),
                  ),
                ),
                _SettingSection(
                  title: '\u8bc6\u522b\u9608\u503c',
                  icon: Icons.tune_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        value: _settings.confidenceThreshold,
                        min: 0.25,
                        max: 0.85,
                        divisions: 12,
                        label: _settings.confidenceThreshold.toStringAsFixed(2),
                        onChanged: (value) => _save(
                          _settings.copyWith(confidenceThreshold: value),
                        ),
                      ),
                      Text(
                        '\u5f53\u524d\uff1a${_settings.confidenceThreshold.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
                _SettingSection(
                  title: '\u64ad\u62a5\u95f4\u9694',
                  icon: Icons.timer_rounded,
                  child: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 800, label: Text('0.8 \u79d2')),
                      ButtonSegment(value: 1200, label: Text('1.2 \u79d2')),
                      ButtonSegment(value: 1800, label: Text('1.8 \u79d2')),
                    ],
                    selected: {_settings.alertIntervalMs},
                    onSelectionChanged: (values) => _save(
                      _settings.copyWith(alertIntervalMs: values.first),
                    ),
                  ),
                ),
                const _SettingSection(
                  title: '\u63a8\u7406\u8f93\u5165',
                  icon: Icons.memory_rounded,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('640'),
                    subtitle: Text('\u5f53\u524d\u6a21\u578b\u56fa\u5b9a\u8f93\u51fa 8400 \u4e2a\u5019\u9009\u70b9'),
                    trailing: Icon(Icons.lock_rounded),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SettingSection extends StatelessWidget {
  const _SettingSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
