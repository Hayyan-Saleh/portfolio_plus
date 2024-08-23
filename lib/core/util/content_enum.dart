import 'package:portfolio_plus/core/constants/strings.dart';

enum Content {
  text(TEXT_CONTENT_TYPE),
  image(IMAGE_CONTENT_TYPE),
  audio(AUDIO_CONTENT_TYPE);

  final String type;
  const Content(this.type);
}
