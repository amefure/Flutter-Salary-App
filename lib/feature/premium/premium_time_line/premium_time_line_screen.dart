import 'package:flutter/material.dart';
import 'package:salary/core/common/components/custom_filter_chip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/domain/salary_list_view.dart';
import 'package:salary/core/config/profile_config.dart';
import 'package:salary/feature/auth/presentation/components/job_picker_modal.dart';
import 'package:salary/feature/premium/premium_time_line/premium_time_line_view_model.dart';

class PremiumTimeLineScreen extends ConsumerWidget {
  const PremiumTimeLineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumTimeLineProvider);
    final notifier = ref.read(premiumTimeLineProvider.notifier);

    return Column(
      children: [
        /// ====== フィルターエリア ======
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              CustomFilterChip(
                label: !state.isUndefinedJob ? state.selectedJob.name : 'すべての職種',
                onTap: () => _showJobPicker(context, ref),
              ),
              // const SizedBox(width: 8),
              // FilterChip(
              //   label: '${state.selectedYear}年',
              //   onTap: () => _showYearPicker(context, ref),
              // ),
              // const SizedBox(width: 8),
              // FilterChip(
              //   label: state.selectedRegion ?? 'すべての地域',
              //   onTap: () => _showRegionPicker(context, ref),
              // ),
            ],
          ),
        ),

        /// リストエリア（Expanded で残りの画面を埋める）
        Expanded(
          child: PublicSalaryListView(
            salaries: state.salaries,
            hasMore: (state.currentPage) < (state.lastPage),
            isLoadingMore: state.isLoadingMore,
            onLoadMore: () => notifier.loadNextPage(),
            onRefresh: () => notifier.refresh(),
          ),
        ),
      ],
    );
  }

  /// 職種選択ピッカーを表示
  void _showJobPicker(BuildContext context, WidgetRef ref) async {
    final state = ref.read(premiumTimeLineProvider);
    final notifier = ref.read(premiumTimeLineProvider.notifier);
    final selected = await showModalBottomSheet<Job>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => JobPickerModal(
        currentJob: state.selectedJob,
        showNoneOption: true,
      ),
    );

    if (selected != null) {
      notifier.updateFilter(job: selected);
    }
  }
}