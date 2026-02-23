
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/common/components/domain/salary_list_view.dart';
import 'package:salary/feature/premium_root/premium_time_line/premium_time_line_view_model.dart';

class PremiumTimeLineScreen extends ConsumerWidget {
  const PremiumTimeLineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final state = ref.watch(premiumTimeLineProvider);

    return PublicSalaryListView(
      salaries: state.salaries,
      hasMore: (state.currentPage) < (state.lastPage),
      isLoadingMore: state.isLoadingMore,
      onLoadMore: () {
        ref.read(premiumTimeLineProvider.notifier)
            .loadNextPage();
      },
      onRefresh: () {
        return ref
            .read(premiumTimeLineProvider.notifier)
            .refresh();
      },
    );
  }
}