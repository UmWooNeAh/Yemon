class SavepointManager {
  int _savepointId = 0;

  String createSavePoint() {
    int now = ++_savepointId;
    return 'my_savepoint_$now';
  }
  String returnSavePoint() {
    int now = _savepointId--;
    return 'my_savepoint_$now';
  }
}