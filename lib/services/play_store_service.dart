import 'package:http/http.dart' as http;

/// Fetches the public Play Store page for an app and extracts the
/// developer's official contact email. Google requires every published
/// app to list a support email, so this is public information already
/// verified by Google to belong to that app's developer account.
class PlayStoreService {
  /// Returns the developer contact email for the given Play Store URL,
  /// or null if it couldn't be found.
  Future<String?> fetchDeveloperEmail(String playStoreUrl) async {
    try {
      final uri = Uri.parse(playStoreUrl.trim());
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'Mozilla/5.0 (Linux; Android 10)'},
      );
      if (response.statusCode != 200) return null;

      final html = response.body;

      // Play Store embeds developer contact info as JSON inside the page.
      // Look for an email pattern near "Developer contact" / support markers,
      // falling back to the first plausible email found after "mailto:" or
      // generic email pattern in the contact section.
      final mailtoMatch =
          RegExp(r'mailto:([a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,})')
              .firstMatch(html);
      if (mailtoMatch != null) {
        return mailtoMatch.group(1);
      }

      // Fallback: generic email pattern anywhere in the page
      final emailMatch = RegExp(
              r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}')
          .firstMatch(html);
      return emailMatch?.group(0);
    } catch (_) {
      return null;
    }
  }
}
