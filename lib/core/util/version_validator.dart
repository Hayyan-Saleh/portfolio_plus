import 'package:cloud_firestore/cloud_firestore.dart';

abstract class VersionValidator {
  Future<int> getVersion();
}

class VerssionValidatorImpl implements VersionValidator {
  @override
  Future<int> getVersion() async {
    final versionDoc = await FirebaseFirestore.instance
        .collection('version')
        .doc('version')
        .get();
    return versionDoc['version'] as int;
  }
}
