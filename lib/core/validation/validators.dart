import 'package:penpenny/domain/entities/payment.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/domain/entities/category.dart';

class ValidationResult {
  final Map<String, String> errors;
  
  const ValidationResult(this.errors);
  
  bool get isValid => errors.isEmpty;
  bool get hasErrors => errors.isNotEmpty;
  
  String? getError(String field) => errors[field];
}

class PaymentValidator {
  static ValidationResult validate(Payment payment) {
    final errors = <String, String>{};
    
    if (payment.amount <= 0) {
      errors['amount'] = 'Amount must be greater than 0';
    }
    
    if (payment.amount > 1000000) {
      errors['amount'] = 'Amount cannot exceed 1,000,000';
    }
    
    if (payment.title.trim().isEmpty) {
      errors['title'] = 'Title is required';
    }
    
    if (payment.title.length > 100) {
      errors['title'] = 'Title cannot exceed 100 characters';
    }
    
    if (payment.description.length > 500) {
      errors['description'] = 'Description cannot exceed 500 characters';
    }
    
    final now = DateTime.now();
    final maxFutureDate = now.add(const Duration(days: 365));
    final minPastDate = now.subtract(const Duration(days: 365 * 10));
    
    if (payment.datetime.isAfter(maxFutureDate)) {
      errors['datetime'] = 'Date cannot be more than 1 year in the future';
    }
    
    if (payment.datetime.isBefore(minPastDate)) {
      errors['datetime'] = 'Date cannot be more than 10 years in the past';
    }
    
    return ValidationResult(errors);
  }
}

class AccountValidator {
  static ValidationResult validate(Account account) {
    final errors = <String, String>{};
    
    if (account.name.trim().isEmpty) {
      errors['name'] = 'Account name is required';
    }
    
    if (account.name.length > 50) {
      errors['name'] = 'Account name cannot exceed 50 characters';
    }
    
    if (account.holderName.trim().isEmpty) {
      errors['holderName'] = 'Holder name is required';
    }
    
    if (account.holderName.length > 100) {
      errors['holderName'] = 'Holder name cannot exceed 100 characters';
    }
    
    if (account.accountNumber.trim().isEmpty) {
      errors['accountNumber'] = 'Account number is required';
    }
    
    if (account.accountNumber.length > 20) {
      errors['accountNumber'] = 'Account number cannot exceed 20 characters';
    }
    
    // Validate account number format (basic check)
    if (!RegExp(r'^[a-zA-Z0-9\-_]+$').hasMatch(account.accountNumber)) {
      errors['accountNumber'] = 'Account number contains invalid characters';
    }
    
    return ValidationResult(errors);
  }
}

class CategoryValidator {
  static ValidationResult validate(Category category) {
    final errors = <String, String>{};
    
    if (category.name.trim().isEmpty) {
      errors['name'] = 'Category name is required';
    }
    
    if (category.name.length > 50) {
      errors['name'] = 'Category name cannot exceed 50 characters';
    }
    
    if (category.budget < 0) {
      errors['budget'] = 'Budget cannot be negative';
    }
    
    if (category.budget > 1000000) {
      errors['budget'] = 'Budget cannot exceed 1,000,000';
    }
    
    return ValidationResult(errors);
  }
}