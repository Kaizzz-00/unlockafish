import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import 'fish_classifier.dart';

class _MobileFishClassifier implements FishClassifier {
  late Interpreter _interpreter;
  late List<String> _labels;
  late int _inputSize;
  bool _loaded = false;

  @override
  Future<void> load() async {
    // 加载模型与标签
    try {
      _interpreter = await Interpreter.fromAsset('models/fish_classifier.tflite');
      _labels = (await rootBundle.loadString('assets/models/labels.txt'))
          .split('\n')
          .where((e) => e.trim().isNotEmpty)
          .toList();

      final inputTensor = _interpreter.getInputTensor(0);
      // 形状示例: [1, 224, 224, 3]
      final shape = inputTensor.shape;
      _inputSize = shape.length >= 3 ? shape[1] : 224;

      _loaded = true;
    } catch (_) {
      _loaded = false;
      rethrow;
    }
  }

  @override
  Future<List<FishPrediction>> classifyBytes(List<int> bytes, {int topK = 3}) async {
    if (!_loaded) {
      return [];
    }

    // 读取与预处理
    final image = img.decodeImage(Uint8List.fromList(bytes));
    if (image == null) return [];
    final resized = img.copyResize(image, width: _inputSize, height: _inputSize);

    // 输入: [1, H, W, 3]
    final input = List.generate(1, (_) => List.generate(_inputSize, (y) => List.generate(_inputSize, (x) {
          final p = resized.getPixel(x, y);
          final r = p.r / 255.0;
          final g = p.g / 255.0;
          final b = p.b / 255.0;
          return [r, g, b];
        })));

    // 输出: [1, numLabels]
    final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));

    try {
      _interpreter.run(input, output);
    } catch (_) {
      return [];
    }

    final scores = output[0].cast<double>();
    final indexed = List.generate(scores.length, (i) => MapEntry(i, scores[i]));
    indexed.sort((a, b) => b.value.compareTo(a.value));

    return indexed.take(topK).map((e) {
      final label = e.key < _labels.length ? _labels[e.key] : 'Unknown';
      return FishPrediction(label: label, confidence: e.value);
    }).toList();
  }

  @override
  void dispose() {
    try {
      _interpreter.close();
    } catch (_) {}
  }
}

FishClassifier createPlatformClassifier() => _MobileFishClassifier();