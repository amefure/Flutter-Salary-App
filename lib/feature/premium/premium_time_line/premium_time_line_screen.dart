import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:salary/core/common/components/custom_action_picker.dart';
import 'package:salary/core/common/components/custom_filter_chip.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/domain/salary_list_view.dart';
import 'package:salary/core/common/overlay/app_dialog.dart';
import 'package:salary/core/config/profile_config.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/feature/auth/presentation/components/job_picker_modal.dart';
import 'package:salary/feature/premium/premium_time_line/premium_time_line_state.dart';
import 'package:salary/feature/premium/premium_time_line/premium_time_line_view_model.dart';
import 'package:salary/feature/salary/detail_salary/detail_salary_view.dart';

class PremiumTimeLineScreen extends ConsumerWidget {
  const PremiumTimeLineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(premiumTimeLineProvider);
    final viewModel = ref.read(premiumTimeLineProvider.notifier);

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
                onTap: () {
                  final premiumState = ref.read(premiumFunctionStateProvider);
                  if (premiumState.isPremiumFeatureUnlocked) {
                    _showJobPicker(context, viewModel, state);
                  } else {
                    _showIsNotPremiumErrorAlert(context);
                  }
                },
              ),
              CustomFilterChip(
                label: state.selectedRegion ?? 'すべての地域',
                onTap: () {
                  final premiumState = ref.read(premiumFunctionStateProvider);
                  if (premiumState.isPremiumFeatureUnlocked) {
                    _showRegionPicker(context, viewModel, state);
                  } else {
                    _showIsNotPremiumErrorAlert(context);
                  }
                },
              ),
              CustomFilterChip(
                label: state.selectedAgeRange ?? 'すべての年代',
                onTap: () {
                  final premiumState = ref.read(premiumFunctionStateProvider);
                  if (premiumState.isPremiumFeatureUnlocked) {
                    _showAgePicker(context, viewModel, state);
                  } else {
                    _showIsNotPremiumErrorAlert(context);
                  }
                },
              ),
            ],
          ),
        ),

        /// リストエリア（Expanded で残りの画面を埋める）
        Expanded(
          child: PublicSalaryListView(
            onTap: (salary) {
              final state = ref.read(premiumFunctionStateProvider);
              if (state.isPremiumFeatureUnlocked) {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    builder: (_) =>
                        DetailSalaryView(id: salary.id, isPublic: true, jobName: salary.user.profile.job),
                  ),
                );
              } else {
                _showIsNotPremiumErrorAlert(context);
              }
            },
            salaries: state.salaries,
            hasMore: (state.currentPage) < (state.lastPage),
            isLoadingMore: state.isLoadingMore,
            onLoadMore: () => viewModel.loadNextPage(),
            onRefresh: () => viewModel.refresh(),
          ),
        ),
      ],
    );
  }

  void _showIsNotPremiumErrorAlert(BuildContext context) {
    final _ = AppDialog.show(
      context: context,
      message: 'この機能を使用するにはプレミアム機能を解放してください。\n設定から解放することが可能です。',
      type: DialogType.notify,
    );
  }

  /// 職種選択ピッカーを表示
  void _showJobPicker(BuildContext context, PremiumTimeLineViewModel notifier, PremiumTimeLineState state) async {
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

  /// 地域選択ピッカー
  void _showRegionPicker(BuildContext context, PremiumTimeLineViewModel notifier, PremiumTimeLineState state) {
    CustomActionPicker.show<String>(
      context: context,
      title: '地域を選択',
      items: [ProfileConfig.selectNone, ...ProfileConfig.prefectures],
      currentValue: state.selectedRegion ?? ProfileConfig.selectNone,
      labelBuilder: (item) => item,
      onSelected: (selected) {
        notifier.updateFilter(region: selected);
      },
    );
  }
  /// 年代選択ピッカー
  void _showAgePicker(BuildContext context, PremiumTimeLineViewModel notifier, PremiumTimeLineState state) {

    CustomActionPicker.show<String>(
      context: context,
      title: '年代を選択',
      items: ProfileConfig.ages,
      currentValue: state.selectedAgeRange ?? ProfileConfig.selectNone,
      labelBuilder: (item) => item,
      onSelected: (selected) {
        notifier.updateFilter(ageRange: selected);
      },
    );
  }
}