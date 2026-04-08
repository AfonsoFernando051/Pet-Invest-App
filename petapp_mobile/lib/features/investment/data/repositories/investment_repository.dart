import 'package:petapp_mobile/features/investment/data/datasources/investment_remote_datasource.dart';
import 'package:petapp_mobile/features/investment/data/models/investment_type_enum.dart';
import 'package:petapp_mobile/features/investment/data/models/asset_registration_model.dart';

class InvestmentRepository {
  final InvestmentRemoteDataSource remoteDataSource;

  InvestmentRepository({required this.remoteDataSource});

  Future<void> configureInvestments(List<AssetRegistrationModel> investments) async {
    return await remoteDataSource.configureInvestments(investments);
  }
}
