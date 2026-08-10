import 'package:flutter_test/flutter_test.dart';
import 'package:letraverse/features/update/update_checker.dart';

void main() {
  final checker = UpdateChecker();

  group('parseSemver', () {
    test('parses a well-formed three-part version', () {
      expect(checker.parseSemver('1.2.3'), [1, 2, 3]);
    });

    test('pads missing parts with zero', () {
      expect(checker.parseSemver('1.2'), [1, 2, 0]);
      expect(checker.parseSemver('1'), [1, 0, 0]);
    });

    test('treats non-numeric parts as zero instead of throwing', () {
      expect(checker.parseSemver('1.x.3'), [1, 0, 3]);
    });

    test('ignores extra parts beyond major.minor.patch', () {
      expect(checker.parseSemver('1.2.3.4'), [1, 2, 3]);
    });
  });

  group('isNewer', () {
    test('a higher major/minor/patch is newer', () {
      expect(checker.isNewer('2.0.0', '1.9.9'), isTrue);
      expect(checker.isNewer('1.3.0', '1.2.9'), isTrue);
      expect(checker.isNewer('1.2.4', '1.2.3'), isTrue);
    });

    test('an equal or lower version is not newer', () {
      expect(checker.isNewer('1.2.3', '1.2.3'), isFalse);
      expect(checker.isNewer('1.2.3', '1.3.0'), isFalse);
      expect(checker.isNewer('1.0.0', '2.0.0'), isFalse);
    });

    test('strips a leading "v" from the tag before comparing', () {
      expect(checker.isNewer('v1.1.0', '1.0.5'), isTrue);
      expect(checker.isNewer('v1.0.5', '1.1.0'), isFalse);
    });

    test('a malformed tag never crashes and falls back to not-newer', () {
      expect(() => checker.isNewer('not-a-version', '1.0.0'), returnsNormally);
      expect(checker.isNewer('not-a-version', '1.0.0'), isFalse);
    });
  });
}
