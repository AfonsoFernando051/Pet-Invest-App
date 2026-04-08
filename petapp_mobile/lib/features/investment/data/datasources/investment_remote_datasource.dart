import 'package:petapp_mobile/core/network/api_client.dart';
import 'package:petapp_mobile/features/investment/data/models/investment_type_enum.dart';
import 'package:petapp_mobile/features/investment/data/models/asset_registration_model.dart';

class InvestmentRemoteDataSource {
  final ApiClient apiClient;

  InvestmentRemoteDataSource({required this.apiClient});

  Future<void> configureInvestments(List<AssetRegistrationModel> investments) async {
    final response = await apiClient.post(
      '/api/investments/configure',
      investments.map((e) => e.toJson()).toList(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to configure investments');
    }
  }
}
