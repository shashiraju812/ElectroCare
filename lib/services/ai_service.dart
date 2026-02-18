class AiService {
  // Simple heuristic-based categorization
  // In a real app, this would call a TFLite model or an API like Gemini
  static String predictCategory(String description) {
    final text = description.toLowerCase();

    if (text.contains('wire') ||
        text.contains('spark') ||
        text.contains('short') ||
        text.contains('fuse') ||
        text.contains('socket') ||
        text.contains('plug')) {
      return 'Wiring';
    }

    if (text.contains('fan') ||
        text.contains('ac') ||
        text.contains('air condition') ||
        text.contains('light') ||
        text.contains('bulb') ||
        text.contains('tube')) {
      return 'Installation'; // Or Repair, context dependent, but defaulting for now
    }

    if (text.contains('fix') ||
        text.contains('broken') ||
        text.contains('not working') ||
        text.contains('repair')) {
      return 'Repair';
    }

    return 'Inspection'; // Default safe category
  }
}
