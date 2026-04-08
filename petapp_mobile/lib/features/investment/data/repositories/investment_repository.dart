import 'package:petapp_mobile/features/investment/data/datasources/investment_remote_datasource.dart';
import 'package:petapp_mobile/features/investment/data/models/investment_type_enum.dart';

class InvestmentRepository {
  final InvestmentRemoteDataSource remoteDataSource;

  InvestmentRepository({required this.remoteDataSource});

  Future<void> configureInvestments(List<InvestmentTypeEnum> investments) async {
    return await remoteDataSource.configureInvestments(investments);
  }
}
