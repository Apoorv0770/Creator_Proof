import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

import '../models/proof_model.dart';
import 'hash_service.dart';

class CertificateService {
  static Future<void> generateAndShare(ProofModel proof) async {
    try {
      // Create certificate image using Flutter's painting
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      const width = 800.0;
      const height = 1000.0;

      // Background
      final bgPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF020617), Color(0xFF0F172A)],
        ).createShader(const Rect.fromLTWH(0, 0, width, height));
      canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

      // Border gradient
      final borderPaint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF00D1FF), Color(0xFF7C3AED)],
        ).createShader(const Rect.fromLTWH(0, 0, width, height))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(20, 20, width - 40, height - 40),
            const Radius.circular(24)),
        borderPaint,
      );

      // Title
      final titlePainter = TextPainter(
        text: const TextSpan(
          text: 'CERTIFICATE OF CREATION',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      titlePainter.layout();
      titlePainter.paint(canvas, Offset((width - titlePainter.width) / 2, 60));

      // Verified badge
      final verifiedPainter = TextPainter(
        text: TextSpan(
          text: proof.isVerified
              ? '✓ BLOCKCHAIN VERIFIED'
              : 'PENDING VERIFICATION',
          style: TextStyle(
            color: proof.isVerified
                ? const Color(0xFF10B981)
                : const Color(0xFFF59E0B),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      verifiedPainter.layout();
      verifiedPainter.paint(
          canvas, Offset((width - verifiedPainter.width) / 2, 100));

      // Work title
      final workPainter = TextPainter(
        text: TextSpan(
          text: proof.title,
          style: const TextStyle(
            color: Color(0xFF00D1FF),
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      workPainter.layout(maxWidth: width - 80);
      workPainter.paint(canvas, Offset((width - workPainter.width) / 2, 160));

      // Creator
      final creatorPainter = TextPainter(
        text: TextSpan(
          text: 'Created by ${proof.creatorName}',
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      creatorPainter.layout();
      creatorPainter.paint(
          canvas, Offset((width - creatorPainter.width) / 2, 220));

      // Date
      final datePainter = TextPainter(
        text: TextSpan(
          text: DateFormat('MMMM d, yyyy • HH:mm UTC').format(proof.createdAt),
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      datePainter.layout();
      datePainter.paint(canvas, Offset((width - datePainter.width) / 2, 250));

      // Details section
      _drawSection(canvas, 'DIGITAL FINGERPRINT',
          HashService.formatHashForDisplay(proof.fileHash), 320, width);

      if (proof.transactionHash != null) {
        _drawSection(
            canvas,
            'BLOCKCHAIN TRANSACTION',
            HashService.formatHashForDisplay(proof.transactionHash!),
            420,
            width);
        _drawSection(
            canvas, 'BLOCK NUMBER', '${proof.blockNumber}', 480, width);
        _drawSection(canvas, 'NETWORK', 'Polygon', 520, width);
      }

      _drawSection(canvas, 'CATEGORY', proof.categoryDisplayName.toUpperCase(),
          580, width);
      _drawSection(
          canvas, 'FILE TYPE', proof.fileType.toUpperCase(), 620, width);

      // License info
      if (proof.license != null) {
        _drawSection(
            canvas, 'LICENSE', proof.license!.type.toUpperCase(), 680, width);
      }

      // Footer
      final footerPainter = TextPainter(
        text: const TextSpan(
          text: 'Verify at creatorproof.app/verify',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      footerPainter.layout();
      footerPainter.paint(
          canvas, Offset((width - footerPainter.width) / 2, height - 60));

      // Logo
      final logoPainter = TextPainter(
        text: const TextSpan(
          text: 'CREATOR PROOF',
          style: TextStyle(
            color: Color(0xFF00D1FF),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        textDirection: ui.TextDirection.ltr,
      );
      logoPainter.layout();
      logoPainter.paint(
          canvas, Offset((width - logoPainter.width) / 2, height - 80));

      // Convert to image
      final picture = recorder.endRecording();
      final image = await picture.toImage(width.toInt(), height.toInt());
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return;

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'certificate_${proof.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Certificate of Creation for "${proof.title}" by ${proof.creatorName}',
      );
    } catch (e) {
      print('Error generating certificate: $e');
      rethrow;
    }
  }

  static void _drawSection(
      Canvas canvas, String label, String value, double y, double width) {
    final labelPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
            color: Colors.white38, fontSize: 11, letterSpacing: 2),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset((width - labelPainter.width) / 2, y));

    final valuePainter = TextPainter(
      text: TextSpan(
        text: value,
        style: const TextStyle(
            color: Colors.white, fontSize: 14, fontFamily: 'monospace'),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    valuePainter.layout(maxWidth: width - 80);
    valuePainter.paint(
        canvas, Offset((width - valuePainter.width) / 2, y + 16));
  }

  static String generateVerificationUrl(ProofModel proof) {
    return 'https://creatorproof.app/verify/${proof.fileHash}';
  }

  static String generateQRData(ProofModel proof) {
    return '''
CREATOR PROOF CERTIFICATE
========================
Title: ${proof.title}
Creator: ${proof.creatorName}
Hash: ${proof.fileHash}
${proof.transactionHash != null ? 'TX: ${proof.transactionHash}' : ''}
Verified: ${proof.isVerified ? 'Yes' : 'Pending'}
Date: ${proof.createdAt.toIso8601String()}
Verify: ${generateVerificationUrl(proof)}
''';
  }
}
