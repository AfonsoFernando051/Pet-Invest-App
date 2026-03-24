import 'package:petapp_mobile/features/pet/data/datasources/pet_remote_datasource.dart';
import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';

class PetRepository {
  final PetRemoteDataSource remoteDataSource;

  PetRepository({required this.remoteDataSource});

  Future<void> configurePet(PetSpecieEnum specie) async {
    return await remoteDataSource.configurePet(specie);
  }

  Future<bool> getPetStatus() async {
    return await remoteDataSource.getPetStatus();
  }
}
