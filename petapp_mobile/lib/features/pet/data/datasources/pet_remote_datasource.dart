import 'dart:convert';
import 'package:petapp_mobile/core/network/api_client.dart';
import 'package:petapp_mobile/core/constants/api_constants.dart';
import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';

class PetRemoteDataSource {
  final ApiClient apiClient;

  PetRemoteDataSource({required this.apiClient});

  Future<void> configurePet(PetSpecieEnum specie) async {
    final response = await apiClient.post(
      '/pets/configure',
      {'specie': specie.name},
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to configure pet');
    }
  }

  Future<bool> getPetStatus() async {
    final response = await apiClient.get('/pets/status');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['hasPet'] as bool;
    }
    return false;
  }
}
