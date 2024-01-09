import 'package:uuid/uuid.dart';

class ModelUuid {

  var randomId = Uuid().v4();
  var now = DateTime.now().millisecondsSinceEpoch;

}