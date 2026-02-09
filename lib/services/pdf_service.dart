import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note.dart';

class PdfService {
  Future<void> exportNoteToPdf(Note note) async {
    final pdf = pw.Document();

    // Load Google Fonts
    final font = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Title
                pw.Text(
                  note.title.isEmpty ? "Untitled Note" : note.title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),

                // Creation Date
                pw.Text(
                  "Created: ${_formatDate(note.createdDate)}",
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 8),

                // Tags
                if (note.tags.isNotEmpty) ...[
                  pw.Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: note.tags.map((tag) {
                      return pw.Container(
                        padding: const pw.EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: PdfColors.grey200,
                          borderRadius: pw.BorderRadius.circular(4),
                        ),
                        child: pw.Text(
                          tag,
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      );
                    }).toList(),
                  ),
                  pw.SizedBox(height: 12),
                ],

                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 12),

                // Content
                pw.Text(
                  note.content,
                  style: const pw.TextStyle(
                    fontSize: 14,
                    lineSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ];
        },
      ),
    );

    try {
      final bytes = await pdf.save();

      // Get valid filename
      final safeTitle = note.title.trim().isEmpty
          ? "note"
          : note.title.trim().replaceAll(RegExp(r'[^\w\s]+'), '');
      final fileName = "${safeTitle.replaceAll(' ', '_')}.pdf";

      if (kIsWeb) {
        // On Web, simple share/download from bytes
        await Share.shareXFiles(
          [
            XFile.fromData(
              bytes,
              name: fileName,
              mimeType: 'application/pdf',
            ),
          ],
          text: 'Sharing note: ${note.title}',
        );
      } else {
        // On Mobile/Desktop, save to local storage then share
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');

        await file.writeAsBytes(bytes);

        // Share the file
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Sharing note: ${note.title}',
        );
      }
    } catch (e) {
      print("Error generating or sharing PDF: $e");
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
