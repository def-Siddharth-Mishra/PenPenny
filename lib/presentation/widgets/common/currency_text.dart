import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/core/utils/currency_helper.dart';
import 'package:penpenny/presentation/blocs/app_settings/app_settings_bloc.dart';

class CurrencyText extends StatelessWidget {
  final double? amount;
  final TextStyle? style;
  final TextOverflow? overflow;
  final CurrencyService currencyService = CurrencyService();

  CurrencyText(this.amount, {super.key, this.style, this.overflow});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, state) {
        Currency? currency = currencyService.findByCode(
          state.settings.currency ?? 'USD',
        );
        return Text(
          amount == null
              ? "${currency!.symbol} "
              : CurrencyHelper.format(
                  amount!,
                  name: currency?.code,
                  symbol: currency?.symbol,
                ),
          style: style,
          overflow: overflow,
        );
      },
    );
  }
}
