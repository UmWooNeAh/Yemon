class SavepointManager {
  var savepointId;

  SavepointManager() {
    savepointId = 0;
  }

  String createSavePoint() {
    return 'my_savepoint_${++savepointId}';
  }
  String returnSavePoint() {
    return 'my_savepoint_${savepointId--}';
  }
}