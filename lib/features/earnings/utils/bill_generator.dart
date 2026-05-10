import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class BillGenerator {
  static Future<String?> generateBillPng({
    required String driverName,
    required String mobile,
    required String weekPeriod,
    required double weeklyEarning,
    required double cash,
    required double tax,
    required double toll,
    required double rent,
    required double uberSubscription,
    required double adjustment,
    required double other,
    required double netAmount,
  }) async {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: 'Rs.');
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(600, 800);
    
    // Background
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    
    // Header Gradient
    final headerRect = const Rect.fromLTWH(0, 0, 600, 120);
    final headerGradient = const LinearGradient(
      colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
    ).createShader(headerRect);
    canvas.drawRect(headerRect, Paint()..shader = headerGradient);
    
    // Header Text
    _drawText(canvas, 'RANGREJ FLEET', 30, Colors.white, const Offset(30, 30), isBold: true);
    _drawText(canvas, 'Weekly Earnings Statement', 18, Colors.white70, const Offset(30, 70));
    _drawText(canvas, DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()), 14, Colors.white, const Offset(400, 70));

    // Driver Info
    _drawText(canvas, 'Driver Information', 20, Colors.black87, const Offset(30, 150), isBold: true);
    _drawText(canvas, 'Name: $driverName', 16, Colors.black87, const Offset(30, 180));
    _drawText(canvas, 'Mobile: $mobile', 16, Colors.black87, const Offset(30, 205));
    _drawText(canvas, 'Week: $weekPeriod', 16, Colors.black87, const Offset(30, 230));
    
    // Table Header
    final tableHeaderPaint = Paint()..color = const Color(0xFFF3F4F6);
    canvas.drawRect(const Rect.fromLTWH(30, 270, 540, 40), tableHeaderPaint);
    _drawText(canvas, 'Description', 16, Colors.black87, const Offset(50, 280), isBold: true);
    _drawText(canvas, 'Amount', 16, Colors.black87, const Offset(480, 280), isBold: true);
    
    // Rows
    double y = 320;
    
    void addRow(String desc, double amount, {bool isDeduction = false}) {
      if (amount == 0) return;
      _drawText(canvas, desc, 16, Colors.black87, Offset(50, y));
      final amountStr = isDeduction ? '- ${formatCurrency.format(amount)}' : '+ ${formatCurrency.format(amount)}';
      final color = isDeduction ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71);
      _drawText(canvas, amountStr, 16, color, Offset(460, y), isBold: true);
      
      // Divider
      canvas.drawLine(Offset(30, y + 25), Offset(570, y + 25), Paint()..color = const Color(0xFFE5E7EB)..strokeWidth = 1);
      y += 40;
    }

    addRow('Weekly Earning', weeklyEarning);
    addRow('Cash Deduction', cash, isDeduction: true);
    addRow('Tax Deduction', tax, isDeduction: true);
    addRow('Toll Addition', toll);
    addRow('Rent Deduction', rent, isDeduction: true);
    addRow('Uber Subscription', uberSubscription, isDeduction: true);
    if (adjustment > 0) addRow('Adjustment', adjustment);
    if (other > 0) addRow('Other Deduction', other, isDeduction: true);

    // Net Amount Box
    y += 20;
    final netBoxPaint = Paint()..color = netAmount >= 0 ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(30, y, 540, 60), const Radius.circular(8)), netBoxPaint);
    _drawText(canvas, 'Net Amount', 22, Colors.white, Offset(50, y + 15), isBold: true);
    _drawText(canvas, formatCurrency.format(netAmount), 24, Colors.white, Offset(420, y + 13), isBold: true);

    // Footer
    _drawText(canvas, 'This is a computer generated statement.', 14, Colors.black54, const Offset(180, 740));
    _drawText(canvas, 'Rangrej Fleet Management System', 14, Colors.black87, const Offset(195, 760), isBold: true);

    // Render Image
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.width.toInt(), size.height.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
    
    if (pngBytes != null) {
      final dir = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
      final path = '${dir.path}/${driverName.replaceAll(' ', '_')}_Earnings_$dateStr.png';
      final file = File(path);
      await file.writeAsBytes(pngBytes.buffer.asUint8List());
      return path;
    }
    return null;
  }

  static void _drawText(Canvas canvas, String text, double fontSize, Color color, Offset offset, {bool isBold = false}) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }
}
