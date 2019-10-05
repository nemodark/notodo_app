import 'package:flutter/material.dart';
import 'package:notodo_app/model/nodo_item.dart';
import 'package:notodo_app/util/database_client.dart';
import 'package:notodo_app/util/date_formatter.dart';


class NoToDoScreen extends StatefulWidget {
  @override
  _NoToDoScreenState createState() => _NoToDoScreenState();
}

class _NoToDoScreenState extends State<NoToDoScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  var db = DatabaseHelper();
  final List<NoDoItem> _itemList = <NoDoItem>[];

  @override
  void initState() {
    super.initState();
    _readNoDoList();
  }

  //insert method
  void _handleSubmitted(String text) async {
    _textEditingController.clear();

    NoDoItem noDoItem = NoDoItem(text, dateFormatted());
    int savedItemId = await db.saveItem(noDoItem);
    NoDoItem addedItem = await db.getItem(savedItemId);

    setState(() {
      _itemList.insert(0, addedItem);
      
    });

    print("Item saved id: $savedItemId");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.black87,
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
                padding: EdgeInsets.all(8.0),
                reverse: false,
                itemCount: _itemList.length,
                itemBuilder: (_, int index) {
                  return Card(
                      color: Colors.white10,
                      child: ListTile(
                        title: _itemList[index],
                        onLongPress: () => _doSettings(_itemList[index].id, index, _itemList[index]),
                      ));
                }),
          ),
          Divider(
            height: 1.0,
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add Item",
        backgroundColor: Colors.blueAccent,
        child: ListTile(title: Icon(Icons.add)),
        onPressed: _showFormDialog,
      ),
    );
  }

  void _showFormDialog() {
    var alert = AlertDialog(
      content: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _textEditingController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Item",
                hintText: "eg. Don't buy stuff",
                icon: Icon(Icons.note_add),
              ),
            ),
          )
        ],
      ),
      actions: <Widget>[
        FlatButton(
          onPressed: () {
            _handleSubmitted(_textEditingController.text);
            _textEditingController.clear();
            Navigator.pop(context);
          },
          child: Text("Save"),
        ),
        FlatButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        )
      ],
    );
    showDialog(
        context: context,
        builder: (_) {
          return alert;
        });
  }

  _readNoDoList() async {
    List items = await db.getItems();
    items.forEach((item) {
      // NoDoItem noDoItem = NoDoItem.map(item);
      setState(() {
        _itemList.add(NoDoItem.map(item)); 
      });
      // print("Db items: ${noDoItem.itemName}");
    });
  }

  _doSettings(int id, int index, NoDoItem item) async {
      var selection = SimpleDialog(
          title: const Text('Select Option'),
          children: <Widget>[
            SimpleDialogOption(
                  onPressed: () {
                      Navigator.pop(context);
                      _updateItem(item, index);
                  },
                  child: const Text('Edit Todo')
              ),
              SimpleDialogOption(
                  onPressed: () {
                      _deleteNoDo(id, index);
                      Navigator.pop(context);
                  },
                  child: const Text('Delete')
              ),
          ],
      );
      showDialog(
        context: context,
        builder: (_) {
          return selection;
        }
      );
  }

  _deleteNoDo(int id, int index) async {
      debugPrint("Deleted item");

      await db.deleteItem(id);
      setState(() {
        _itemList.removeAt(index); 
      });
  }

  _updateItem(NoDoItem item, int index){
      var alert = AlertDialog(
        title: const Text("Update Item"),
        content: Row(
            children: <Widget>[
                Expanded(
                  child: TextField(
                      controller: _textEditingController,
                      autofocus: true,

                      decoration: InputDecoration(
                          labelText: "Item",
                          hintText: "eg. Don't buy stuff",
                          icon: Icon(Icons.edit)
                      ),
                  ),)
            ],
        ),
        actions: <Widget>[
            FlatButton(
                onPressed: () async {
                  NoDoItem newItemUpdated = NoDoItem.fromMap({
                    "itemName": _textEditingController.text,
                    "dateCreated": dateFormatted(),
                    "id" : item.id
                    }
                  );

                _handleSubmittedUpdate(index, item); //redrawing the screen
                await db.updateItem(newItemUpdated); //updating the item
                setState(() {
                  _readNoDoList(); //redrawing the screen with all items saved in the database
                });
                Navigator.pop(context);
                },
                child: Text("Update"),
            ),
            FlatButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
            ),
        ],
      );
      showDialog(
        context: context,
        builder: (_) {
          return alert;
        }
      );
  }

  void _handleSubmittedUpdate(int index, NoDoItem item){
      setState(() {
        _itemList.removeWhere((element) {
            _itemList[index].itemName == item.itemName;
        });
      });
  }
}
