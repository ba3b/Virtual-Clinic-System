class VaccinationConstants {
  static const String covid19 = 'COVID-19';
  static const String influenza = 'Influenza (Flu)';
  static const String hepatitisA = 'Hepatitis A';
  static const String hepatitisB = 'Hepatitis B';
  static const String tdap = 'Tetanus, Diphtheria, Pertussis (Tdap)';
  static const String mmr = 'Measles, Mumps, Rubella (MMR)';
  static const String polio = 'Polio';
  static const String varicella = 'Varicella (Chickenpox)';
  static const String hpv = 'Human Papillomavirus (HPV)';
  static const String meningococcal = 'Meningococcal';
  static const String pneumococcal = 'Pneumococcal';
  static const String rotavirus = 'Rotavirus';
  static const String shingles = 'Shingles (Herpes Zoster)';
  static const String rabies = 'Rabies (on demand)';
  static const String travelVaccines = 'Travel Vaccines (e.g., Yellow Fever, Typhoid)';
  
  static const List<String> allVaccinations = [
    covid19,
    influenza,
    hepatitisA,
    hepatitisB,
    tdap,
    mmr,
    polio,
    varicella,
    hpv,
    meningococcal,
    pneumococcal,
    rotavirus,
    shingles,
    rabies,
    travelVaccines,
  ];

  static String getTranslationKey(String vaccination) {
    switch (vaccination) {
      case covid19: return 'vac_covid19';
      case influenza: return 'vac_influenza';
      case hepatitisA: return 'vac_hepatitis_a';
      case hepatitisB: return 'vac_hepatitis_b';
      case tdap: return 'vac_tdap';
      case mmr: return 'vac_mmr';
      case polio: return 'vac_polio';
      case varicella: return 'vac_varicella';
      case hpv: return 'vac_hpv';
      case meningococcal: return 'vac_meningococcal';
      case pneumococcal: return 'vac_pneumococcal';
      case rotavirus: return 'vac_rotavirus';
      case shingles: return 'vac_shingles';
      case rabies: return 'vac_rabies';
      case travelVaccines: return 'vac_travel';
      default: return vaccination;
    }
  }
}