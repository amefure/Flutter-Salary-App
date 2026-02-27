import 'package:flutter/material.dart';
import 'package:salary/core/common/components/ad_banner_widget.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/models/thema_color.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/number_utils.dart';
import 'package:salary/feature/premium/domain/model/public_salary.dart';

/// ===============================
/// Base List View（完全共通）
/// ===============================
class BaseSalaryListView<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final void Function(T item)? onTap;

  final bool showAd;
  final VoidCallback? onLoadMore;
  final Future<void> Function()? onRefresh;

  final bool hasMore;
  final bool isLoadingMore;

  const BaseSalaryListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onTap,
    this.showAd = true,
    this.onLoadMore,
    this.onRefresh,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  State<BaseSalaryListView<T>> createState() =>
      _BaseSalaryListViewState<T>();
}

class _BaseSalaryListViewState<T>
    extends State<BaseSalaryListView<T>> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (!_controller.hasClients) return;

      final threshold =
          _controller.position.maxScrollExtent * 0.8;

      if (_controller.position.pixels >= threshold) {
        if (widget.hasMore &&
            !widget.isLoadingMore &&
            widget.onLoadMore != null) {
          widget.onLoadMore!();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh ?? () async {},
        child: const Center(
          child: CustomText(
            text: 'データがありません',
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh ?? () async {},
            child: ListView.builder(
              controller: _controller,
              itemCount:
              widget.items.length +
                  (widget.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == widget.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final item = widget.items[index];

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => widget.onTap?.call(item),
                  child: widget.itemBuilder(context, item),
                );
              },
            ),
          ),
        ),
        if (widget.showAd) const AdMobBannerWidget(),
      ],
    );
  }
}

/// ===============================
/// 共通カードUI
/// ===============================
class SalaryCard extends StatelessWidget {
  final DateTime date;
  final bool isBonus;
  final Color color;
  final String sourceName;
  final bool isMain;
  final int paymentAmount;
  final int netSalary;

  const SalaryCard({
    super.key,
    required this.date,
    required this.isBonus,
    required this.color,
    required this.sourceName,
    required this.paymentAmount,
    required this.netSalary,
    this.isMain = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin:
      const EdgeInsets.only(left: 20, right: 20, top: 1),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _DateBox(
            date: date,
            isBonus: isBonus,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isMain)
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber,
                      ),
                    CustomText(
                      text: sourceName,
                      textSize: TextSize.S,
                      color: CustomColors.text(context)
                          .withValues(alpha: 0.7),
                    ),
                  ],
                ),
                _SalaryRow(
                  label: '総支給',
                  amount: paymentAmount,
                ),
                _SalaryRow(
                  label: '手取り',
                  amount: netSalary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// 日付Box
/// ===============================
class _DateBox extends StatelessWidget {
  final DateTime date;
  final bool isBonus;
  final Color color;

  const _DateBox({
    required this.date,
    required this.isBonus,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: '${date.year}年',
            textSize: TextSize.S,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          CustomText(
            text: !isBonus
                ? '${date.month}月'
                : '${date.month}月(賞)',
            textSize:
            !isBonus ? TextSize.ML : TextSize.SS,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// 金額Row
/// ===============================
class _SalaryRow extends StatelessWidget {
  final String label;
  final int amount;

  const _SalaryRow({
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        CustomText(text: label, textSize: TextSize.S),
        const SizedBox(width: 15),
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            CustomText(
              text:
              NumberUtils.formatWithComma(amount),
              textSize: TextSize.L,
              color: CustomColors.thema,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(width: 5),
            const CustomText(
              text: '円',
              textSize: TextSize.S,
            ),
          ],
        ),
      ],
    );
  }
}

/// ===============================
/// Salary 用
/// ===============================
class SalaryListView extends StatelessWidget {
  final List<Salary> salaries;
  final void Function(Salary salary)? onTap;
  final bool showAd;
  final VoidCallback? onLoadMore;
  final Future<void> Function()? onRefresh;
  final bool hasMore;
  final bool isLoadingMore;

  const SalaryListView({
    super.key,
    required this.salaries,
    this.onTap,
    this.showAd = true,
    this.onLoadMore,
    this.onRefresh,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return BaseSalaryListView<Salary>(
      items: salaries,
      onTap: onTap,
      showAd: showAd,
      onLoadMore: onLoadMore,
      onRefresh: onRefresh,
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
      itemBuilder: (_, salary) => SalaryCard(
        date: salary.createdAt,
        isBonus: salary.isBonus,
        color: salary.source?.themaColorEnum.color
            ?? CustomColors.thema,
        sourceName: salary.source?.name ?? '未設定',
        isMain: salary.source?.isMain ?? false,
        paymentAmount: salary.paymentAmount,
        netSalary: salary.netSalary,
      ),
    );
  }
}

/// ===============================
/// PublicSalary 用
/// ===============================
class PublicSalaryListView extends StatelessWidget {
  final List<PublicSalary> salaries;
  final void Function(PublicSalary salary)? onTap;
  final bool showAd;
  final VoidCallback? onLoadMore;
  final Future<void> Function()? onRefresh;
  final bool hasMore;
  final bool isLoadingMore;

  const PublicSalaryListView({
    super.key,
    required this.salaries,
    this.onTap,
    this.showAd = true,
    this.onLoadMore,
    this.onRefresh,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return BaseSalaryListView<PublicSalary>(
      items: salaries,
      onTap: onTap,
      showAd: showAd,
      onLoadMore: onLoadMore,
      onRefresh: onRefresh,
      hasMore: hasMore,
      isLoadingMore: isLoadingMore,
      itemBuilder: (_, salary) => SalaryCard(
        date: salary.paidAt,
        isBonus: salary.isBonus,
        color: salary.paymentSource?.themaColorEnum.color ?? ThemaColor.blue.color,
        sourceName: salary.user.profile.job,
        paymentAmount: salary.paymentAmount,
        netSalary: salary.netSalary,
      ),
    );
  }
}