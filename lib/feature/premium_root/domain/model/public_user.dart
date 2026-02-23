import 'package:salary/feature/premium_root/domain/model/public_profile.dart';

class PublicUser {

  final int id;
  final String name;
  final PublicProfile profile;

  PublicUser({
    required this.id,
    required this.name,
    required this.profile,
  });
}
