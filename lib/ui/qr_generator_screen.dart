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
const Color accentGreen = Color(0xFF4CAF50);
const Color accentBlue = Color(0xFF2196F3);
const Color accentRed = Color(0xFFF44336);
const Color bgColor = Color(0xFFF5F7FA);
const Color cardColor = Color(0xFFFFFFFF);

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
  final TextEditingController _textController = TextEditingController();
  String? _qrData;
  Color _qrColor = Colors.white;
  bool _isSharing = false;
  bool _isPrinting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

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
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _updateQrData(String value) {
    setState(() {
      _qrData = value.trim().isEmpty ? null : value.trim();
    });
  }

  void _resetAll() {
    _textController.clear();
    setState(() {
      _qrData = null;
      _qrColor = Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Create QR Code',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background dengan gradient
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          // Konten utama
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                children: [
                  // Card utama
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 1,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Judul section
                        Center(
                          child: Text(
                            'Generate QR Code',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            'Buat QR code dari teks atau link',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Preview QR Code
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Preview QR Code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Screenshot(
                                controller: _screenshotController,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: _qrColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: _qrData == null || _qrData!.isEmpty
                                      ? Container(
                                          width: 200,
                                          height: 200,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.qr_code_2,
                                                size: 64,
                                                color: Colors.grey.shade400,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Masukkan teks/link\ndi bawah ini',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox(
                                          width: 200,
                                          height: 200,
                                          child: PrettyQrView.data(
                                            data: _qrData!,
                                            decoration: const PrettyQrDecoration(
                                              shape: PrettyQrSmoothSymbol(),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Input field
                        Text(
                          'Input Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: 'https://example.com atau teks apa saja',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: primaryColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.text_fields,
                              color: primaryColor,
                            ),
                            suffixIcon: _qrData != null && _qrData!.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.grey.shade500,
                                    ),
                                    onPressed: () {
                                      _textController.clear();
                                      _updateQrData('');
                                    },
                                  )
                                : null,
                          ),
                          maxLines: 3,
                          minLines: 1,
                          onChanged: _updateQrData,
                        ),

                        const SizedBox(height: 28),

                        // Pilih warna background
                        Text(
                          'Pilih Warna Background QR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: qrColors.map((color) {
                            return GestureDetector(
                              onTap: () => setState(() => _qrColor = color),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _qrColor == color
                                        ? primaryColor
                                        : Colors.grey.shade300,
                                    width: _qrColor == color ? 3 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: _qrColor == color
                                    ? Center(
                                        child: Icon(
                                          Icons.check,
                                          color: primaryColor,
                                          size: 20,
                                        ),
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 32),
                        const Divider(height: 1, color: Colors.grey),
                        const SizedBox(height: 24),

                        // Tombol Reset dan Share
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _resetAll,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: accentRed,
                                  side: BorderSide(color: accentRed),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.restart_alt, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Reset',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSharing || _qrData == null || _qrData!.isEmpty
                                    ? null
                                    : () async {
                                        if (_qrData == null || _qrData!.isEmpty) {
                                          _showSnackBar('Masukkan teks/link terlebih dahulu');
                                          return;
                                        }

                                        setState(() {
                                          _isSharing = true;
                                        });

                                        try {
                                          await Future.delayed(
                                              const Duration(milliseconds: 50));

                                          final Uint8List? imageBytes =
                                              await _screenshotController.capture(
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  disabledBackgroundColor: Colors.grey.shade300,
                                ),
                                child: _isSharing
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.share, size: 20),
                                          SizedBox(width: 8),
                                          Text(
                                            'Share QR',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Tombol Print ke Printer
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isPrinting || _qrData == null || _qrData!.isEmpty
                                ? null
                                : _generateAndPrintPdf,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                            child: _isPrinting
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.print, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        'Print QR ke Printer',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tombol Export PDF
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isPrinting || _qrData == null || _qrData!.isEmpty
                                ? null
                                : _savePdfToFile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              disabledBackgroundColor: Colors.grey.shade300,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.picture_as_pdf, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Buat & Bagikan PDF',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Info
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.blue.shade100,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'QR Code akan otomatis tersimpan sebagai gambar',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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