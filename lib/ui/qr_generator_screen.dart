import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

const Color primaryColor = Color(0xFF3A2EC3);

const List<Color> qrColors = [
  Colors.white,
  Colors.grey,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.cyan,
  Colors.purple,
];

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  String? _qrData;
  Color _qrColor = Colors.white;
  bool _isSharing = false;
  bool _isPrinting = false;

  Future<void> _generateAndPrintPdf() async {
    if (_qrData == null || _qrData!.isEmpty) {
      _showSnackBar('Masukkan teks/link terlebih dahulu');
      return;
    }

    setState(() {
      _isPrinting = true;
    });

    try {
      // Ambil screenshot dengan kualitas tinggi untuk print
      final imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0,
      );
      
      if (imageBytes == null) {
        _showSnackBar('Gagal membuat gambar QR untuk print');
        return;
      }

      final pdf = pw.Document();
      final qrImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                // Header
                pw.Text(
                  'QR CODE',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Dibuat dengan QR S&G App',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey,
                  ),
                ),
                pw.Divider(thickness: 1, color: PdfColors.blue),
                pw.SizedBox(height: 40),

                // QR Code dengan background warna
                pw.Container(
                  padding: const pw.EdgeInsets.all(25),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(_qrColor.value),
                    border: pw.Border.all(color: PdfColors.black, width: 1),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Image(qrImage, width: 250, height: 250),
                ),
                pw.SizedBox(height: 30),

                // Informasi QR Code
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.blue, width: 1),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Data QR Code:',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        _qrData!,
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                      pw.SizedBox(height: 15),
                      pw.Row(
                        children: [
                          pw.Text(
                            'Warna Background: ',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                          pw.Container(
                            width: 20,
                            height: 20,
                            decoration: pw.BoxDecoration(
                              color: PdfColor.fromInt(_qrColor.value),
                              border: pw.Border.all(color: PdfColors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Footer
                pw.Spacer(),
                pw.Divider(thickness: 0.5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Tanggal: ${DateTime.now().toString().split(' ')[0]}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      'QR S&G - QR Generator & Scanner',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontStyle: pw.FontStyle.italic,
                        color: PdfColors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );

      // Print PDF langsung - tanpa save file dulu
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      _showSnackBar('QR code berhasil dikirim ke printer!');
    } catch (e) {
      print('Print Error: $e');
      _showSnackBar('Error saat print: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  Future<void> _savePdfToFile() async {
    if (_qrData == null || _qrData!.isEmpty) {
      _showSnackBar('Masukkan teks/link terlebih dahulu');
      return;
    }

    setState(() {
      _isPrinting = true;
    });

    try {
      final imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0,
      );
      
      if (imageBytes == null) {
        _showSnackBar('Gagal membuat gambar QR');
        return;
      }

      final pdf = pw.Document();
      final qrImage = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text('QR Code',
                    style: pw.TextStyle(
                        fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(_qrColor.value),
                    border: pw.Border.all(color: PdfColors.black),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Image(qrImage, width: 200, height: 200),
                ),
                pw.SizedBox(height: 20),
                pw.Text('Data: $_qrData',
                    style: const pw.TextStyle(fontSize: 14)),
                pw.SizedBox(height: 10),
                pw.Text('Dibuat dengan QR S&G App',
                    style: pw.TextStyle(
                        fontSize: 12, color: PdfColors.grey)),
              ],
            );
          },
        ),
      );

      // Simpan PDF ke temporary directory (lebih aman)
      final bytes = await pdf.save();
      
      // Share langsung sebagai file PDF
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/QR_Code_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      
      // Share file PDF
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'QR Code PDF: $_qrData',
        subject: 'QR Code dari QR S&G App',
      );
      
      _showSnackBar('PDF berhasil dibuat dan siap dibagikan!');
    } catch (e) {
      print('Save PDF Error: $e');
      _showSnackBar('Error: Coba gunakan fitur Print langsung');
    } finally {
      if (mounted) {
        setState(() {
          _isPrinting = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create QR', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(height: 220, color: primaryColor),
              Expanded(child: Container(color: Colors.grey.shade50)),
            ],
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // widget Screenshot
                        Screenshot(
                          controller: _screenshotController,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _qrColor,
                              borderRadius: BorderRadius.circular(16),
                              border:
                                  Border.all(color: Colors.black12, width: 2),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 12,
                                    offset: Offset(0, 4)),
                              ],
                            ),
                            child: _qrData == null || _qrData!.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(40),
                                    child: Text(
                                      'Masukkan teks/link untuk generate QR',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : PrettyQrView.data(
                                    data: _qrData!,
                                    decoration: const PrettyQrDecoration(
                                      shape: PrettyQrSmoothSymbol(),
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // widget TextField input data QR
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Link atau Teks',
                            hintText: 'https://example.com atau teks apa saja',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          maxLines: 3,
                          onChanged: (value) {
                            setState(() => _qrData =
                                value.trim().isEmpty ? null : value.trim());
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Pilih Warna Background QR',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: qrColors.map((color) {
                            return GestureDetector(
                              onTap: () => setState(() => _qrColor = color),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _qrColor == color
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black12, blurRadius: 6),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        const Divider(height: 1),
                        const SizedBox(height: 16),

                        // TOMBOL RESET DAN SHARE
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _qrData = null;
                                    _qrColor = Colors.white;
                                  });
                                },
                                style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red),
                                child: const Text('Reset'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isSharing
                                    ? null
                                    : () async {
                                        if (_qrData == null ||
                                            _qrData!.isEmpty) {
                                          _showSnackBar(
                                              'Masukkan teks/link terlebih dahulu');
                                          return;
                                        }

                                        setState(() {
                                          _isSharing = true;
                                        });

                                        try {
                                          await Future.delayed(
                                              const Duration(milliseconds: 50));

                                          final Uint8List? imageBytes =
                                              await _screenshotController
                                                  .capture(
                                            pixelRatio: MediaQuery.of(context)
                                                .devicePixelRatio,
                                          );

                                          if (imageBytes != null) {
                                            await Share.shareXFiles(
                                              [
                                                XFile.fromData(
                                                  imageBytes,
                                                  name: 'qr_code.png',
                                                  mimeType: 'image/png',
                                                ),
                                              ],
                                              text:
                                                  'QR Code untuk: $_qrData\nDibuat dengan QR S&G',
                                              subject: 'QR Code dari QR S&G App',
                                            );
                                          }
                                        } catch (e) {
                                          print('Error: $e');
                                        } finally {
                                          Future.delayed(
                                              const Duration(seconds: 1), () {
                                            if (mounted) {
                                              setState(() {
                                                _isSharing = false;
                                              });
                                            }
                                          });
                                        }
                                      },
                                icon: _isSharing
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.share),
                                label: Text(
                                    _isSharing ? 'Sharing...' : 'Share QR'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isSharing
                                      ? Colors.grey
                                      : primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // TOMBOL PRINT UTAMA
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isPrinting || _qrData == null || _qrData!.isEmpty
                                ? null
                                : _generateAndPrintPdf,
                            icon: _isPrinting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.print),
                            label: Text(_isPrinting ? 'Printing...' : 'Print QR ke Printer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isPrinting
                                  ? Colors.grey
                                  : Colors.green[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // TOMBOL SAVE AS PDF (SHARE)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isPrinting || _qrData == null || _qrData!.isEmpty
                                ? null
                                : _savePdfToFile,
                            icon: const Icon(Icons.picture_as_pdf, size: 20),
                            label: const Text('Buat & Bagikan PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}