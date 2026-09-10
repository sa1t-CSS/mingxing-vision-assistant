import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'app_settings.dart';
import 'detection.dart';

// AI辅助生成：Codex.2026-04-28) 封装语音播报、震动和重复提醒抑制策略。
class AlertService {
  AlertService() {
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.58);
    _tts.setVolume(1);
  }

  static const _channel = MethodChannel('vision_guard/ncnn');

  final FlutterTts _tts = FlutterTts();
  DateTime _lastAlertAt = DateTime.fromMillisecondsSinceEpoch(0);
  String? _lastMessage;

  Future<void> stop() async {
    await _tts.stop();
    _lastMessage = null;
  }

  Future<void> applySettings(AppSettings settings) async {
    if (!settings.voiceEnabled) {
      await stop();
    }
  }

  Future<void> test(AppSettings settings) async {
    if (settings.vibrationEnabled) {
      await _vibrate(strong: true);
    }
    if (settings.voiceEnabled) {
      await _tts.stop();
      await _tts.speak('\u524d\u65b9\u6709\u969c\u788d\u7269\uff0c\u8bf7\u6ce8\u610f\u907f\u8ba9');
    }
  }

  // AI辅助生成：Codex.2026-04-28) 根据检测风险和用户设置触发语音/震动预警。
  Future<void> speakFor(DetectionFrame frame, AppSettings settings) async {
    final message = _messageFor(frame);
    if (message == null) return;

    final now = DateTime.now();
    final quietPeriod = Duration(milliseconds: settings.alertIntervalMs);
    if (message == _lastMessage && now.difference(_lastAlertAt) < quietPeriod) {
      return;
    }

    _lastMessage = message;
    _lastAlertAt = now;

    if (settings.vibrationEnabled && frame.risk.index >= RiskLevel.warning.index) {
      await _vibrate(strong: frame.risk == RiskLevel.danger);
    }

    if (settings.voiceEnabled) {
      await _tts.stop();
      await _tts.speak(message);
    }
  }

  Future<void> _vibrate({required bool strong}) async {
    await HapticFeedback.heavyImpact();
    await _channel.invokeMethod<void>('vibrateAlert', {'strong': strong});
  }

  // AI辅助生成：Codex.2026-04-28) 将结构化检测结果转换成适合视障用户理解的中文提示。
  String? _messageFor(DetectionFrame frame) {
    final primary = frame.primary;
    if (primary == null) return null;

    final direction = primary.direction.label;
    final distance = primary.distanceMeters == null
        ? ''
        : '\uff0c\u7ea6${primary.distanceMeters!.toStringAsFixed(1)}\u7c73';

    return switch (primary.type) {
      DetectionClass.obstacle =>
        '$direction\u6709\u969c\u788d\u7269\uff0c\u8bf7\u6ce8\u610f\u907f\u8ba9',
      DetectionClass.stairs =>
        '$direction\u6709\u53f0\u9636$distance\uff0c\u8bf7\u6162\u884c',
      DetectionClass.trafficLightRed => '\u7ea2\u706f\uff0c\u8bf7\u7b49\u5f85',
      DetectionClass.trafficLightYellow => '\u9ec4\u706f\uff0c\u8bf7\u6ce8\u610f',
      DetectionClass.trafficLightGreen => '\u7eff\u706f\uff0c\u53ef\u4ee5\u901a\u884c',
      DetectionClass.tactilePaving => '\u68c0\u6d4b\u5230\u76f2\u9053',
      DetectionClass.person => '$direction\u6709\u884c\u4eba$distance',
      DetectionClass.vehicle =>
        '$direction\u6709\u8f66\u8f86$distance\uff0c\u8bf7\u6ce8\u610f',
      DetectionClass.unknown => null,
    };
  }
}
