import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Dil Anketi"),
        ),
        body: SurveyList(),
      ),
    );
  }
}

class SurveyList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return SurveyListState();
  }
}

class SurveyListState extends State {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("dilanketi").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          return buildBody(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget buildBody(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
        padding: EdgeInsets.only(top: 25),
        children: snapshot
            .map<Widget>((data) => buildListItem(context, data))
            .toList());
  }

  buildListItem(BuildContext context, DocumentSnapshot data) {
    final row = Anket.fromSnaphot(data);
    return Padding(
      key: ValueKey(row.isim),
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Container(
        decoration: (BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5),
        )),
        child: ListTile(
          title: Text(row.isim),
          trailing: Text(row.oy.toString()),
          onTap: () {
            Firestore.instance.runTransaction((transaction) async {
              final freshSnapshot = await transaction.get(row.reference);
              final fresh = Anket.fromSnaphot(freshSnapshot);

              await transaction.update(row.reference, {"oy": fresh.oy + 1});
            });
          },
        ),
      ),
    );
  }
}

final sahteSnapshot = [
  {"isim": "java", "oy": 3},
  {"isim": "swift", "oy": 1},
  {"isim": "c++", "oy": 8},
  {"isim": "dart", "oy": 4},
];

class Anket {
  String isim;
  int oy;
  DocumentReference reference;

  Anket.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map["isim"] != null),
        assert(map["oy"] != null),
        isim = map["isim"],
        oy = map["oy"];

  Anket.fromSnaphot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);
}
