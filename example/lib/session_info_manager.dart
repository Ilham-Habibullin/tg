import 'dart:convert' show jsonDecode;

import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:tg/tg.dart' as tg;
import 'package:t/t.dart' as t;

class SessionInfoManager extends tg.SessionInfoManager {

  SessionInfoManager({
    required tg.AuthorizationKey authorizationKey,
    required this.dropClient,
  }) : super(authorizationKey: authorizationKey) {
    prefKey = '${authorizationKey.id}-${authorizationKey.key.join()}';
  }

  late final String prefKey;
  final void Function() dropClient;

  @override
  Future<void> updateSeqno(int id, int seqnoCounter) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(prefKey, '$id,$seqnoCounter');
  }

  Future<(int id, int seqnoCounter)> getSeqno({ tg.AuthorizationKey? authorizationKey }) async {
    final prefs = await SharedPreferences.getInstance();
    final seqno = prefs.getString(prefKey);

    if (seqno == null) {
      return (0, 0);
    }

    final parts = seqno.split(',');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  @override
  Future<void> updateServerSalt(t.BadServerSalt msg) async {
    final prefs = await SharedPreferences.getInstance();

    final authKey = prefs.getString('auth');

    if (authKey == null) {
      return;
    }

    final authKeyJson = jsonDecode(authKey);
    final authKeyObj = tg.AuthorizationKey.fromJson(authKeyJson);

    final newAuthKey = tg.AuthorizationKey(
      authKeyObj.id,
      authKeyObj.key,
      msg.newServerSalt,
    );

    prefs.setString('auth', newAuthKey.toString());

    dropClient();
  }
}