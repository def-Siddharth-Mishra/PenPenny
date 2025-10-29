import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:penpenny/core/data/app_icons.dart';
import 'package:penpenny/core/events/global_events.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/presentation/blocs/accounts/accounts_bloc.dart';
import 'package:penpenny/presentation/widgets/common/app_button.dart';

typedef Callback = void Function();

class AccountFormDialog extends StatefulWidget {
  final Account? account;
  final Callback? onSave;

  const AccountFormDialog({super.key, this.account, this.onSave});

  @override
  State<StatefulWidget> createState() => _AccountFormState();
}

class _AccountFormState extends State<AccountFormDialog> {
  Account? _account;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _account = Account(
        id: widget.account!.id,
        name: widget.account!.name,
        holderName: widget.account!.holderName,
        accountNumber: widget.account!.accountNumber,
        icon: widget.account!.icon,
        color: widget.account!.color,
      );
    } else {
      _account = const Account(
        name: "",
        holderName: "",
        accountNumber: "",
        icon: Icons.account_circle,
        color: Colors.grey,
      );
    }
  }

  void onSave(BuildContext context) async {
    if (widget.account != null) {
      context.read<AccountsBloc>().add(UpdateAccount(_account!));
    } else {
      context.read<AccountsBloc>().add(CreateAccount(_account!));
    }
    
    if (widget.onSave != null) {
      widget.onSave!();
    }
    Navigator.pop(context);
    globalEventEmitter.emit(GlobalEventType.accountUpdate.name);
  }

  @override
  Widget build(BuildContext context) {
    if (_account == null) {
      return const CircularProgressIndicator();
    }
    return AlertDialog(
      title: Text(
        widget.account != null ? "Edit Account" : "New Account",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      scrollable: true,
      insetPadding: const EdgeInsets.all(20),
      content: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: _account!.color,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  alignment: Alignment.center,
                  child: Icon(_account!.icon, color: Colors.white),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextFormField(
                    initialValue: _account!.name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      hintText: 'Account name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    ),
                    onChanged: (String text) {
                      setState(() {
                        _account = _account!.copyWith(name: text);
                      });
                    },
                  ),
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 20, top: 20),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Holder name',
                  hintText: 'Enter account holder name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                ),
                initialValue: _account!.holderName,
                onChanged: (text) {
                  setState(() {
                    _account = _account!.copyWith(holderName: text);
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 20),
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'A/C Number',
                  hintText: 'Enter account number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                ),
                initialValue: _account!.accountNumber,
                onChanged: (text) {
                  setState(() {
                    _account = _account!.copyWith(accountNumber: text);
                  });
                },
              ),
            ),
            // Color picker
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppIcons.colors.length,
                itemBuilder: (BuildContext context, index) => Container(
                  width: 45,
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _account = _account!.copyWith(color: AppIcons.colors[index]);
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppIcons.colors[index],
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          width: 2,
                          color: _account!.color.value == AppIcons.colors[index].value
                              ? Colors.white
                              : Colors.transparent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            // Icon picker
            SizedBox(
              height: 45,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AppIcons.icons.length,
                itemBuilder: (BuildContext context, index) => Container(
                  width: 45,
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 2.5, vertical: 2.5),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _account = _account!.copyWith(icon: AppIcons.icons[index]);
                      });
                    },
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: _account!.icon == AppIcons.icons[index]
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        AppIcons.icons[index],
                        color: Theme.of(context).colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        AppButton(
          height: 45,
          isFullWidth: true,
          onPressed: () {
            onSave(context);
          },
          color: Theme.of(context).colorScheme.primary,
          label: "Save",
        )
      ],
    );
  }
}