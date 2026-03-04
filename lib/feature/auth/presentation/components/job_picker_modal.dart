import 'package:flutter/material.dart';
import 'package:salary/core/common/components/custom/custom_text_view.dart';
import 'package:salary/core/config/profile_config.dart';
import 'package:salary/core/utils/custom_colors.dart';

class JobPickerModal extends StatefulWidget {
  final Job currentJob;

  const JobPickerModal({super.key, required this.currentJob});

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
    for (var i = 0; i < ProfileConfig.jobCategories.length; i++) {
      if (ProfileConfig.jobCategories[i].jobs.contains(widget.currentJob.name)) {
        _selectedCategoryIndex = i;
        _selectedJobCategory = ProfileConfig.jobCategories[i].name;
        _selectedJob = widget.currentJob.name;
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final category = ProfileConfig.jobCategories[_selectedCategoryIndex];

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: CustomColors.foundation(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          /// タイトル
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
              children: [
                /// 左：カテゴリリスト
                Container(
                  width: 140,
                  color: CustomColors.textBlack,
                  child: ListView.builder(
                    itemCount: ProfileConfig.jobCategories.length,
                    itemBuilder: (_, index) {
                      final cat = ProfileConfig.jobCategories[index];
                      final selected = index == _selectedCategoryIndex;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          color: selected ? CustomColors.thema.withAlpha(90) : CustomColors.textBlack,
                          child: CustomText(
                            text: cat.name,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            textSize: TextSize.S,
                            color: CustomColors.textWhite,
                            maxLines: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// 右：職種リスト
                Expanded(
                  child: ListView.builder(
                    itemCount: category.jobs.length,
                    itemBuilder: (_, index) {
                      final job = category.jobs[index];
                      final selected = job == _selectedJob;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedJobCategory = ProfileConfig.jobCategories[index].name;
                            _selectedJob = job;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: selected ? CustomColors.thema.withAlpha(50) : CustomColors.background(context),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected ? CustomColors.thema : Colors.grey[300]!,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: CustomText(
                            text: job,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            textSize: TextSize.S,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          /// 決定ボタン
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedJob != null ? CustomColors.thema : Colors.grey[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _selectedJob != null
                    ? () => Navigator.pop(context, Job(category: _selectedJobCategory!, name: _selectedJob!))
                    : null,
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
}