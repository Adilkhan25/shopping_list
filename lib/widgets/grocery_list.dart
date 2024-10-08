import 'package:flutter/material.dart';
import 'package:shopping_list/database/rest_operation.dart';
import 'package:shopping_list/models/grocery_item.dart';

import 'package:shopping_list/widgets/new_grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryList = [];
  var _isLoading = true;
  @override
  void initState() {
    _loadTheData();
    super.initState();
  }

  void _loadTheData() async {
    final itemList = await RestOperation.getTheData();

    setState(() {
      _groceryList = itemList;
      _isLoading = false;
    });
  }

  void _addNewGroceryItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewGroceryItem(),
      ),
    );
    if (newItem != null) {
      setState(() {
        _groceryList.add(newItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your groceries'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _groceryList.isEmpty
              ? const Center(
                  child: Text(
                      'No Groceries are available, please add the grocery item.\nTo add the grocery item press the + icon button'),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: ListView.builder(
                      itemCount: _groceryList.length,
                      itemBuilder: (ctx, idx) {
                        return Dismissible(
                          key: Key(_groceryList[idx].id),
                          background: Container(
                            color: Colors.red,
                            child: const Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Icon(Icons.delete),
                              ),
                            ),
                          ),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (DismissDirection direction) {
                            final removedAtIndex = idx;
                            final removedItem = _groceryList[idx];
                            setState(() {
                              _groceryList.remove(removedItem);
                            });
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('${removedItem.name} deleted'),
                                    action: SnackBarAction(
                                      label: 'Undo',
                                      onPressed: () {
                                        setState(() {
                                          _groceryList.insert(
                                              removedAtIndex, removedItem);
                                        });
                                      },
                                    ),
                                  ),
                                )
                                .closed
                                .then((reason) async {
                              if (reason != SnackBarClosedReason.action) {
                                final isDeleted =
                                    await RestOperation.delete(removedItem.id);
                                if (!isDeleted) {
                                  setState(() {
                                    _groceryList.insert(
                                        removedAtIndex, removedItem);
                                  });
                                }
                              }
                            });
                          },
                          child: ListTile(
                            leading: ColoredBox(
                              color: _groceryList[idx].category.color,
                              child: const SizedBox(
                                width: 20,
                                height: 20,
                              ),
                            ),
                            title: Text(_groceryList[idx].name),
                            trailing:
                                Text(_groceryList[idx].quantity.toString()),
                          ),
                        );
                      }),
                ),
      floatingActionButton: FloatingActionButton(
          onPressed: _addNewGroceryItem,
          tooltip: 'Add new grocery item',
          child: const Icon(Icons.add)),
    );
  }
}
