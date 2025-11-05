import 'fish_classifier.dart';

class _StubClassifier implements FishClassifier {
  @override
  Future<void> load() async {}

  @override
  Future<List<FishPrediction>> classifyBytes(List<int> bytes, {int topK = 3}) async {
    return [];
  }

  @override
  void dispose() {}
}

FishClassifier createPlatformClassifier() => _StubClassifier();