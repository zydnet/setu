import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:equatable/equatable.dart';
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

class ScanLoading extends ScanState {}

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
  ScanBloc() : super(ScanInitial()) {
    on<ScanImageEvent>(_onScanImage);
  }

  Future<void> _onScanImage(ScanImageEvent event, Emitter<ScanState> emit) async {
    emit(ScanLoading());
    try {
      final bytes = await event.imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('${ApiConstants.geminiVisionUrl}?key=${ApiConstants.geminiApiKey}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [
              {
                'text': 'Analyze this image and identify the item. Determine: 1) What is this item? 2) What category does it belong to (clothing, electronics, books, furniture, or other)? 3) What is its condition (good, fair, poor)? Provide your response as a concise JSON with fields: name, category, condition, description.'
              },
              {
                'inlineData': {
                  'mimeType': 'image/jpeg',
                  'data': base64Image
                }
              }
            ]
          }]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
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
}