import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AIService {
  String get _apiKey => dotenv.env['AI_API_KEY'] ?? '';

  /// Generate personalized styling advice using Gemini API
  /// Sends clothing image and user profile context for analysis
  Future<String> generateStylingAdvice({
    required File clothingImage,
    required String gender,
    String? profileImageUrl,
    double? height,
    double? weight,
  }) async {
    try {
      if (_apiKey.isEmpty || _apiKey == 'YOUR_GEMINI_API_KEY') {
        return _getMockStylingAdvice(gender);
      }

      // Read clothing image as base64
      final clothingBytes = await clothingImage.readAsBytes();
      final clothingBase64 = base64Encode(clothingBytes);

      // Build the prompt
      final prompt = _buildPrompt(
        gender: gender,
        height: height,
        weight: weight,
      );

      // Prepare the request parts
      final List<Map<String, dynamic>> parts = [
        {'text': prompt},
        {
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': clothingBase64,
          }
        },
      ];

      // If profile image URL is available, mention it in text
      // (Gemini can analyze the clothing image directly)
      final requestBody = {
        'contents': [
          {
            'parts': parts,
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 500,
        },
      };

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? _getMockStylingAdvice(gender);
      } else {
        print('AI API Error: ${response.statusCode} - ${response.body}');
        return _getMockStylingAdvice(gender);
      }
    } catch (e) {
      print('AI Service Error: $e');
      return _getMockStylingAdvice(gender);
    }
  }

  /// Generate styling advice with both clothing and profile images
  Future<String> generateAdviceWithProfileImage({
    required File clothingImage,
    required File profileImage,
    required String gender,
    double? height,
    double? weight,
  }) async {
    try {
      if (_apiKey.isEmpty || _apiKey == 'YOUR_GEMINI_API_KEY') {
        return _getMockStylingAdvice(gender);
      }

      final clothingBytes = await clothingImage.readAsBytes();
      final clothingBase64 = base64Encode(clothingBytes);

      final profileBytes = await profileImage.readAsBytes();
      final profileBase64 = base64Encode(profileBytes);

      final prompt = _buildPromptWithProfile(
        gender: gender,
        height: height,
        weight: weight,
      );

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': profileBase64,
                }
              },
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': clothingBase64,
                }
              },
            ],
          }
        ],
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 500,
        },
      };

      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
        return text ?? _getMockStylingAdvice(gender);
      } else {
        print('AI API Error: ${response.statusCode} - ${response.body}');
        // Fallback to single-image analysis
        return generateStylingAdvice(
          clothingImage: clothingImage,
          gender: gender,
          height: height,
          weight: weight,
        );
      }
    } catch (e) {
      print('AI Service Error (dual image): $e');
      return generateStylingAdvice(
        clothingImage: clothingImage,
        gender: gender,
        height: height,
        weight: weight,
      );
    }
  }

  String _buildPrompt({
    required String gender,
    double? height,
    double? weight,
  }) {
    final heightStr = height != null ? '${height.toStringAsFixed(0)} cm' : 'not specified';
    final weightStr = weight != null ? '${weight.toStringAsFixed(0)} kg' : 'not specified';

    return '''
You are a professional fashion stylist. Analyze this clothing item image and provide personalized styling advice.

User profile:
- Gender: $gender
- Height: $heightStr
- Weight: $weightStr

Please provide:
1. Color suitability — does this color generally complement common skin tones? Would it enhance or dull appearance?
2. Styling suggestions — recommend bottom wear pairing, footwear, and accessories (appropriate for $gender)
3. Occasion suitability — what occasions is this piece best suited for?

Guidelines:
- Keep response to 5-8 lines maximum
- Use an elegant, fashion-focused tone
- Be specific and actionable
- Start with a complimentary observation about the piece
''';
  }

  String _buildPromptWithProfile({
    required String gender,
    double? height,
    double? weight,
  }) {
    final heightStr = height != null ? '${height.toStringAsFixed(0)} cm' : 'not specified';
    final weightStr = weight != null ? '${weight.toStringAsFixed(0)} kg' : 'not specified';

    return '''
You are a professional fashion stylist. I'm providing two images:
1. First image: The user's profile photo — use this to estimate their skin tone and basic body shape
2. Second image: A clothing item they're considering

User profile:
- Gender: $gender
- Height: $heightStr
- Weight: $weightStr

Based on both images, provide personalized styling advice:
1. Color suitability — does this clothing color match the user's skin tone? Does it enhance or dull their appearance?
2. Styling suggestions — recommend bottom wear pairing, footwear, and accessories (appropriate for $gender)
3. Occasion suitability — what occasions is this piece best suited for?

Guidelines:
- Keep response to 5-8 lines maximum
- Use an elegant, fashion-focused tone
- Be specific and personalized based on the user's appearance
- Start with an observation about how this piece complements the user
''';
  }

  /// Fallback mock styling advice when API is unavailable
  String _getMockStylingAdvice(String gender) {
    if (gender.toLowerCase() == 'female') {
      return '''✨ This piece carries a beautiful silhouette that flatters most body types with its structured yet relaxed fit.

🎨 The color palette works wonderfully with warm and neutral skin tones, adding a soft glow to your complexion.

👗 Pair with high-waisted tailored trousers or a flowing midi skirt for an effortlessly chic look. Complete the ensemble with pointed-toe heels or elegant mules.

💎 Accessorize with delicate gold jewelry — layered necklaces and minimal hoop earrings would elevate this beautifully.

🌟 Perfect for brunch dates, gallery visits, or a polished day-to-evening transition.''';
    } else {
      return '''✨ This piece offers a clean, modern cut that pairs versatility with understated sophistication.

🎨 The tonal quality complements a wide range of skin tones, creating a balanced and refined appearance.

👔 Style with slim-fit chinos or well-tailored dark denim. White sneakers keep it casual; leather loafers elevate the look.

⌚ A classic watch and minimal leather accessories would complete this ensemble with effortless polish.

🌟 Ideal for smart-casual settings — weekend outings, dinner reservations, or relaxed office environments.''';
    }
  }
}
