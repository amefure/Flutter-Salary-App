import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/common/components/empty_state_view.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/core/models/annual_withholding.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/feature/annual_withholding/annual_withholding_view_model.dart';
import 'package:salary/feature/annual_withholding/components/annual_withholding_editor_modal.dart';
import 'package:salary/feature/annual_withholding/components/annual_withholding_list_item.dart';
import 'package:salary/feature/annual_withholding/components/annual_withholding_summary_card.dart';
import 'package:salary/feature/annual_withholding/domain/annual_withholding_labels.dart';

class AnnualWithholdingScreen extends ConsumerStatefulWidget {
  const AnnualWithholdingScreen({super.key});

  @override
  ConsumerState<AnnualWithholdingScreen> createState() =>
      _AnnualWithholdingScreenState();
}

class _AnnualWithholdingScreenState
    extends ConsumerState<AnnualWithholdingScreen> {
  final _numberFormatter = NumberFormat('#,###');
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year;
  }

  List<AnnualWithholding> get _itemsForSelectedYear {
    final state = ref.read(annualWithholdingProvider);
    final items =
    state.items.where((item) => item.year == _selectedYear).toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  List<PaymentSource> get _paymentSources {
    return ref.read(annualWithholdingProvider).paymentSources;
  }

  int get _totalPaymentAmount {
    return _itemsForSelectedYear.fold<int>(
      0,
          (sum, item) => sum + item.paymentAmount,
    );
  }

  int get _totalTaxAmount {
    return _itemsForSelectedYear.fold<int>(
      0,
          (sum, item) => sum + item.incomeTaxAmount,
    );
  }

  String _paymentSourceName(String? paymentSourceId) {
    if (paymentSourceId == null || paymentSourceId.isEmpty) {
      return AnnualWithholdingLabels.unknownPaymentSource;
    }
    for (final source in _paymentSources) {
      if (source.id == paymentSourceId) {
        return source.name;
      }
    }
    return AnnualWithholdingLabels.unknownPaymentSource;
  }

  Future<void> _showYearPicker() async {
    final years = List<int>.generate(
      31,
          (index) => DateTime.now().year - 15 + index,
    );
    var selectedIndex = years.indexOf(_selectedYear);
    if (selectedIndex < 0) {
      selectedIndex = years.length ~/ 2;
    }

    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) {
        var pickerIndex = selectedIndex;
        return Container(
          height: 260,
          decoration: BoxDecoration(
            color: CustomColors.background(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CustomText(
                      text: AnnualWithholdingLabels.chooseYear,
                      fontWeight: FontWeight.bold,
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() => _selectedYear = years[pickerIndex]);
                      },
                      child: const CustomText(
                        text: AnnualWithholdingLabels.pickerDone,
                        color: CustomColors.thema,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    pickerIndex = index;
                  },
                  children: [
                    for (final year in years)
                      Center(
                        child: CustomText(
                          text: '$year${AnnualWithholdingLabels.yearSuffix}',
                          textSize: TextSize.MS,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showEditor({AnnualWithholding? existing}) async {
    final sources = _paymentSources;
    if (sources.isEmpty) {
      await AppDialog.show(
        context: context,
        message: '支払い元を登録してください。',
        type: DialogType.error,
      );
      return;
    }

    await Navigator.of(context).push<void>(
      CupertinoPageRoute(
        builder: (context) => AnnualWithholdingEditorModal(
          existing: existing,
          selectedYear: _selectedYear,
          paymentSources: sources,
          onSaved: (item) {
            final isSaved = ref
                .read(annualWithholdingProvider.notifier)
                .save(item: item);
            if (!isSaved) {
              AppDialog.show(
                context: context,
                message: AnnualWithholdingLabels.duplicateWarning,
                type: DialogType.error,
              );
              return false;
            }
            return true;
          },
        ),
      ),
    );
  }

  void _confirmDelete(String id) async {
    final result = await AppDialog.show(
      context: context,
      message: AnnualWithholdingLabels.deleteConfirm,
      type: DialogType.confirm,
      positiveTitle: '削除',
      isPositiveNegativeType: true,
    );
    if (result ?? false) {
      ref.read(annualWithholdingProvider.notifier).deleteById(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _itemsForSelectedYear;

    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
        middle: CustomText(
          text: AnnualWithholdingLabels.screenTitle,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            AnnualWithholdingSummaryCard(
              selectedYear: _selectedYear,
              totalPaymentAmount: _totalPaymentAmount,
              totalTaxAmount: _totalTaxAmount,
              onTapYear: _showYearPicker,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CustomText(
                  text: '登録一覧',
                  fontWeight: FontWeight.bold,
                  textSize: TextSize.MS,
                ),
                CupertinoButton.filled(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  onPressed: () => _showEditor(),
                  child: const CustomText(
                    text: AnnualWithholdingLabels.addNew,
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                    textSize: TextSize.S,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: const Center(
                  child: EmptyStateView(message: AnnualWithholdingLabels.emptyState, icon: CupertinoIcons.collections),
                ),
              )
            else
              ...items.map((item) {
                return AnnualWithholdingListItem(
                  item: item,
                  paymentSourceName: _paymentSourceName(item.paymentSourceId),
                  numberFormatter: _numberFormatter,
                  onTap: () => _showEditor(existing: item),
                  onDelete: () => _confirmDelete(item.id),
                );
              }),
          ],
        ),
      ),
    );
  }
}