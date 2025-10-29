import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:penpenny/core/theme/theme_colors.dart';
import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/presentation/widgets/common/currency_text.dart';

class DismissiblePaymentItem extends StatefulWidget {
  final Payment payment;
  final VoidCallback onTap;
  final Function(Payment) onDelete;

  const DismissiblePaymentItem({
    super.key,
    required this.payment,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<DismissiblePaymentItem> createState() => _DismissiblePaymentItemState();
}

class _DismissiblePaymentItemState extends State<DismissiblePaymentItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isCredit = widget.payment.type == PaymentType.credit;
    
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Dismissible(
          key: Key('payment_${widget.payment.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: ThemeColors.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 24,
            ),
          ),
          confirmDismiss: (direction) async {
            return await _showDeleteConfirmation(context);
          },
          onDismissed: (direction) {
            widget.onDelete(widget.payment);
            _showUndoSnackBar(context);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: widget.onTap,
              leading: Hero(
                tag: 'payment_icon_${widget.payment.id}',
                child: Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: widget.payment.category.color.withOpacity(0.1),
                  ),
                  child: Icon(
                    widget.payment.category.icon,
                    size: 22,
                    color: widget.payment.category.color,
                  ),
                ),
              ),
              title: Text(
                widget.payment.category.name,
                style: Theme.of(context).textTheme.bodyMedium?.merge(
                  const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.payment.title.isNotEmpty)
                    Text(
                      widget.payment.title,
                      style: Theme.of(context).textTheme.bodySmall?.apply(
                        color: Colors.grey[600],
                      ),
                    ),
                  Text(
                    DateFormat("dd MMM yyyy, HH:mm").format(widget.payment.datetime),
                    style: Theme.of(context).textTheme.bodySmall?.apply(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              trailing: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Theme.of(context).textTheme.bodyMedium?.apply(
                  color: isCredit ? ThemeColors.success : ThemeColors.error,
                  fontWeightDelta: 1,
                ) ?? const TextStyle(),
                child: CurrencyText(
                  isCredit ? widget.payment.amount : -widget.payment.amount,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Transaction'),
          content: Text('Are you sure you want to delete this ${widget.payment.type == PaymentType.credit ? 'income' : 'expense'} transaction?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: ThemeColors.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showUndoSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.payment.type == PaymentType.credit ? 'Income' : 'Expense'} deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // Note: In a real implementation, you'd need to implement undo functionality
            // This would require storing the deleted payment temporarily and restoring it
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Undo functionality would be implemented here'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}