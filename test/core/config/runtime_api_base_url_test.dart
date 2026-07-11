import 'package:flutter_test/flutter_test.dart';
import 'package:goods_carrier/core/config/runtime_api_base_url.dart';

void main() {
  setUp(() {
    RuntimeApiBaseUrl.resetForTest(bootstrap: 'https://bootstrap.example');
  });

  test('normalize strips trailing slashes', () {
    expect(
      RuntimeApiBaseUrl.normalize('https://a.example/'),
      'https://a.example',
    );
  });

  test('set updates current; null/empty ignored', () async {
    await RuntimeApiBaseUrl.set('https://api.example/');
    expect(RuntimeApiBaseUrl.current, 'https://api.example');
    await RuntimeApiBaseUrl.set('  ');
    expect(RuntimeApiBaseUrl.current, 'https://api.example');
  });
}
