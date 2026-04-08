import 'package:petapp_mobile/core/network/api_client.dart';
import 'package:petapp_mobile/features/investment/data/models/investment_type_enum.dart';

class InvestmentRemoteDataSource {
  final ApiClient apiClient;

  InvestmentRemoteDataSource({required this.apiClient});

  Future<void> configureInvestments(List<InvestmentTypeEnum> investments) async {
    final response = await apiClient.post(
      '/api/investments/configure',
      {
        'investments': investments.map((e) => e.name).toList(),
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to configure investments');
    }
  }
}
