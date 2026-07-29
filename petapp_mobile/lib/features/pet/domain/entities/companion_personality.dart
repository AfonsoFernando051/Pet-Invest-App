import 'package:petapp_mobile/features/pet/data/models/pet_specie_enum.dart';

/// Descriptive personality traits shown on Companion Home — explicitly
/// *not* gameplay stats. No trait is "better" than another; they only
/// flavor who the companion is.
enum PersonalityTrait {
  optimistic,
  patient,
  curious,
  disciplined,
  friendly,
  protective,
  playful,
  confident,
  calm,
}

/// Each species leans into a different, fixed set of traits — matching the
/// tone `DefaultPersonalityEngine` already gives each species in its
/// event/greeting phrasing (dog: warm/energetic, cat: confident/aloof,
/// wolf: disciplined/protective, fox: clever/playful, bear: calm/steady,
/// lion: confident/protective).
const Map<PetSpecieEnum, List<PersonalityTrait>> companionPersonalityBySpecies =
    {
      PetSpecieEnum.DOG: [
        PersonalityTrait.friendly,
        PersonalityTrait.playful,
        PersonalityTrait.optimistic,
      ],
      PetSpecieEnum.CAT: [
        PersonalityTrait.confident,
        PersonalityTrait.patient,
        PersonalityTrait.curious,
      ],
      PetSpecieEnum.WOLF: [
        PersonalityTrait.disciplined,
        PersonalityTrait.protective,
        PersonalityTrait.calm,
      ],
      PetSpecieEnum.FOX: [
        PersonalityTrait.curious,
        PersonalityTrait.playful,
        PersonalityTrait.confident,
      ],
      PetSpecieEnum.BEAR: [
        PersonalityTrait.patient,
        PersonalityTrait.protective,
        PersonalityTrait.calm,
      ],
      PetSpecieEnum.LION: [
        PersonalityTrait.confident,
        PersonalityTrait.protective,
        PersonalityTrait.optimistic,
      ],
    };
