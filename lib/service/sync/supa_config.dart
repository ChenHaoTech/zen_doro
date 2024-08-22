enum KvType {
  timeBlock(0),
  tags(1),
  setting(2),
  // 不存磁盘
  subscriptionTier(3),
  ;

  final int code;

  const KvType(this.code);
}

enum KvState {
  unknow(-1),
  normal(0),
  delete(1),
  ;

  final int code;

  const KvState(this.code);

  static KvState of(int code) {
    for (KvState state in KvState.values) {
      if (state.code == code) {
        return state;
      }
    }
    return KvState.unknow;
  }
}
