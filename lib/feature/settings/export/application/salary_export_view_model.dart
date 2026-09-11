import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salary/core/providers/global_error_provider.dart';
import 'package:salary/core/providers/premium_function_state_notifier.dart';
import 'package:salary/core/repository/domain/local_salary_repository.dart';
import 'package:salary/core/utils/logger.dart';
import 'package:salary/feature/settings/export/data/salary_share_service.dart';
import 'package:salary/feature/settings/export/domain/salary_csv_converter.dart';
import 'package:salary/feature/settings/export/domain/salary_export_access.dart';

final salaryShareServiceProvider = Provider<SalaryShareService>((ref) {
  return const SharePlusSalaryShareService();
});

final salaryExportProvider = Provider<SalaryExportViewModel>((ref) {
  return SalaryExportViewModel(
    ref: ref,
    localSalaryRepository: ref.read(localSalaryRepositoryProvider),
    shareService: ref.read(salaryShareServiceProvider),
    readPremiumState: () => ref.read(premiumFunctionStateProvider),
  );
});

enum SalaryExportResult { shared, locked }

class SalaryExportViewModel {
  final Ref _ref;
  final LocalSalaryRepository _localSalaryRepository;
  final SalaryShareService _shareService;
  final PremiumFunctionState Function() _readPremiumState;
  final SalaryCsvConverter _converter;

  SalaryExportViewModel({
    required Ref ref,
    required LocalSalaryRepository localSalaryRepository,
    required SalaryShareService shareService,
    required PremiumFunctionState Function() readPremiumState,
    SalaryCsvConverter converter = const SalaryCsvConverter(),
  }) :  _ref = ref,
        _localSalaryRepository = localSalaryRepository,
        _shareService = shareService,
        _readPremiumState = readPremiumState,
        _converter = converter;

  /// テストやUIからも同じプレミアム判定を利用できるようにする。
  bool get canExport => SalaryExportAccess.isAllowed(_readPremiumState());

  Future<SalaryExportResult> export({Rect? sharePositionOrigin}) async {
    if (!canExport) {
      return SalaryExportResult.locked;
    }
    await _ref.runWithGlobalHandling(() async {
      final salaries = _localSalaryRepository.fetchAll();
      final bytes = _converter.convertToUtf8Bom(salaries);
      try {
        await _shareService.share(
          bytes,
          fileName: _createFileName(),
          sharePositionOrigin: sharePositionOrigin,
        );
      } catch(e) {
        logger('CSV変換失敗$e');
      }
    });
    return SalaryExportResult.shared;
  }

  String _createFileName() {
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return 'salary_export_$timestamp.csv';
  }
}
