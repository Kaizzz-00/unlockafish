import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../services/ml/fish_classifier.dart';

class IdentificationPage extends StatefulWidget {
  const IdentificationPage({super.key});

  @override
  State<IdentificationPage> createState() => _IdentificationPageState();
}

class _IdentificationPageState extends State<IdentificationPage> {
  late final FishClassifier _classifier;
  bool _modelReady = false;
  bool _running = false;
  Uint8List? _imageBytes;
  List<FishPrediction> _predictions = const [];

  @override
  void initState() {
    super.initState();
    _classifier = createClassifier();
    _initModel();
  }

  Future<void> _initModel() async {
    if (kIsWeb) {
      // Web 暂不支持本地推理，使用占位实现
      setState(() => _modelReady = true);
      return;
    }
    try {
      await _classifier.load();
      setState(() => _modelReady = true);
    } catch (e) {
      // 模型加载失败，仍允许选择图片但不进行推理
      setState(() => _modelReady = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('模型加载失败：$e')),
      );
    }
  }

  Future<void> _pickAndClassify() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _running = true;
      _predictions = const [];
    });

    try {
      final preds = await _classifier.classifyBytes(bytes, topK: 3);
      setState(() => _predictions = preds);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('推理失败：$e')),
      );
    } finally {
      setState(() => _running = false);
    }
  }

  @override
  void dispose() {
    _classifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.identifyTab),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (kIsWeb)
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingSmall),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '当前为 Web 预览，暂不支持本地模型推理。\n请在 Android/iOS 设备运行以体验离线识别。',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            const SizedBox(height: AppConstants.paddingMedium),

            // 选择图片按钮
            ElevatedButton.icon(
              onPressed: _running ? null : _pickAndClassify,
              icon: const Icon(Icons.photo_library),
              label: const Text('选择图片并识别'),
            ),
            const SizedBox(height: AppConstants.paddingSmall),

            // 预览所选图片
            if (_imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _imageBytes!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: AppConstants.paddingMedium),

            // 识别结果
            if (_running)
              const Center(child: CircularProgressIndicator())
            else if (_predictions.isEmpty)
              const Center(child: Text('暂无识别结果'))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _predictions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final p = _predictions[index];
                    return Container(
                      padding: const EdgeInsets.all(AppConstants.paddingSmall),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.biotech, size: 32),
                          const SizedBox(width: AppConstants.paddingSmall),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.label,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '置信度: ${(p.confidence * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}