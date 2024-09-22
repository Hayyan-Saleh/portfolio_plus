// ignore_for_file: constant_identifier_names

import 'package:portfolio_plus/core/constants/strings.dart';

enum PostType {
  WEB_DEVELOPMENT(WEB_DEVELOPMENT_TYPE),
  MOBILE_DEVELOPMENT(MOBILE_DEVELOPMENT_TYPE),
  DATA_SCIENCE(DATA_SCIENCE_TYPE),
  MACHINE_LEARNING(MACHINE_LEARNING_TYPE),
  ARTIFICIAL_INTELLIGENCE(ARTIFICIAL_INTELLIGENCE_TYPE),
  GAME_DEVELOPMENT(GAME_DEVELOPMENT_TYPE),
  EMBEDDED_SYSTEMS(EMBEDDED_SYSTEMS_TYPE),
  CYBER_SECURITY(CYBER_SECURITY_TYPE),
  CLOUD_COMPUTING(CLOUD_COMPUTING_TYPE),
  DEVOPS(DEVOPS_TYPE),
  BLOCKCHAIN(BLOCKCHAIN_TYPE),
  INTERNET_OF_THINGS(INTERNET_OF_THINGS_TYPE),
  AUGMENTED_REALITY(AUGMENTED_REALITY_TYPE),
  VIRTUAL_REALITY(VIRTUAL_REALITY_TYPE),
  ROBOTICS(ROBOTICS_TYPE),
  ECOMMERCE(ECOMMERCE_TYPE),
  FINTECH(FINTECH_TYPE),
  HEALTHTECH(HEALTHTECH_TYPE),
  EDTECH(EDTECH_TYPE),
  SOCIAL_MEDIA(SOCIAL_MEDIA_TYPE),
  MEDICAL_TECHNOLOGY(MEDICAL_TECHNOLOGY_TYPE),
  BIOTECHNOLOGY(BIOTECHNOLOGY_TYPE),
  PHARMACEUTICALS(PHARMACEUTICALS_TYPE),
  TELEMEDICINE(TELEMEDICINE_TYPE),
  MEDICAL_IMAGING(MEDICAL_IMAGING_TYPE),
  CIVIL_ENGINEERING(CIVIL_ENGINEERING_TYPE),
  MECHANICAL_ENGINEERING(MECHANICAL_ENGINEERING_TYPE),
  ELECTRICAL_ENGINEERING(ELECTRICAL_ENGINEERING_TYPE),
  CHEMICAL_ENGINEERING(CHEMICAL_ENGINEERING_TYPE),
  AEROSPACE_ENGINEERING(AEROSPACE_ENGINEERING_TYPE),
  AUTOMOTIVE_ENGINEERING(AUTOMOTIVE_ENGINEERING_TYPE),
  ENVIRONMENTAL_ENGINEERING(ENVIRONMENTAL_ENGINEERING_TYPE),
  INDUSTRIAL_ENGINEERING(INDUSTRIAL_ENGINEERING_TYPE),
  MATERIALS_SCIENCE(MATERIALS_SCIENCE_TYPE),
  NANOTECHNOLOGY(NANOTECHNOLOGY_TYPE),
  RENEWABLE_ENERGY(RENEWABLE_ENERGY_TYPE),
  SMART_CITIES(SMART_CITIES_TYPE),
  AGRICULTURAL_TECHNOLOGY(AGRICULTURAL_TECHNOLOGY_TYPE),
  FOOD_TECHNOLOGY(FOOD_TECHNOLOGY_TYPE),
  SUPPLY_CHAIN_MANAGEMENT(SUPPLY_CHAIN_MANAGEMENT_TYPE),
  LOGISTICS(LOGISTICS_TYPE),
  REAL_ESTATE_TECHNOLOGY(REAL_ESTATE_TECHNOLOGY_TYPE),
  CONSTRUCTION_TECHNOLOGY(CONSTRUCTION_TECHNOLOGY_TYPE),
  SMART_HOME_TECHNOLOGY(SMART_HOME_TECHNOLOGY_TYPE),
  WEARABLE_TECHNOLOGY(WEARABLE_TECHNOLOGY_TYPE),
  QUANTUM_COMPUTING(QUANTUM_COMPUTING_TYPE),
  SPACE_TECHNOLOGY(SPACE_TECHNOLOGY_TYPE),
  MARINE_TECHNOLOGY(MARINE_TECHNOLOGY_TYPE),
  SPORTS_TECHNOLOGY(SPORTS_TECHNOLOGY_TYPE),
  ENTERTAINMENT_TECHNOLOGY(ENTERTAINMENT_TECHNOLOGY_TYPE);

  final String type;
  const PostType(this.type);
}