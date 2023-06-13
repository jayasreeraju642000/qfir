import 'package:flutter/material.dart';
import 'package:qfinr/widgets/styles.dart';

class TextWithDropDown<T> extends StatelessWidget {
  final String fixedText;
  final String variableText;
  final T selectedItem;
  final List<T> itemList;
  final Function displayVariable;
  final Function onChanged;

  TextWithDropDown(
    this.fixedText,
    this.variableText,
    this.selectedItem,
    this.itemList,
    this.displayVariable,
    this.onChanged,
  );

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        icon: Icon(
          Icons.keyboard_arrow_down,
          size: 14,
        ),
        hint: Container(
          alignment: Alignment.center,
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: _textStyle,
              text: fixedText,
              children: [
                TextSpan(
                  text: this.variableText,
                  style: _textStyle.copyWith(
                    color: AppColor.colorBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
        selectedItemBuilder: (context) {
          return itemList.map<Widget>((T item) {
            return Container(
              alignment: Alignment.center,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: _textStyle,
                  text: fixedText,
                  children: [
                    TextSpan(
                      text: this.variableText,
                      style: _textStyle.copyWith(
                        color: AppColor.colorBlue,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList();
        },
        value: this.selectedItem,
        items: itemList.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              this.displayVariable(item),
              style: _textStyle,
            ),
          );
        }).toList(),
        onChanged: (value) {
          this.onChanged(value);
        },
      ),
    );
  }

  final TextStyle _textStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    fontFamily: 'roboto',
    letterSpacing: 1,
    color: Color(0xffa5a5a5),
  );
}
