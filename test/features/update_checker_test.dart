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

  group('parseVersion', () {
    test('splits semver from the build number', () {
      final v = checker.parseVersion('1.1.0+6');
      expect(v.semver, [1, 1, 0]);
      expect(v.build, 6);
    });

    test('defaults build to 0 when there is no "+" suffix', () {
      final v = checker.parseVersion('1.1.0');
      expect(v.semver, [1, 1, 0]);
      expect(v.build, 0);
    });

    test('treats a non-numeric build as 0 instead of throwing', () {
      final v = checker.parseVersion('1.1.0+abc');
      expect(v.build, 0);
    });
  });

  group('isNewer', () {
    test('a higher major/minor/patch is newer regardless of build number', () {
      expect(checker.isNewer('2.0.0', '1.9.9', '99'), isTrue);
      expect(checker.isNewer('1.3.0', '1.2.9', '99'), isTrue);
      expect(checker.isNewer('1.2.4', '1.2.3', '99'), isTrue);
    });

    test('an equal or lower major/minor/patch (with an equal/lower build) is not newer', () {
      expect(checker.isNewer('1.2.3', '1.2.3', '1'), isFalse);
      expect(checker.isNewer('1.2.3', '1.3.0', '1'), isFalse);
      expect(checker.isNewer('1.0.0', '2.0.0', '1'), isFalse);
    });

    test('same major.minor.patch: a higher build number is newer', () {
      // This is the case scripts/build_release.ps1 hits on every default
      // run -- only the build number changes, major.minor.patch stays put.
      expect(checker.isNewer('1.1.0+6', '1.1.0', '5'), isTrue);
      expect(checker.isNewer('1.1.0+5', '1.1.0', '5'), isFalse);
      expect(checker.isNewer('1.1.0+4', '1.1.0', '5'), isFalse);
    });

    test('a tag with no build suffix is only newer if semver itself is higher', () {
      expect(checker.isNewer('1.1.0', '1.1.0', '5'), isFalse);
      expect(checker.isNewer('1.2.0', '1.1.0', '5'), isTrue);
    });

    test('strips a leading "v" from the tag before comparing', () {
      expect(checker.isNewer('v1.1.0', '1.0.5', '1'), isTrue);
      expect(checker.isNewer('v1.0.5', '1.1.0', '1'), isFalse);
    });

    test('a malformed tag never crashes and falls back to not-newer', () {
      expect(() => checker.isNewer('not-a-version', '1.0.0', '1'), returnsNormally);
      expect(checker.isNewer('not-a-version', '1.0.0', '1'), isFalse);
    });
  });
}
