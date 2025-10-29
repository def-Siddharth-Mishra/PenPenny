import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:penpenny/core/events/global_events.dart';
import 'package:penpenny/core/theme/theme_colors.dart';
import 'package:penpenny/domain/entities/account.dart';
import 'package:penpenny/presentation/blocs/accounts/accounts_bloc.dart';
import 'package:penpenny/presentation/widgets/common/confirm_dialog.dart';
import 'package:penpenny/presentation/widgets/common/currency_text.dart';
import 'package:penpenny/presentation/widgets/dialogs/account_form_dialog.dart';

String maskAccount(String value, [int lastLength = 4]) {
  if (value.length < 4) return value;
  int length = value.length - lastLength;
  String generated = "";
  if (length > 0) {
    generated += value.substring(0, length).split("").map((e) => e == " " ? " " : "X").join("");
  }
  generated += value.substring(length);
  return generated;
}

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();

    globalEventEmitter.on(GlobalEventType.accountUpdate.name, (data) {
      debugPrint("accounts are changed");
      context.read<AccountsBloc>().add(LoadAccounts());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Accounts",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
      ),
      body: BlocBuilder<AccountsBloc, AccountsState>(
        builder: (context, state) {
          if (state is AccountsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is AccountsLoaded && state.accounts.isNotEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              itemCount: state.accounts.length,
              itemBuilder: (builder, index) {
                Account account = state.accounts[index];
                GlobalKey accKey = GlobalKey();
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: account.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.holderName.isEmpty ? "---" : account.holderName,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                                  ),
                                  Text(
                                    account.name,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    account.accountNumber.isEmpty ? "---" : maskAccount(account.accountNumber),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Total Balance",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          CurrencyText(
                            account.balance,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Income",
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    CurrencyText(
                                      account.income,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Expense",
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                    ),
                                    CurrencyText(
                                      account.expense,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      right: 15,
                      bottom: 40,
                      child: Icon(account.icon, size: 20, color: account.color),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        key: accKey,
                        onPressed: () {
                          final RenderBox renderBox = accKey.currentContext?.findRenderObject() as RenderBox;
                          final Size size = renderBox.size;
                          final Offset offset = renderBox.localToGlobal(Offset.zero);

                          showMenu(
                            context: context,
                            position: RelativeRect.fromLTRB(
                              offset.dx,
                              offset.dy + size.height,
                              offset.dx + size.width,
                              offset.dy + size.height,
                            ),
                            items: [
                              PopupMenuItem<String>(
                                value: '1',
                                child: const Text('Edit'),
                                onTap: () {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    showDialog(
                                      context: context,
                                      builder: (builder) => AccountFormDialog(account: account),
                                    );
                                  });
                                },
                              ),
                              PopupMenuItem<String>(
                                value: '2',
                                child: const Text(
                                  'Delete',
                                  style: TextStyle(color: ThemeColors.error),
                                ),
                                onTap: () {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    ConfirmDialog.show(
                                      context,
                                      title: "Are you sure?",
                                      content: "All the payments will be deleted belongs to this account",
                                    ).then((confirmed) {
                                      if (confirmed == true) {
                                        context.read<AccountsBloc>().add(DeleteAccount(account.id!));
                                      }
                                    });
                                  });
                                },
                              ),
                            ],
                          );
                        },
                        icon: const Icon(Icons.more_vert, size: 20),
                      ),
                    )
                  ],
                );
              },
            );
          }
          
          // Empty state
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_balance,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No accounts yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add your first account to get started',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (builder) => const AccountFormDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}