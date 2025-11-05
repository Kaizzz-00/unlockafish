import 'fish_classifier_stub.dart' if (dart.library.io) 'fish_classifier_mobile.dart';

class FishPrediction {
  final String label;
  final double confidence;
  FishPrediction({required this.label, required this.confidence});
}

abstract class FishClassifier {
  Future<void> load();
  Future<List<FishPrediction>> classifyBytes(List<int> bytes, {int topK = 3});
  void dispose();
}

FishClassifier createClassifier() => createPlatformClassifier();