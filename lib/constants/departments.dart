class DepartmentConstants {
  static const String generalMedicine = 'General Medicine';
  static const String pediatrics = 'Pediatrics';
  static const String dermatology = 'Dermatology';
  static const String ophthalmology = 'Ophthalmology';
  static const String ent = 'Otolaryngology (ENT)';
  static const String orthopedics = 'Orthopedics';
  static const String cardiology = 'Cardiology';
  static const String neurology = 'Neurology';
  static const String obgyn = 'Obstetrics & Gynecology';
  static const String psychiatry = 'Psychiatry';
  static const String endocrinology = 'Endocrinology';
  
  static const List<String> allDepartments = [
    generalMedicine,
    pediatrics,
    dermatology,
    ophthalmology,
    ent,
    orthopedics,
    cardiology,
    neurology,
    obgyn,
    psychiatry,
    endocrinology,
  ];

  static String getTranslationKey(String department) {
    switch (department) {
      case generalMedicine: return 'dept_general_medicine';
      case pediatrics: return 'dept_pediatrics';
      case dermatology: return 'dept_dermatology';
      case ophthalmology: return 'dept_ophthalmology';
      case ent: return 'dept_ent';
      case orthopedics: return 'dept_orthopedics';
      case cardiology: return 'dept_cardiology';
      case neurology: return 'dept_neurology';
      case obgyn: return 'dept_obgyn';
      case psychiatry: return 'dept_psychiatry';
      case endocrinology: return 'dept_endocrinology';
      default: return department;
    }
  }
}