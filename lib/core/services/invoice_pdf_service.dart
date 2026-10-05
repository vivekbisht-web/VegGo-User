import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:vegon_user/core/constants/app_colors.dart';
import 'package:vegon_user/core/constants/app_strings.dart';
import 'package:vegon_user/features/orders/models/order_invoice_response_model.dart';

class InvoicePdfService {
  static Future<void> downloadAndShare(OrderInvoiceData invoice) async {
    try {
      Get.snackbar(
        AppStrings.appName,
        AppStrings.generatingInvoice,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primary,
        colorText: AppColors.surface,
        duration: const Duration(seconds: 2),
      );

      final pdfBytes = await _buildPdf(invoice);

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: _buildFileName(invoice),
      );
    } catch (e) {
      Get.snackbar(
        AppStrings.error,
        AppStrings.invoiceDownloadFailed,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: AppColors.surface,
      );
    }
  }

  static String _buildFileName(OrderInvoiceData invoice) {
    final num =
        invoice.orderNumber?.replaceAll('#', '').replaceAll(' ', '_') ??
        'invoice';
    return 'VegGo_Invoice_$num.pdf';
  }

  static Future<Uint8List> _buildPdf(OrderInvoiceData invoice) async {
    final pdf = pw.Document();

    final ttf = await PdfGoogleFonts.nunitoRegular();
    final ttfBold = await PdfGoogleFonts.nunitoBold();

    final brandColor = PdfColor.fromHex('006A34');
    final lightGreen = PdfColor.fromHex('F1F8F3');
    final borderColor = PdfColor.fromHex('E0E0E0');
    final textSecondary = PdfColor.fromHex('757575');

    String formattedDate = '';
    if (invoice.orderDate != null) {
      try {
        final parsed = DateTime.parse(invoice.orderDate!);
        formattedDate = DateFormat(
          'dd MMM yyyy, hh:mm a',
        ).format(parsed.toLocal());
      } catch (_) {
        formattedDate = invoice.orderDate!;
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: brandColor,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          AppStrings.veggoFresh,
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 22,
                            color: PdfColors.white,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          AppStrings.supportEmail,
                          style: pw.TextStyle(
                            font: ttf,
                            fontSize: 9,
                            color: PdfColors.white,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          AppStrings.invoiceDetails.toUpperCase(),
                          style: pw.TextStyle(
                            font: ttfBold,
                            fontSize: 12,
                            color: PdfColors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (invoice.orderNumber != null) ...[
                          pw.SizedBox(height: 4),
                          pw.Text(
                            invoice.orderNumber!,
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 11,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Info row
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: lightGreen,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            AppStrings.billedTo.toUpperCase(),
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 8,
                              color: brandColor,
                              letterSpacing: 1,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          if (invoice.customerName != null)
                            pw.Text(
                              invoice.customerName!,
                              style: pw.TextStyle(font: ttfBold, fontSize: 11),
                            ),
                          if (invoice.customerPhone != null)
                            pw.Text(
                              invoice.customerPhone!,
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 10,
                                color: textSecondary,
                              ),
                            ),
                          if (invoice.deliveryAddress != null) ...[
                            pw.SizedBox(height: 4),
                            pw.Text(
                              invoice.deliveryAddress!,
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 9,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: lightGreen,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'ORDER DETAILS',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 8,
                              color: brandColor,
                              letterSpacing: 1,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          if (formattedDate.isNotEmpty)
                            _infoRow(
                              AppStrings.date,
                              formattedDate,
                              ttf,
                              ttfBold,
                            ),
                          if (invoice.paymentMethod != null)
                            _infoRow(
                              AppStrings.paymentMethod,
                              invoice.paymentMethod!,
                              ttf,
                              ttfBold,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),

              // Items table
              if (invoice.items != null && invoice.items!.isNotEmpty) ...[
                pw.Text(
                  AppStrings.items.toUpperCase(),
                  style: pw.TextStyle(
                    font: ttfBold,
                    fontSize: 9,
                    color: brandColor,
                    letterSpacing: 1,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Table(
                  border: pw.TableBorder.all(color: borderColor, width: 0.5),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3.5),
                    1: const pw.FlexColumnWidth(1.2),
                    2: const pw.FlexColumnWidth(1.5),
                    3: const pw.FlexColumnWidth(1.5),
                  },
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: brandColor),
                      children: [
                        _tableHeader('ITEM', ttfBold),
                        _tableHeader(
                          'QTY',
                          ttfBold,
                          align: pw.TextAlign.center,
                        ),
                        _tableHeader(
                          'UNIT PRICE',
                          ttfBold,
                          align: pw.TextAlign.right,
                        ),
                        _tableHeader(
                          'TOTAL',
                          ttfBold,
                          align: pw.TextAlign.right,
                        ),
                      ],
                    ),
                    ...invoice.items!.asMap().entries.map((entry) {
                      final i = entry.key;
                      final item = entry.value;
                      final bg = i.isEven
                          ? PdfColors.white
                          : PdfColor.fromHex('FAFAFA');
                      final subtotal =
                          item.subTotal ??
                          ((item.unitPrice ?? 0.0) * (item.quantity ?? 1));
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(color: bg),
                        children: [
                          _tableCell(
                            '${item.productName ?? ''}${item.unit != null ? ' (${item.unit})' : ''}',
                            ttf,
                          ),
                          _tableCell(
                            '${item.quantity ?? 1}',
                            ttf,
                            align: pw.TextAlign.center,
                          ),
                          _tableCell(
                            '${AppStrings.currencySymbol}${(item.unitPrice ?? 0.0).toStringAsFixed(2)}',
                            ttf,
                            align: pw.TextAlign.right,
                          ),
                          _tableCell(
                            '${AppStrings.currencySymbol}${subtotal.toStringAsFixed(2)}',
                            ttfBold,
                            align: pw.TextAlign.right,
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 16),
              ],

              // Summary
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Container(
                  width: 240,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: lightGreen,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      if (invoice.subtotal != null)
                        _summaryRow(
                          AppStrings.subtotal,
                          invoice.subtotal!,
                          ttf,
                          ttfBold,
                        ),
                      if (invoice.deliveryFee != null)
                        _summaryRow(
                          AppStrings.deliveryFee,
                          invoice.deliveryFee!,
                          ttf,
                          ttfBold,
                          freeIfZero: true,
                        ),
                      if (invoice.estimatedTax != null)
                        _summaryRow(
                          AppStrings.estimatedTaxes,
                          invoice.estimatedTax!,
                          ttf,
                          ttfBold,
                        ),
                      if (invoice.promoDiscount != null &&
                          invoice.promoDiscount! > 0)
                        _summaryRow(
                          AppStrings.discount,
                          -invoice.promoDiscount!,
                          ttf,
                          ttfBold,
                          isDiscount: true,
                        ),
                      pw.Divider(color: borderColor, thickness: 0.8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            AppStrings.total.toUpperCase(),
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 13,
                              color: brandColor,
                            ),
                          ),
                          pw.Text(
                            '${AppStrings.currencySymbol}${(invoice.total ?? 0.0).toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 14,
                              color: brandColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              pw.Spacer(),

              // Footer
              pw.Divider(color: borderColor),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  AppStrings.termsFooter,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 8,
                    color: textSecondary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _infoRow(
    String label,
    String value,
    pw.Font ttf,
    pw.Font ttfBold,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 70,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 9,
                color: PdfColor.fromHex('757575'),
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(font: ttfBold, fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _tableHeader(
    String text,
    pw.Font ttfBold, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          font: ttfBold,
          fontSize: 9,
          color: PdfColors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(
    String text,
    pw.Font font, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(font: font, fontSize: 10),
      ),
    );
  }

  static pw.Widget _summaryRow(
    String label,
    double value,
    pw.Font ttf,
    pw.Font ttfBold, {
    bool isDiscount = false,
    bool freeIfZero = false,
  }) {
    final displayValue = freeIfZero && value <= 0
        ? AppStrings.free
        : '${isDiscount ? '-' : ''}${AppStrings.currencySymbol}${value.abs().toStringAsFixed(2)}';

    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: ttf,
              fontSize: 10,
              color: PdfColor.fromHex('757575'),
            ),
          ),
          pw.Text(
            displayValue,
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 10,
              color: isDiscount
                  ? PdfColor.fromHex('2E7D32')
                  : PdfColor.fromHex('212121'),
            ),
          ),
        ],
      ),
    );
  }
}
