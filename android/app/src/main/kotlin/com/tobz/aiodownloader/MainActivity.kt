package com.tobz.aiodownloader

import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.ByteBuffer

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.tobz.aiodownloader/video_processor"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "remuxVideo" -> {
                    val inputPath = call.argument<String>("inputPath")
                    val outputPath = call.argument<String>("outputPath")
                    if (inputPath != null && outputPath != null) {
                        try {
                            remuxVideo(inputPath, outputPath)
                            result.success(outputPath)
                        } catch (e: Exception) {
                            result.error("REMUX_FAILED", e.message, null)
                        }
                    } else {
                        result.error("INVALID_ARGUMENT", "Missing paths", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun remuxVideo(inputPath: String, outputPath: String) {
        val inputFile = File(inputPath)
        if (!inputFile.exists()) {
            throw Exception("Input file does not exist")
        }

        val extractor = MediaExtractor()
        extractor.setDataSource(inputPath)

        val muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        val trackIndexMap = mutableMapOf<Int, Int>()

        // Add all tracks from input to output
        for (i in 0 until extractor.trackCount) {
            val format = extractor.getTrackFormat(i)
            val mimeType = format.getString(MediaFormat.KEY_MIME) ?: ""
            
            // Only process video and audio tracks
            if (mimeType.startsWith("video/") || mimeType.startsWith("audio/")) {
                val trackIndex = muxer.addTrack(format)
                trackIndexMap[i] = trackIndex
            }
        }

        muxer.start()

        // Copy data from input to output
        val buffer = ByteBuffer.allocate(1024 * 1024) // 1MB buffer
        val bufferInfo = android.media.MediaCodec.BufferInfo()

        for (i in 0 until extractor.trackCount) {
            if (trackIndexMap.containsKey(i)) {
                extractor.selectTrack(i)
                
                while (true) {
                    val sampleSize = extractor.readSampleData(buffer, 0)
                    if (sampleSize < 0) break

                    bufferInfo.offset = 0
                    bufferInfo.size = sampleSize
                    bufferInfo.presentationTimeUs = extractor.sampleTime
                    bufferInfo.flags = extractor.sampleFlags

                    muxer.writeSampleData(trackIndexMap[i]!!, buffer, bufferInfo)
                    extractor.advance()
                }
                
                extractor.unselectTrack(i)
                extractor.seekTo(0, MediaExtractor.SEEK_TO_PREVIOUS_SYNC)
            }
        }

        muxer.stop()
        muxer.release()
        extractor.release()
    }
}
