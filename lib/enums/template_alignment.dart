import 'package:collection/collection.dart';

enum TemplateAlignment {left,middle,right}

TemplateAlignment? getTemplateAlignment(String? alignment){
  return TemplateAlignment.values.firstWhereOrNull((element) => element.title == alignment);
}

extension AlignmentMapping on TemplateAlignment {

  String get title {

    switch(this){

      case TemplateAlignment.left:
        return 'Left';
      case TemplateAlignment.middle:
        return 'Middle';
      case TemplateAlignment.right:
        return 'Right';
    }
  }


}