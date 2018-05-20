import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart';

import 'package:test/test.dart';

import '../tool/gen_golden.dart' as golden;

Iterable<File> getGoldenFileNames() sync* {
  final Directory dir = new Directory(join(dirname(Platform.script.path),
      dirname(Platform.script.path).endsWith('test') ? '..' : '', 'golden'));
  for (FileSystemEntity fe in dir.listSync(recursive: true)) {
    if (fe is File && fe.path.toLowerCase().endsWith('.png')) {
      yield fe;
    }
  }
}

String getSvgAssetName(String goldenFileName) {
  return goldenFileName
      .replaceAll('/golden/', '/assets/')
      .replaceAll('\\golden\\', '\\assets\\')
      .replaceAll('.png', '.svg');
}

void main() {
  test('SVG Rendering matches golden files', () async {
    for (File goldenFile in getGoldenFileNames()) {
      final File svgAssetFile = new File(getSvgAssetName(goldenFile.path));
      final Uint8List bytes =
          await golden.getSvgPngBytes(await svgAssetFile.readAsString());

      final Uint8List goldenBytes = await goldenFile.readAsBytes();
      if (goldenFile.path.contains('Ghost')) {
        final File tmp = new File('/Users/dnfield/tmp/gstiger2.png');
        tmp.writeAsBytesSync(bytes);
      }
      expect(bytes, orderedEquals(goldenBytes),
          reason:
              '${goldenFile.path} does not match rendered output of ${svgAssetFile.path}!');
    }
  });
}