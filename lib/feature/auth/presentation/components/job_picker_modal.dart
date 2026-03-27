import 'package:flutter/material.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/config/profile_config.dart';
import 'package:salary/core/utils/custom_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class JobPickerModal extends StatefulWidget {
  final Job currentJob;
  final bool showNoneOption;

  const JobPickerModal({
    super.key,
    required this.currentJob,
    this.showNoneOption = false,
  });

  @override
  State<JobPickerModal> createState() => _JobPickerModalState();
}

class _JobPickerModalState extends State<JobPickerModal> {
  int _selectedCategoryIndex = 0;
  String? _selectedJob;
  String? _selectedJobCategory;

  @override
  void initState() {
    super.initState();
    _initializeSelection();
  }

  void _initializeSelection() {
    if (widget.currentJob.name == ProfileConfig.undefined && widget.showNoneOption) {
      _selectedCategoryIndex = -1;
      _selectedJob = ProfileConfig.undefined;
      _selectedJobCategory = ProfileConfig.undefined;
    } else {
      for (var i = 0; i < ProfileConfig.jobCategories.length; i++) {
        if (ProfileConfig.jobCategories[i].jobs.contains(widget.currentJob.name)) {
          _selectedCategoryIndex = i;
          _selectedJobCategory = ProfileConfig.jobCategories[i].name;
          _selectedJob = widget.currentJob.name;
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 画面の80%の高さを確保
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: CustomColors.foundation(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          /// タイトルエリア
          const Padding(
            padding: EdgeInsets.all(16),
            child: CustomText(
              text: '職種を選択',
              textSize: TextSize.ML,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(height: 1),

          /// カテゴリ・職種リスト
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 左：カテゴリリスト（背景黒）
                Container(
                  width: 140,
                  color: CustomColors.textBlack,
                  child: ListView.builder(
                    itemCount: widget.showNoneOption
                        ? ProfileConfig.jobCategories.length + 1
                        : ProfileConfig.jobCategories.length,
                    itemBuilder: (_, index) {
                      final isNoneTab = widget.showNoneOption && index == 0;
                      final catIdx = widget.showNoneOption ? index - 1 : index;
                      final isSelected = isNoneTab
                          ? _selectedCategoryIndex == -1
                          : _selectedCategoryIndex == catIdx;

                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedCategoryIndex = isNoneTab ? -1 : catIdx;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          color: isSelected ? CustomColors.thema.withAlpha(90) : Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomText(
                                  text: isNoneTab ? '指定なし' : ProfileConfig.jobCategories[catIdx].name,
                                  color: Colors.white,
                                  textSize: TextSize.S,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// 右：職種リスト
                Expanded(
                  child: Container(
                    color: CustomColors.foundation(context),
                    child: _selectedCategoryIndex == -1
                        ? _buildNoneOptionView()
                        : _buildJobListView(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          /// 下部ボタンエリア
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedJob != null ? CustomColors.thema : Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _selectedJob == null ? null : () {
                  final result = _selectedJob == ProfileConfig.undefined
                      ? ProfileConfig.undefinedJob
                      : Job(category: _selectedJobCategory!, name: _selectedJob!);
                  Navigator.pop(context, result);
                },
                child: const CustomText(
                  text: '決定',
                  textSize: TextSize.M,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoneOptionView() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildJobCard(
          label: 'すべての職種を表示',
          isSelected: _selectedJob == ProfileConfig.undefined,
          onTap: () => setState(() {
            _selectedJob = ProfileConfig.undefined;
            _selectedJobCategory = ProfileConfig.undefined;
          }),
        ),
      ],
    );
  }

  Widget _buildJobListView() {
    final jobs = ProfileConfig.jobCategories[_selectedCategoryIndex].jobs;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: jobs.length,
      itemBuilder: (_, index) {
        final jobName = jobs[index];
        return _buildJobCard(
          label: jobName,
          isSelected: _selectedJob == jobName,
          onTap: () => setState(() {
            _selectedJob = jobName;
            _selectedJobCategory = ProfileConfig.jobCategories[_selectedCategoryIndex].name;
          }),
        );
      },
    );
  }

  Widget _buildJobCard({required String label, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? CustomColors.thema.withAlpha(50) : CustomColors.background(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? CustomColors.thema : Colors.grey,
            width: 1,
          ),
        ),
        child: CustomText(
          text: label,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          textSize: TextSize.S,
          maxLines: 2,
        ),
      ),
    );
  }
}