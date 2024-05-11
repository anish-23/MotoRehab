import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoRehab',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late File exercise1Video;
  late File exercise2Video;
  late File exercise3Video;
  late File exercise4Video;

  void _pickVideo(int exercise) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        switch (exercise) {
          case 1:
            exercise1Video = File(file.path!);
            break;
          case 2:
            exercise2Video = File(file.path!);
            break;
          case 3:
            exercise3Video = File(file.path!);
            break;
          case 4:
            exercise4Video = File(file.path!);
            break;
        }
      });
    }
  }

  Future<void> _uploadVideo(int exerciseNumber, File videoFile) async {
    var url = Uri.parse('http://192.168.0.100:5000/upload_video'); // Replace with your backend URL

    var request = http.MultipartRequest('POST', url);
    var file = await http.MultipartFile.fromPath('video', videoFile.path);
    request.files.add(file);
    request.fields['exercise'] = exerciseNumber.toString();

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        // Handle successful upload
        print('Video uploaded successfully!');
        // Show success message to user
      } else {
        // Handle error
        print('Error uploading video: ${response.statusCode}');
        // Show error message to user, potentially with details from response body
      }
    } catch (e) {
      // Handle network errors or other exceptions
      print('Error during upload: $e');
      // Show error message to user
    }
  }

  Future<void> _sendVideos() async {
    if (exercise1Video == null ||
        exercise2Video == null ||
        exercise3Video == null ||
        exercise4Video == null) {
      // Handle case where not all videos are uploaded
      return;
    }

    // Upload videos individually to ensure proper handling
    await _uploadVideo(1, exercise1Video);
    await _uploadVideo(2, exercise2Video);
    await _uploadVideo(3, exercise3Video);
    await _uploadVideo(4, exercise4Video);

    // If all uploads are successful, trigger report generation (assuming backend handles this)
    // If any upload fails, handle the error accordingly
  }

  Future<String> _getDownloadsDirectory() async {
    Directory downloadsDirectory;
    if (Platform.isAndroid) {
      downloadsDirectory = Directory('/storage/emulated/0/Download'); // Adjust this path as needed
    } else {
      downloadsDirectory = (await getDownloadsDirectory())!;
    }
    return downloadsDirectory.path;
  }


  Future<void> _saveReportToDownloads(int exerciseNumber) async {
    final String downloadsDirectory = await _getDownloadsDirectory();
    final String reportFileName = 'optical_flow_report_$exerciseNumber.pdf';
    final String reportFilePath = '$downloadsDirectory/$reportFileName';

    try {
      final http.Response response = await http.get(
        Uri.parse('http://192.168.0.100:5000/get_report?exercise=$exerciseNumber'),
      );

      if (response.statusCode == 200) {
        final File reportFile = File(reportFilePath);
        await reportFile.writeAsBytes(response.bodyBytes);
        print('Report saved to: $reportFilePath');
      } else {
        print('Error downloading report: ${response.statusCode}');
        // Handle error downloading report
      }
    } catch (e) {
      print('Error saving report: $e');
      // Handle error saving report
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MotoRehab'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Exercise buttons
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: CustomRaisedButton(
                    onPressed: () => _pickVideo(1),
                    colors: ButtonColors(
                        buttonColor: Colors.redAccent, textColor: Colors.white),
                    child: const Text('Upload Exercise 1 Video'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CustomRaisedButton(
                    onPressed: () => _saveReportToDownloads(1), // Placeholder onPressed for save button
                    colors: ButtonColors(
                        buttonColor: Colors.grey, textColor: Colors.white),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: CustomRaisedButton(
                    onPressed: () => _pickVideo(2),
                    colors: ButtonColors(
                        buttonColor: Colors.lightBlueAccent, textColor: Colors.white),
                    child: const Text('Upload Exercise 2 Video'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CustomRaisedButton(
                    onPressed: () => _saveReportToDownloads(2), // Placeholder onPressed for save button
                    colors: ButtonColors(
                        buttonColor: Colors.grey, textColor: Colors.white),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: CustomRaisedButton(
                    onPressed: () => _pickVideo(3),
                    colors: ButtonColors(
                        buttonColor: Colors.lightGreenAccent, textColor: Colors.white),
                    child: const Text('Upload Exercise 3 Video'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CustomRaisedButton(
                    onPressed: () => _saveReportToDownloads(3), // Placeholder onPressed for save button
                    colors: ButtonColors(
                        buttonColor: Colors.grey, textColor: Colors.white),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: CustomRaisedButton(
                    onPressed: () => _pickVideo(4),
                    colors: ButtonColors(
                        buttonColor: Colors.yellowAccent, textColor: Colors.white),
                    child: const Text('Upload Exercise 4 Video'),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CustomRaisedButton(
                    onPressed: () => _saveReportToDownloads(4), // Placeholder onPressed for save button
                    colors: ButtonColors(
                        buttonColor: Colors.grey, textColor: Colors.white),
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),

            // Report button
            CustomRaisedButton(
              onPressed: _sendVideos,
              colors: ButtonColors(buttonColor: Colors.blueGrey, textColor: Colors.white),
              child: const Text('Generate Report'),
            ),
          ],
        ),
      ),
    );
  }
}

class ButtonColors {
  final Color buttonColor;
  final Color textColor;

  ButtonColors({
    required this.buttonColor,
    required this.textColor,
  });
}

class CustomRaisedButton extends StatelessWidget {
  final ButtonColors colors;
  final VoidCallback onPressed;
  final Widget child;

  const CustomRaisedButton({
    required this.onPressed,
    required this.colors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 70.0,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(colors.buttonColor),
            textStyle: MaterialStateProperty.all<TextStyle>(
              const TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
