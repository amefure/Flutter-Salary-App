import 'package:flutter/material.dart';
import 'package:salary/core/common/components/ad_banner_widget.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/number_utils.dart';

class SalaryListView extends StatefulWidget {
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
  State<SalaryListView> createState() => _SalaryListViewState();
}

class _SalaryListViewState extends State<SalaryListView> {
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
    if (widget.salaries.isEmpty) {
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
              widget.salaries.length +
                  (widget.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == widget.salaries.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final salary = widget.salaries[index];

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      widget.onTap?.call(salary),
                  child: _SalaryItem(salary: salary),
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


class _SalaryItem extends StatelessWidget {
  final Salary salary;

  const _SalaryItem({required this.salary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 1),
      decoration: BoxDecoration(
        color: CustomColors.background(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildDateBox(),
          const SizedBox(width: 10),
          Expanded(child: _buildRightContent(context)),
        ],
      ),
    );
  }

  Widget _buildDateBox() {
    return Container(
      padding: const EdgeInsets.all(8),
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: salary.source?.themaColorEnum.color ??
            CustomColors.thema,
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
            text: !salary.isBonus
                ? '${salary.createdAt.month}月'
                : '${salary.createdAt.month}月(賞)',
            textSize:
            !salary.isBonus ? TextSize.ML : TextSize.SS,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
  }

  Widget _buildRightContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (salary.source?.isMain ?? false)
              const Icon(Icons.star, size: 14, color: Colors.amber),
            CustomText(
              text: salary.source?.name ?? '未設定',
              textSize: TextSize.S,
              color:
              CustomColors.text(context).withValues(alpha: 0.7),
            ),
          ],
        ),
        _buildSalaryRow('総支給', salary.paymentAmount),
        _buildSalaryRow('手取り', salary.netSalary),
      ],
    );
  }

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