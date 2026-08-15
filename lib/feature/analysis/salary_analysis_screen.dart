import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/ad_banner_widget.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/models/salary.dart';
import 'package:salary/core/utils/custom_colors.dart';
import 'package:salary/core/utils/date_time_utils.dart';
import 'package:salary/core/utils/number_utils.dart';
import 'package:salary/feature/analysis/components/comparison_view.dart';
import 'package:salary/feature/analysis/components/item_summary_view.dart';
import 'salary_analysis_state.dart';
import 'salary_analysis_view_model.dart';

class SalaryAnalysisScreen extends ConsumerStatefulWidget {
  const SalaryAnalysisScreen({super.key});

  @override
  ConsumerState<SalaryAnalysisScreen> createState() => _SalaryAnalysisScreenState();
}

class _SalaryAnalysisScreenState extends ConsumerState<SalaryAnalysisScreen> {
  int _selectedSegment = 0;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CustomColors.foundation(context),
      navigationBar: const CupertinoNavigationBar(
        middle: CustomText(
          text: '給与ディープ分析',
          fontWeight: FontWeight.bold,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<int>(
                  groupValue: _selectedSegment,
                  children: const {
                    0: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('月別比較', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                    1: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('項目別累計', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  },
                  onValueChanged: (value) {
                    if (value != null) setState(() => _selectedSegment = value);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedSegment == 0 ? const ComparisonView() : const ItemSummaryView(),
            ),
            const AdMobBannerWidget(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}