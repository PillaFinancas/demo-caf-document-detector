import 'dart:io';

import 'package:document_detector/android/android_settings.dart';
import 'package:document_detector/android/customization.dart';
import 'package:document_detector/android/maskType.dart';
import 'package:document_detector/android/resolution.dart';
import 'package:document_detector/caf_stages.dart';
import 'package:document_detector/document_detector.dart';
import 'package:document_detector/document_detector_step.dart';
import 'package:document_detector/document_type.dart';
import 'package:document_detector/message_settings.dart';
import 'package:document_detector/result/document_detector_result.dart';
import 'package:document_detector/result/document_detector_success.dart';
import 'package:document_detector/upload_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String url = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Upload do sua CNH Digital'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: url.isNotEmpty,
              child: Text(url.limit(45)),
            ),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue)),
              onPressed: () {
                _showDocument(['PDF']);
              },
              child: const Text(
                'CNH digital PDF',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue)),
              onPressed: () {
                _showDocument(['PNG']);
              },
              child: const Text(
                'CNH digital PNG',
                style: TextStyle(color: Colors.white),
              ),
            ),
            Visibility(
              visible: url.isNotEmpty,
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.green)),
                onPressed: () {
                  _copy(
                    onComplete: (){
ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Url copiada')));
                    }
                  );
                },
                child: const Text(
                  'Copiar Url',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _showDocument(List<String> allowedExtensions) async {
    const mobileToken =
        'insert_a_valid_mobile_token';
    final DocumentDetector documentDetector = DocumentDetector(
      mobileToken: mobileToken,
    );
    if (Platform.isAndroid) {
      final DocumentDetectorCustomizationAndroid
          documentDetectorCustomizationAndroid =
          DocumentDetectorCustomizationAndroid(
        maskType: MaskType.DETAILED,
        styleResIdName: 'defaultStyle',
      );

      final DocumentDetectorAndroidSettings detectorAndroidSettings =
          DocumentDetectorAndroidSettings(
              enableSwitchCameraButton: false,
              compressQuality: 100,
              resolution: Resolution.FULL_HD,
              customization: documentDetectorCustomizationAndroid,
              useEmulator: true,
              useRoot: true,
              useDeveloperMode: true,
              useAdb: true,
              useDebug: true);

      documentDetector.setAndroidSettings(detectorAndroidSettings);
    }

    documentDetector.setGetImageUrlExpireTime('30d');

    final MessageSettings messageSettings = MessageSettings(
      openDocumentWrongMessage: "Feche o documento",
      showOpenDocumentMessage: true,
      unsupportedDocumentMessage: "Ops, esse documento não é suportado",
    );
    documentDetector.setMessageSettings(messageSettings);

    documentDetector.setDocumentFlow(
        [DocumentDetectorStep(document: DocumentType.CNH_FULL)]);
    documentDetector
        .setUploadSettings(UploadSettings(fileFormats: allowedExtensions));
    documentDetector.setStage(CafStage.PROD);
    final DocumentDetectorResult documentDetectorResult =
        await documentDetector.start();
    if (documentDetectorResult is DocumentDetectorSuccess) {
      setState(() {
        url = documentDetectorResult.captures.first.imageUrl ?? '';
      });
    }
    return documentDetectorResult;
  }

  _copy({required VoidCallback onComplete}) async {
    await Clipboard.setData(ClipboardData(text: url)).then((value) => onComplete());
    return;
  }
}


extension StringExtension on String{
  String limit(int size){
    if(length<=size) return '$this...';
    return '${substring(0,size)}...';

  }
}