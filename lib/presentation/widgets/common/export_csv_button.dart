import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/presentation/blocs/payments/payments_bloc.dart';

class ExportCsvButton extends StatelessWidget {
  const ExportCsvButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaymentsBloc, PaymentsState>(
      builder: (context, state) {
        if (state is! PaymentsLoaded || state.payments.isEmpty) {
          return const SizedBox.shrink();
        }

        return ElevatedButton.icon(
          onPressed: () => _exportToCsv(context, state.payments),
          icon: const Icon(Icons.download),
          label: const Text('Export CSV'),
        );
      },
    );
  }

  Future<void> _exportToCsv(BuildContext context, List<Payment> payments) async {
    try {
      final csvContent = _generateCsvContent(payments);
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${directory.path}/penpenny_transactions_$timestamp.csv');
      
      await file.writeAsString(csvContent);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transactions exported to ${file.path}'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _generateCsvContent(List<Payment> payments) {
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('Date,Time,Type,Category,Account,Amount,Title,Description');
    
    // CSV Data
    for (final payment in payments) {
      final date = DateFormat('yyyy-MM-dd').format(payment.datetime);
      final time = DateFormat('HH:mm:ss').format(payment.datetime);
      final type = payment.type == PaymentType.credit ? 'Income' : 'Expense';
      final category = _escapeCsvField(payment.category.name);
      final account = _escapeCsvField(payment.account.holderName ?? 'Unknown');
      final amount = payment.amount.toString();
      final title = _escapeCsvField(payment.title);
      final description = _escapeCsvField(payment.description);
      
      buffer.writeln('$date,$time,$type,$category,$account,$amount,$title,$description');
    }
    
    return buffer.toString();
  }

  String _escapeCsvField(String field) {
    // Escape quotes and wrap in quotes if contains comma, quote, or newline
    if (field.contains(',') || field.contains('"') || field.contains('\n')) {
      return '"${field.replaceAll('"', '""')}"';
    }
    return field;
  }
}