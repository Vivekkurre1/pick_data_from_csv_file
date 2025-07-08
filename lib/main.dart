import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ContactGroupViewScreen(),
    );
  }
}

class ContactGroupViewScreen extends StatefulWidget {
  const ContactGroupViewScreen({super.key});

  @override
  State<ContactGroupViewScreen> createState() => _ContactGroupViewScreenState();
}

class _ContactGroupViewScreenState extends State<ContactGroupViewScreen> {
  DataTable? _dataTable;

  Future<void> pickAndReadCsvFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      final bytes = File(result.files.single.path!).readAsBytesSync();
      final csvTable = const CsvToListConverter().convert(utf8.decode(bytes));

      final dataTable = DataTable(
        columns: List.generate(
          csvTable.first.length,
          (index) => DataColumn(label: Text(csvTable.first[index].toString())),
        ),
        rows: List.generate(
          csvTable.length > 1 ? csvTable.length - 1 : 0,
          (rowIndex) => DataRow(
            cells: List.generate(
              csvTable[rowIndex + 1].length,
              (colIndex) =>
                  DataCell(Text(csvTable[rowIndex + 1][colIndex].toString())),
            ),
          ),
        ),
      );

      setState(() {
        _dataTable = dataTable;
      });
    } else {
      if (kDebugMode) {
        print('File picking cancelled.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: pickAndReadCsvFile,
        backgroundColor: const Color.fromARGB(255, 13, 71, 161),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0)),
        ),
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 71, 161),
        title: Text(
          "Contact Group View",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child:
            (_dataTable == null)
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      Text("No data", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                )
                : ListView(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: _dataTable,
                    ),
                    SizedBox(height: 20),
                  ],
                ),
      ),
    );
  }
}
