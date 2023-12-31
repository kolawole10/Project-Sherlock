import 'package:flutter/material.dart';
import 'package:sherlock/models/stain_comment.dart';
import '../models/blood_sample.dart';
import '../models/blood_stains.dart';
import 'pg_results.dart';
import '../services/db_service.dart';

Color sherlockGrey = const Color(0xFF7C7C7C);
Color sherlockDarkGreen = const Color(0xFF215A47);
Color sherlockBorderGreen = const Color(0xFF028958);
Color sherlockLightGreen = const Color(0xFFE8F3F5);
BloodSample data = BloodSample(isNew: true, filename: "temp_file");

// ignore: must_be_immutable
class BloodDataPage extends StatelessWidget {
  // constructor
  BloodDataPage(BloodSample dataset, {Key? key}) : super(key: key) {
    data = dataset;
  }

  @override
  Widget build(BuildContext context) {
    String infoText =
        "Please enter/edit your blood spatter data in the following table."
                " Your team name and pattern ID will be used to automatically save"
                " your data for you when you run the analysis."
                "\n\nTeam Name: " +
            (data.teamName ?? "") +
            "\nPattern ID: " +
            (data.patternId ?? "");
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Stain Parameters",
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Container(
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(children: [
                        ElevatedButton(
                          onPressed: () {
                            // Navigate back to previous screen when tapped.
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Dataset Information",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(300, 60),
                              primary: sherlockGrey,
                              padding: const EdgeInsets.all(20),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20))),
                        ),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            infoText,
                            style: TextStyle(
                              fontSize: 16,
                              color: sherlockGrey,
                            ),
                          ),
                        ),
                        const BloodDataForm(),
                      ]),
                    )))),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ResultsPage(sample: data)),
                );
              },
              child: const Text(
                "Process Data",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(300, 60),
                  primary: sherlockDarkGreen,
                  padding: const EdgeInsets.all(20),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
          ),
        ));
  }
} // --- End Stain Parameters Class

// Define a custom Form widget.
class BloodDataForm extends StatefulWidget {
  // constructor
  const BloodDataForm({Key? key}) : super(key: key);

  @override
  BloodDataFormState createState() {
    // ignore: no_logic_in_create_state
    return BloodDataFormState();
  }
}

//creating a form using GlobalKey
class BloodDataFormState extends State<BloodDataForm> {
 
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          // --- All the form fields go here ----
          for (int i = 0; i < data.numStains; ++i) formBox(i + 1),
        ],
      ),
    );
  } // --- End build function

  // This function creates the form fields for each stain
  Widget formBox(int stainID) {
    String stain = "Stain Number " + stainID.toString();
    return Container(
        width: 340,
        height: 180,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: sherlockLightGreen,
            border: Border.all(width: 2.0, color: sherlockBorderGreen)),
        child: Column(
          children: [
            Text(
              stain,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                SizedBox(
                    width: 150,
                    height: 40,
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "α Angle"),
                      keyboardType: TextInputType.number,
                    )),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                    width: 150,
                    height: 40,
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "γ Angle"),
                      keyboardType: TextInputType.number,
                    )),
              ],
            ),
            Row(
              children: [
                SizedBox(
                    width: 150,
                    height: 40,
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "Y Coord."),
                      keyboardType: TextInputType.number,
                    )),
                const SizedBox(
                  width: 10,
                ),
                SizedBox(
                    width: 150,
                    height: 40,
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: "Z Coord."),
                      keyboardType: TextInputType.number,
                    )),
              ],
            ),
            Row(
              children: [
                const Text("Include"),
                FormField(
                    initialValue: true,
                    builder: (FormFieldState<bool> field) {
                      return SizedBox(
                          width: 60,
                          child: Switch(
                              value: data.bloodStains[stainID - 1].include,
                              onChanged: (bool val) {
                                setState(() {
                                  data.bloodStains[stainID - 1].include = val;
                                });
                              }));
                    }),
                SizedBox(
                    width: 200,
                    child: DropdownButtonFormField<StainComment>(
                      hint: const Text("Comment"),
                      items: const [
                        DropdownMenuItem<StainComment>(
                          value: StainComment.none,
                          child: Text(""),
                        ),
                        DropdownMenuItem<StainComment>(
                          value: StainComment.badAlphaValue,
                          child: Text("Bad alpha value"),
                        ),
                        DropdownMenuItem<StainComment>(
                          value: StainComment.badGammaValue,
                          child: Text("Bad gamma value"),
                        ),
                        DropdownMenuItem<StainComment>(
                          value: StainComment.badYOrZCoord,
                          child: Text("Bad Y or Z coordinate"),
                        )
                      ],
                      onChanged: (value) {
                        setState(() {
                          data.bloodStains[stainID - 1].comment =
                              value as StainComment;
                        });
                      },
                    ))
              ],
            ),
          ],
        ));
  }

  
} 
