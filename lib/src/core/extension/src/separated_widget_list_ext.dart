import 'package:flutter/material.dart';

extension SeparatedWidgetListX on Iterable<Widget> {
  List<Widget> getSeparatedList({
    required Widget separator,
  }) => length == 0
      ? []
      : List<Widget>.generate(
          length * 2 - 1,
          (index) => index.isEven ? elementAt(index ~/ 2) : separator,
        );

  List<Widget> buildChildrenWithDividers({
    required Widget divider,
  }) {
    final result = <Widget>[];

    for (var i = 0; i < length; i++) {
      result.add(elementAt(i));
      if (i < length - 1) {
        result.add(divider);
      }
    }

    return result;
  }
}
