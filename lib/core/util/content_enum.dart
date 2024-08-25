// ignore_for_file: constant_identifier_names

import 'package:portfolio_plus/core/constants/strings.dart';

enum Content {
  TEXT(TEXT_CONTENT_TYPE),
  IMAGE(IMAGE_CONTENT_TYPE),
  AUDIO(AUDIO_CONTENT_TYPE);

  final String type;
  const Content(this.type);
}
