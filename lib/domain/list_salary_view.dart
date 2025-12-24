import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:realm/realm.dart';
import 'package:salary/models/salary.dart';
import 'package:salary/models/thema_color.dart';
import 'package:salary/utilities/custom_colors.dart';
import 'package:salary/utilities/number_utils.dart';
import 'package:salary/viewmodels/reverpod/payment_source_notifier.dart';
import 'package:salary/viewmodels/reverpod/salary_notifier.dart';
import 'package:salary/common/components/custom_text_view.dart';
import 'package:salary/domain/detail/detail_salary_view.dart';
import 'package:salary/domain/input/input_salary_view.dart';

class SalaryListView extends StatefulWidget {
  const SalaryListView({super.key});

  @override
  State<SalaryListView> createState() => _SalaryListViewState();
}

class _SalaryListViewState extends State<SalaryListView> {
  /// Salaryに存在する支払い元リスト
  List<PaymentSource> _sourceList = [];
  /// 表示中の支払い元
  late PaymentSource _selectedSource = _allSource;

  /// "全て" を表すダミーの PaymentSource を作成
  final PaymentSource _allSource = PaymentSource(
    Uuid.v4().toString(),
    'ALL',
    ThemaColor.blue.value,
  );

  @override
  Widget build(BuildContext context) {
    // Scaffold配下にCupertinoPageScaffold(iOS UI)を設置しないと
    // Textのスタイルが黄色い下線になってしまう
    return Scaffold(
      body: CupertinoPageScaffold(
        backgroundColor: CustomColors.foundation,
        navigationBar: CupertinoNavigationBar(
          middle: const CustomText(
            text: 'シンプル給料記録',
            fontWeight: FontWeight.bold,
          ),
          leading: _buildSourceSelector(),
          trailing: CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.add_circled_solid, size: 28),
            onPressed: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => const InputSalaryView(salary: null),
                ),
              );
            },
          ),
        ),
        child: Consumer(
          builder: (context, ref, child) {
            final salaries = ref.watch(salaryProvider);
            final paymentSources = ref.watch(paymentSourceProvider);
            _sourceList = [];
            // paymentSourcesにinsertするとRealmに保存されてしまうので注意
            _sourceList = [
              _allSource,
              ...paymentSources,
            ];
            if (salaries.isEmpty) {
              return const Center(
                  child: CustomText(
                    text: 'データがありません',
                    fontWeight: FontWeight.bold,
                  )
              );
            }
            return ListView.builder(
              itemCount: salaries.length,
              itemBuilder: (context, index) {
                final salary = salaries[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => DetailSalaryView(id: salary.id),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 1),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      // 角丸
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 年月UI
                        Container(
                          padding: const EdgeInsets.all(8),
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color:
                                salary.source?.themaColorEnum.color ??
                                CustomColors.thema,
                            // 角丸
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: '${salary.createdAt.year}年',
                                textSize: TextSize.S,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),

                              CustomText(
                                text: !salary.isBonus ? '${salary.createdAt.month}月' :  '${salary.createdAt.month}月(賞)',
                                textSize: !salary.isBonus ? TextSize.ML :  TextSize.SS,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: switch (salary.source?.name) {
                                  String name => name,
                                  _ => '未設定',
                                },
                                textSize: TextSize.S,
                                color: CustomColors.text.withValues(alpha: 0.7),
                              ),
                              // 給料詳細UI
                              // 総支給
                              _buildSalaryRow('総支給', salary.paymentAmount),
                              // 手取り
                              _buildSalaryRow('手取り', salary.netSalary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// **給与の支払い元を選択するUI (MenuAnchor)**
  Widget _buildSourceSelector() {
    return Consumer(builder: (_, ref, _) {
      return MenuAnchor(
        builder: (context, controller, child) {
          return GestureDetector(
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: const Icon(Icons.filter_list, size: 28),
          );
        },
        menuChildren:
        _sourceList.map((source) {
          return MenuItemButton(
            onPressed: () {
              setState(() {
                _selectedSource = source;
                if (source == _allSource) {
                  ref.read(salaryProvider.notifier).fetchAll();
                } else {
                  ref.read(salaryProvider.notifier).fetchFilter(source.name);
                }
              });
            },
            child: SizedBox(
              width: 200,
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.building_2_fill,
                    color: source.themaColorEnum.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: CustomText(text: source.name, fontWeight: FontWeight.bold)),
                  if (_selectedSource == source)
                    const Icon(CupertinoIcons.checkmark_alt),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  /// ラベルと金額表示UI
  Widget _buildSalaryRow(String label, int amount) {
    return Row(
      children: [
        const Spacer(),
        CustomText(text: label, textSize: TextSize.S),
        const SizedBox(width: 15),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomText(
              text: NumberUtils.formatWithComma(amount),
              textSize: TextSize.L,
              color: CustomColors.thema,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(width: 5),
            const CustomText(text: '円', textSize: TextSize.S),
          ],
        ),
      ],
    );
  }
}
