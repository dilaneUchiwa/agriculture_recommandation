import 'package:get/get.dart';
import 'package:agriculture_recommandation/utils/translations/fr.dart';
import 'package:agriculture_recommandation/utils/translations/en.dart';

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys =>
      {'en_US': en, 'fr_FR': fr};
}
