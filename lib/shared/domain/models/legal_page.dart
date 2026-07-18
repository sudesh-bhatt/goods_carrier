class LegalPage {
  const LegalPage({
    required this.title,
    required this.content,
    this.slug = '',
  });

  final String title;
  final String content;
  final String slug;

  bool get hasContent => content.trim().isNotEmpty;

  factory LegalPage.fromJson(Map<String, dynamic> json) {
    return LegalPage(
      title: _firstString(json, const ['title', 'name', 'label']),
      content: _firstString(json, const [
        'content',
        'body',
        'html',
        'description',
        'text',
      ]),
      slug: _firstString(json, const ['slug', 'key', 'code']),
    );
  }

  static String _firstString(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return '';
  }
}
