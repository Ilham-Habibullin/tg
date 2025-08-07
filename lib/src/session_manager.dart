part of '../tg.dart';

abstract class SessionInfoManager {
  SessionInfoManager({
    required AuthorizationKey authorizationKey,
  });

  Future<void> updateSeqno(int id, int seqnoCounter);

  Future<void> updateServerSalt(BadServerSalt msg, Completer<t.Result> completer, t.TlMethod method);
}