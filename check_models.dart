import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  const apiKey = 'AQ.Ab8RN6K1Xstwb4L1xZ-kpm4iWj7QCGfCIx1eZg06pa991fsdfsdds';
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    for (var model in json['models']) {
      if (model['name'].contains('flash')) {
        print(model['name']);
        print(model['supportedGenerationMethods']);
      }
    }
  } else {
    print('Error: ${response.body}');
  }
}
