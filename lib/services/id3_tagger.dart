import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';

/// Minimal ID3v2.3 tag writer — embeds title, artist, album and cover art
/// (APIC frame) directly into an MP3 file without any native plugin.
class Id3Tagger {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 20),
  ));

  /// Embed metadata + cover art into an existing mp3/m4a file at [filePath].
  /// Silently returns on any error so callers never fail due to tagging.
  static Future<void> embedTags({
    required String filePath,
    required String title,
    String artist = '',
    String album = '',
    String coverUrl = '',
  }) async {
    try {
      // Only apply ID3 to mp3 files (m4a/opus use different containers)
      if (!filePath.toLowerCase().endsWith('.mp3')) return;

      // Download cover image bytes
      Uint8List? coverBytes;
      String coverMime = 'image/jpeg';
      if (coverUrl.isNotEmpty) {
        try {
          final res = await _dio.get<List<int>>(
            coverUrl,
            options: Options(responseType: ResponseType.bytes),
          );
          if (res.data != null && res.data!.isNotEmpty) {
            coverBytes = Uint8List.fromList(res.data!);
            // Detect mime from magic bytes
            if (coverBytes.length >= 4) {
              if (coverBytes[0] == 0x89 && coverBytes[1] == 0x50) {
                coverMime = 'image/png';
              } else if (coverBytes[0] == 0xFF && coverBytes[1] == 0xD8) {
                coverMime = 'image/jpeg';
              } else if (coverBytes[0] == 0x47 && coverBytes[1] == 0x49) {
                coverMime = 'image/gif';
              }
            }
          }
        } catch (_) {}
      }

      // Build frames
      final frames = BytesBuilder();
      if (title.isNotEmpty) frames.add(_textFrame('TIT2', title));
      if (artist.isNotEmpty) frames.add(_textFrame('TPE1', artist));
      if (album.isNotEmpty) frames.add(_textFrame('TALB', album));
      if (coverBytes != null) {
        frames.add(_apicFrame(coverBytes, coverMime));
      }

      final framesBytes = frames.toBytes();

      // Read existing file, strip old ID3v2 header if any
      final file = File(filePath);
      final mp3Bytes = await file.readAsBytes();
      int audioStart = 0;
      if (mp3Bytes.length >= 10 &&
          mp3Bytes[0] == 0x49 && // 'I'
          mp3Bytes[1] == 0x44 && // 'D'
          mp3Bytes[2] == 0x33) { // '3'
        final existingTagSize = _readSyncsafe(mp3Bytes, 6);
        audioStart = 10 + existingTagSize;
        // Skip extended header if flagged
        if ((mp3Bytes[5] & 0x40) != 0 && audioStart + 4 < mp3Bytes.length) {
          audioStart += 4 + _bigEndianInt32(mp3Bytes, audioStart);
        }
      }

      // Build new ID3v2.3 header
      final header = BytesBuilder();
      header.add([0x49, 0x44, 0x33]); // "ID3"
      header.add([0x03, 0x00]); // version 2.3, revision 0
      header.add([0x00]); // flags
      header.add(_toSyncsafe(framesBytes.length)); // tag size (excl. header)

      // Write new file
      final out = BytesBuilder(copy: false);
      out.add(header.toBytes());
      out.add(framesBytes);
      out.add(mp3Bytes.sublist(audioStart));

      await file.writeAsBytes(out.toBytes(), flush: true);
    } catch (_) {}
  }


  // Build a text frame (e.g. TIT2 for title, TPE1 for artist, TALB for album).
  static Uint8List _textFrame(String frameId, String text) {
    assert(frameId.length == 4);
    final textBytes = utf8.encode(text);
    // content = encoding(1) + utf8 bytes
    final contentSize = 1 + textBytes.length;
    final b = BytesBuilder();
    b.add(frameId.codeUnits); // frame id
    b.add(_int32(contentSize)); // frame size
    b.add([0x00, 0x00]); // flags
    b.add([0x03]); // encoding: UTF-8
    b.add(textBytes);
    return b.toBytes();
  }

  /// Build an APIC (attached picture) frame.
  static Uint8List _apicFrame(Uint8List imgBytes, String mimeType) {
    final mimeBytes = utf8.encode(mimeType);
    // content = encoding(1) + mime + null(1) + pic_type(1) + desc(0 bytes) + null(1) + img
    final contentSize = 1 + mimeBytes.length + 1 + 1 + 0 + 1 + imgBytes.length;
    final b = BytesBuilder();
    b.add('APIC'.codeUnits);
    b.add(_int32(contentSize));
    b.add([0x00, 0x00]); // flags
    b.add([0x03]); // encoding UTF-8 (unused for description "" but required)
    b.add(mimeBytes);
    b.add([0x00]); // MIME null-terminator
    b.add([0x03]); // picture type: 0x03 = Cover (front)
    // description: empty string, null-terminated
    b.add([0x00]);
    b.add(imgBytes);
    return b.toBytes();
  }

  // Utilities for int<->bytes conversions

  static List<int> _int32(int v) => [
        (v >> 24) & 0xFF,
        (v >> 16) & 0xFF,
        (v >> 8) & 0xFF,
        v & 0xFF,
      ];

  static List<int> _toSyncsafe(int v) => [
        (v >> 21) & 0x7F,
        (v >> 14) & 0x7F,
        (v >> 7) & 0x7F,
        v & 0x7F,
      ];

  static int _readSyncsafe(Uint8List b, int off) =>
      ((b[off] & 0x7F) << 21) |
      ((b[off + 1] & 0x7F) << 14) |
      ((b[off + 2] & 0x7F) << 7) |
      (b[off + 3] & 0x7F);

  static int _bigEndianInt32(Uint8List b, int off) =>
      (b[off] << 24) | (b[off + 1] << 16) | (b[off + 2] << 8) | b[off + 3];
}
