enum PetSpecieEnum {
  DOG,
  CAT,
  WOLF,
  FOX,
  BEAR,
  LION
}

extension PetSpecieEnumExtension on PetSpecieEnum {
  String get name => toString().split('.').last;
}
