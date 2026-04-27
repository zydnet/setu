import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/donatable_item.dart';

abstract class ScanEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScanImageEvent extends ScanEvent {
  final File imageFile;
  ScanImageEvent(this.imageFile);

  @override
  List<Object?> get props => [imageFile];
}

abstract class ScanState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ScanInitial extends ScanState {}

class ScanLoading extends ScanState {
  final String? preliminaryLabel;
  ScanLoading({this.preliminaryLabel});

  @override
  List<Object?> get props => [preliminaryLabel];
}

class ScanSuccess extends ScanState {
  final DonatableItem item;
  ScanSuccess(this.item);

  @override
  List<Object?> get props => [item];
}

class ScanError extends ScanState {
  final String message;
  ScanError(this.message);

  @override
  List<Object?> get props => [message];
}

class ScanBloc extends Bloc<ScanEvent, ScanState> {
  final ImageLabeler _labeler =
      ImageLabeler(options: ImageLabelerOptions(confidenceThreshold: 0.5));

  ScanBloc() : super(ScanInitial()) {
    on<ScanImageEvent>(_onScanImage);
  }

  @override
  Future<void> close() {
    _labeler.close();
    return super.close();
  }

  Future<void> _onScanImage(
      ScanImageEvent event, Emitter<ScanState> emit) async {
    emit(ScanLoading());
    try {
      // 1. ML Kit Local Identification (Fast)
      final inputImage = InputImage.fromFile(event.imageFile);
      final labels = await _labeler.processImage(inputImage);
      final labelString = labels
          .map(
              (l) => '${l.label} (${(l.confidence * 100).toStringAsFixed(0)}%)')
          .join(', ');

      final preliminaryCategory = _mapLabelsToCategory(
          labels.map((e) => e.label.toLowerCase()).toList());
      if (preliminaryCategory != null) {
        emit(ScanLoading(preliminaryLabel: preliminaryCategory));
      }

      // 2. Gemini Detailed Analysis (Deep)
      final bytes = await event.imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final prompt = '''
Analyze this image and identify the item. 
Local ML Kit detected these possible labels: $labelString.

Please determine:
1) What is this item?
2) What category does it belong to (clothing, electronics, books, furniture, or other)?
3) What is its condition (good, fair, poor)?
4) A brief description.

Provide your response as a concise JSON with fields: name, category, condition, description.
''';

      final response = await http.post(
        Uri.parse(
            '${ApiConstants.geminiVisionUrl}?key=${ApiConstants.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inlineData': {'mimeType': 'image/jpeg', 'data': base64Image}
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        final item = _parseGeminiResponse(text);
        emit(ScanSuccess(item));
      } else {
        emit(ScanError('Failed to analyze image: ${response.statusCode}'));
      }
    } catch (e) {
      emit(ScanError('Error: $e'));
    }
  }

  DonatableItem _parseGeminiResponse(String response) {
    String name = 'Unknown Item';
    String categoryStr = 'other';
    String condition = 'good';
    String description = response;

    try {
      final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(response);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        final data = jsonDecode(jsonStr);
        name = data['name'] ?? name;
        categoryStr = data['category'] ?? categoryStr;
        condition = data['condition'] ?? condition;
        description = data['description'] ?? description;
      }
    } catch (_) {
      final lines = response.split('\n');
      for (final line in lines) {
        if (line.toLowerCase().contains('name:')) {
          name = line.split(':').last.trim();
        } else if (line.toLowerCase().contains('category:')) {
          categoryStr = line.split(':').last.trim();
        } else if (line.toLowerCase().contains('condition:')) {
          condition = line.split(':').last.trim();
        }
      }
    }

    return DonatableItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: DonatableItem.categoryFromString(categoryStr),
      condition: condition,
      description: description,
    );
  }

  String? _mapLabelsToCategory(List<String> labels) {
    if (labels.isEmpty) return null;

    final clothingKeywords = [
      'clothing',
      'apparel',
      'shirt',
      'pants',
      'dress',
      'shoe',
      'fabric',
      'textile',
      'jeans',
      'footwear'
    ];
    final electronicsKeywords = [
      'electronics',
      'gadget',
      'computer',
      'phone',
      'laptop',
      'screen',
      'device',
      'appliance',
      'audio',
      'television'
    ];
    final furnitureKeywords = [
      'furniture',
      'chair',
      'table',
      'desk',
      'sofa',
      'couch',
      'bed',
      'cabinet',
      'wood',
      'room',
      'seating'
    ];
    final booksKeywords = [
      'book',
      'paper',
      'document',
      'text',
      'reading',
      'novel',
      'magazine'
    ];

    for (var label in labels) {
      if (clothingKeywords.any((k) => label.contains(k)))
        return 'Clothing & Apparel';
      if (electronicsKeywords.any((k) => label.contains(k)))
        return 'Electronics & Gadgets';
      if (furnitureKeywords.any((k) => label.contains(k)))
        return 'Furniture & Home Goods';
      if (booksKeywords.any((k) => label.contains(k))) return 'Books & Media';
    }

    return 'Miscellaneous/Other';
  }
}
