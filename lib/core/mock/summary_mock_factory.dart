import 'package:salary/feature/premium/data/dto/income_distribution_dto.dart';
import 'package:salary/feature/premium/data/dto/public_profile_dto.dart';
import 'package:salary/feature/premium/data/dto/public_user_dto.dart';
import 'package:salary/feature/premium/data/dto/ranking_dto.dart';
import 'package:salary/feature/premium/data/dto/summary_dto.dart';

abstract class SummaryMockFactory {
  static SummaryDto create() {
    // グラフ用のサンプルデータ
    final List<IncomeDistributionDto> rawDistribution = [
      IncomeDistributionDto(incomeRange: '0〜100万', userCount: 3),
      IncomeDistributionDto(incomeRange: '100〜200万', userCount: 4),
      IncomeDistributionDto(incomeRange: '200〜300万', userCount: 10),
      IncomeDistributionDto(incomeRange: '300〜400万', userCount: 12),
      IncomeDistributionDto(incomeRange: '400〜500万', userCount: 24),
      IncomeDistributionDto(incomeRange: '500〜600万', userCount: 20),
      IncomeDistributionDto(incomeRange: '600〜700万', userCount: 18),
      IncomeDistributionDto(incomeRange: '700〜800万', userCount: 18),
      IncomeDistributionDto(incomeRange: '800〜900万', userCount: 14),
      IncomeDistributionDto(incomeRange: '900〜1000万', userCount: 8),
      IncomeDistributionDto(incomeRange: '1000〜1100万', userCount: 2),
      IncomeDistributionDto(incomeRange: '1100〜1200万', userCount: 2),
      IncomeDistributionDto(incomeRange: '1200〜1300万', userCount: 1),
      IncomeDistributionDto(incomeRange: '1300〜1400万', userCount: 0),
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