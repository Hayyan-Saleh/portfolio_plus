import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';

class CustomDropDownButton extends StatefulWidget {
  final String buttonTitle;
  final String dropDownTitle;
  final List dataList;
  final void Function(List<dynamic> selectedList) onSelect;

  const CustomDropDownButton({
    required this.dropDownTitle,
    required this.onSelect,
    required this.buttonTitle,
    required this.dataList,
    super.key,
  });

  @override
  State<CustomDropDownButton> createState() => _CustomDropDownButtonState();
}

class _CustomDropDownButtonState extends State<CustomDropDownButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          DropDownState(
            DropDown(
              dropDownBackgroundColor: Theme.of(context).colorScheme.background,
              isDismissible: true,
              bottomSheetTitle: Text(
                widget.dropDownTitle,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              data: _generateSelectedListItems(),
              selectedItems: (List<dynamic> selectedItems) =>
                  widget.onSelect(selectedItems),
              enableMultipleSelection: false,
            ),
          ).showModal(context);
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border:
                  Border.all(color: Theme.of(context).colorScheme.secondary)),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    widget.buttonTitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  List<SelectedListItem> _generateSelectedListItems() {
    return widget.dataList
        .map<SelectedListItem>((item) => SelectedListItem(name: item))
        .toList();
  }
}
