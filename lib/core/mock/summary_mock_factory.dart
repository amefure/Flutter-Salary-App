import 'package:salary/feature/premium/data/dto/income_distribution_dto.dart';
import 'package:salary/feature/premium/data/dto/public_profile_dto.dart';
import 'package:salary/feature/premium/data/dto/public_user_dto.dart';
import 'package:salary/feature/premium/data/dto/ranking_dto.dart';
import 'package:salary/feature/premium/data/dto/summary_dto.dart';

abstract class SummaryMockFactory {
  static SummaryDto create() {
    // グラフ用のサンプルデータ
    final List<IncomeDistributionDto> rawDistribution = [
      IncomeDistributionDto(incomeRange: '300〜400万', userCount: 12),
      IncomeDistributionDto(incomeRange: '500〜600万', userCount: 48),
      IncomeDistributionDto(incomeRange: '700〜800万', userCount: 18),
      IncomeDistributionDto(incomeRange: '1000〜1100万', userCount: 5),
      IncomeDistributionDto(incomeRange: '1400万〜', userCount: 3),
    ];

    // ランキング用のサンプルデータ (Top 10)
    final jobs = ['エンジニア', 'コンサル', '営業', '会計士', '医師', 'デザイナー', '人事', '建築士', 'マーケ', '公務員'];
    final regions = ['東京都', '神奈川県', '大阪府', '愛知県', '福岡県'];

    final List<RankingDto> top10 = List.generate(10, (index) {
      final amount = 10000000 - (index * 400000);
      return RankingDto(
        userId: 1000 + index,
        year: 2024,
        totalPaymentAmount: amount,
        totalNetSalary: (amount * 0.7).toInt(),
        user: PublicUserDto(
          id: 1000 + index,
          name: 'ユーザー${index + 1}',
          profile: PublicProfileDto(
            jobCategory: '専門職',
            job: jobs[index],
            region: regions[index % regions.length],
            ageRange: '30代',
          ),
        ),
      );
    });

    return SummaryDto(
      top10: top10,
      distribution: rawDistribution.withZeroFilled(),
    );
  }
}