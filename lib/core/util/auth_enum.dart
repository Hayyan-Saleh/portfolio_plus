import 'package:portfolio_plus/core/constants/strings.dart';

enum AuthenticationType {
  googleAuth(GOOGLE_AUTH_TYPE),
  emailPasswordAuth(EMAIL_PASSWORD_AUTH_TYPE),
  noAuth(NO_AUTH_TYPE);

  final String type;
  const AuthenticationType(this.type);
}
