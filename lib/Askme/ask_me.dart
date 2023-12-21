import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_tutor/Constants/constants.dart';
import 'package:e_tutor/Services/my_services.dart';
import 'package:e_tutor/Views/CustomWidgets/show_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:async';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import '../Constants/sharedpref.dart';
import '../Views/CustomWidgets/custom_app_bar.dart';
import 'get_ask_me_model.dart';
import 'loader/overylay_loader.dart';
import 'model.dart';
import 'constant.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;


const backgroundColor = Color(0x17877575);
const botBackgroundColor = Color(0x17877575);

class AskMe extends StatefulWidget {
  const AskMe({super.key});

  @override
  State<AskMe> createState() => _AskMeState();
}

Future<String> generateResponse(String prompt) async {
  const apiKey = apiSecretKey;

  var url = Uri.https("api.openai.com", "/v1/completions");
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey'
    },
    body: jsonEncode({
      "model": "text-davinci-003",
      "prompt": prompt,
      'temperature': 0,
      'max_tokens': 2000,
      'top_p': 1,
      'frequency_penalty': 0.0,
      'presence_penalty': 0.0,
    }),
  );

  // Do something with the response
  Map<String, dynamic> newresponse = jsonDecode(response.body);
  return newresponse['choices'][0]['text'];
}

class _AskMeState extends State<AskMe> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
   bool isLoading = false;

  static String data = "";
  static String img1 = "";

  late bool isKeyboardSend = false;
  //audio recognization
  stt.SpeechToText speech = stt.SpeechToText();
  bool _hasSpeech = false;
  final bool _logEvents = false;
  final bool _onDevice = false;
  final TextEditingController _pauseForController =
  TextEditingController(text: '3');
  final TextEditingController _listenForController =
  TextEditingController(text: '30');
  double level = 0.0;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  String lastWords = '';
  String lastError = '';
  String lastStatus = '';
  String _currentLocaleId = '';
  List<AskMeGetModelData>? askMeList;
  File? image;

  @override
  void initState() {
    super.initState();
    callAsyncFetch();
    initSpeechState();
  }

  /// This initializes SpeechToText. That only has to be done
  /// once per application, though calling it again is harmless
  /// it also does nothing. The UX of the sample app ensures that
  /// it can only be called once.
  ///
  Future<void> initSpeechState() async {
    try {
      var hasSpeech = await speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
        debugLogging: _logEvents,
      );
      if (hasSpeech) {
        // Get the list of languages installed on the supporting platform so they
        // can be displayed in the UI for selection by the user.
         speech.locales();

        var systemLocale = await speech.systemLocale();
        _currentLocaleId = systemLocale?.localeId ?? '';
      }
      if (!mounted) return;

      setState(() {
        _hasSpeech = hasSpeech;
      });
    } catch (e) {
      setState(() {
        lastError = 'Speech recognition failed: ${e.toString()}';
        _hasSpeech = false;
      });
    }
  }

  Future callAsyncFetch() async {
    SharedPred.getImage().then((value) {
      img1 = value;
      MyServices.getAskMeQuestion().then((value) {
        askMeList = value!.data;
        for (var item in askMeList!) {
          _messages.add(ChatMessage(text: item.question.toString(),
              chatMessageType: ChatMessageType.user,time: item.datetime.toString()));
          _messages.add(ChatMessage(text: item.answer.toString(),
              chatMessageType: ChatMessageType.bot,time: item.datetime.toString()));
        }
        setState(() {
          data = "success";
        });
      });
    });
  }

  Widget openCameraDialog(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton.icon(
                  icon: Icon(
                    Icons.photo_library,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text("From Gallery",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _getFromGallery(context);
                    Navigator.of(context).pop();
                  }),
              TextButton.icon(
                icon: Icon(
                  Icons.photo_camera_rounded,
                  color: Theme.of(context).primaryColor,
                ),
                label: Text("Camera",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _getFromCamera(context);
                  //Navigator.of(context).pop();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

// get image File camera
  Future<bool> _permissionToPickImage() async {
    late final Map<Permission, PermissionStatus> statusess;
    if(Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      /*bool permissionGiven = await Permission.storage.isGranted;
    if (!permissionGiven) {
      permissionGiven = (await Permission.storage.request()).isGranted;
      return permissionGiven;
    }*/
      if (androidInfo.version.sdkInt <= 32) {
        statusess = await [
          Permission.storage,
        ].request();
      }else {
        //  statusess = await [Permission.photos, Permission.notification].request();
        statusess = await [Permission.photos].request();
      }
    }else {
      //  statusess = await [Permission.photos, Permission.notification].request();
      statusess = await [Permission.storage].request();
    }

    var allAccepted = true;
    statusess.forEach((permission, status) {
      if (status != PermissionStatus.granted) {
        allAccepted = false;
      }
    });
    return allAccepted;
  }

  Future<bool> _permissionToPickImageCamera() async {
    late final Map<Permission, PermissionStatus> statusess;
    if(Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        statusess = await [
          Permission.storage,
        ].request();
      }else {
        //  statusess = await [Permission.photos, Permission.notification].request();
        statusess = await [Permission.photos].request();
      }
    }else {
      //  statusess = await [Permission.photos, Permission.notification].request();
      statusess = await [Permission.storage].request();
    }

    var allAccepted = true;
    statusess.forEach((permission, status) {
      if (status != PermissionStatus.granted) {
        allAccepted = false;
      }
    });
    return allAccepted;
  }

  Future<void> _fixImageOrientation(String imagePath, context) async {
    try {
      final capturedImage =
      img.decodeImage(await File(imagePath).readAsBytes());
      final img.Image orientedImage = img.bakeOrientation(capturedImage!);
      image = await File(imagePath).writeAsBytes(img.encodeJpg(orientedImage));
      setState(() {
        final image = this.image;
        if (image != null) {
          scanText(image.path);
        }
      });
    }catch (e){
      //
    }
  }

  _getFromCamera(context) async {
    Navigator.of(context).pop();
    final ImagePicker picker = ImagePicker();
    if (await _permissionToPickImageCamera()) {
      try {
        final XFile? pickedFile = await picker.pickImage(
          source: ImageSource.camera,
        );

        final path = pickedFile?.path;
        if (pickedFile == null) {
          return;
        }
        await _fixImageOrientation(path!, context);
      } catch (e) {
        //
      }
    } else {
    }
  }

  //get image file from library
  _getFromGallery(BuildContext context) async {
    if (await _permissionToPickImage()) {
      final FilePickerResult? result =
      await FilePicker.platform.pickFiles(type: FileType.image);

      final path = result?.files.single.path;
      if (result == null) {
        return;
      }
      // ignore: use_build_context_synchronously
      await _fixImageOrientation(path!, context);
    } else {
    }
  }

  // scan text from image
  Future scanText(String path) async {
    String recognizeText = "";
    Loader.show(context);
    final inputImage = InputImage.fromFilePath(path);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
    await textDetector.processImage(inputImage);
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement element in line.elements) {
          setState(() {
            recognizeText = "${recognizeText.trim()} ${element.text.trim()}";
          });
        }
        _textController.text = recognizeText;
      }
    }
    Loader.hide();
  }


  // voice code
// This is called each time the users wants to start a new speech
  // recognition session
  void startListening() {
    _logEvent('start listening');
    lastWords = '';
    lastError = '';
    _textController.text = '';
    final pauseFor = int.tryParse(_pauseForController.text);
    final listenFor = int.tryParse(_listenForController.text);
    // Note that `listenFor` is the maximum, not the minimun, on some
    // systems recognition will be stopped before this value is reached.
    // Similarly `pauseFor` is a maximum not a minimum and may be ignored
    // on some devices.
    speech.listen(
      onResult: resultListener,
      listenFor: Duration(seconds: listenFor ?? 30),
      pauseFor: Duration(seconds: pauseFor ?? 3),
      partialResults: true,
      localeId: _currentLocaleId,
      onSoundLevelChange: soundLevelListener,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
      onDevice: _onDevice,
    );
    setState(() {});
  }

  void stopListening() {
    _logEvent('stop');
    speech.stop();
    setState(() {
      level = 0.0;
    });
  }

  void cancelListening() {
    _logEvent('cancel');
    speech.cancel();
    setState(() {
      level = 0.0;
    });
  }

  /// This callback is invoked each time new recognition results are
  /// available after `listen` is called.
  void resultListener(SpeechRecognitionResult result) {
    _logEvent(
        'Result listener final: ${result.finalResult}, words: ${result.recognizedWords}');
    setState(() {
      // lastWords = '${result.recognizedWords} - ${result.finalResult}';
      lastWords = result.recognizedWords;
      _textController.text = lastWords;
    });
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = '${error.errorMsg} - ${error.permanent}';
    });
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = status;
    });
  }


  void _logEvent(String eventDescription) {
    if (_logEvents) {
    }
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight((size.height / 10)),
          child: AppBar(
            centerTitle: true,
            systemOverlayStyle: const SystemUiOverlayStyle(
              systemNavigationBarColor: appColor, // Navigation bar
              statusBarColor: appColor, // Status bar
            ),
            titleSpacing: 30.w,
            leading: IconButton(
              icon:  Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 25.sp,
              ),
              onPressed: () =>
                  Navigator.pop(context),
            ),
            title: Text(
              "Ask Me",
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 19),
            ),
            backgroundColor: appColor,
            shape: const CustomAppBarShape(multi: 0.08),
          )),
      body:  SafeArea(
        child:  Column(
          children: [
            Expanded(
              child: data=="" ? const Center(child: CircularProgressIndicator(color: appColor,)): _buildList(),
            ),
            Visibility(
              visible: isLoading,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(
                  color: appColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child:
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: const [
                          BoxShadow(
                              color: Color.fromRGBO(
                                  0, 0, 0, 0.06),
                              blurRadius: 10,
                              spreadRadius: 4,
                              offset: Offset(0, 0)),
                        ],
                      ),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(width: 5,),
                          SizedBox(
                            width:
                            MediaQuery.of(context).size.height * 0.28,
                            child: TextField(
                              textCapitalization:
                              TextCapitalization.sentences,
                              style:  GoogleFonts.roboto(color: appColor,fontSize: 16.sp),
                              controller: _textController,
                              decoration: InputDecoration(
                                hintText: 'Type here',
                                hintStyle: GoogleFonts.roboto(color: Colors.grey,fontSize: 16.sp),
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                              )
                            )
                          ),
                          Visibility(
                            visible: !isLoading,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    content: openCameraDialog(ctx),
                                  ),
                                );
                              },
                              child:  Container(padding:const EdgeInsets.all(0),
                                  child: Icon(Icons.camera_alt_rounded,color: appColor,size: 20.h,))
                            )
                          ),
                          Visibility(
                            visible: !isLoading,
                            child: InkWell(
                              onTap: () {
                                if(_textController.text == ""){
                                  showSnackBar(context, "Text must not be Empty");
                                }else{
                                  setState(() {
                                    var dt = DateTime.now();
                                      _messages.add(
                                        ChatMessage(
                                          text: _textController.text,
                                          chatMessageType: ChatMessageType.user,time : dt.toString()
                                        ),
                                      );
                                      isLoading = true;
                                    },
                                  );
                                  var input = _textController.text;
                                  _textController.clear();
                                  Future.delayed(const Duration(milliseconds: 50))
                                      .then((_) => _scrollDown());
                                  generateResponse(input).then((value) {
                                    setState(() {
                                      isLoading = false;
                                      var dt = DateTime.now();
                                      _messages.add(
                                        ChatMessage(
                                          text: value,
                                          chatMessageType: ChatMessageType.bot,time : dt.toString()
                                        ),
                                      );
                                      MyServices.setAskMeQuestion(input, value);
                                    });
                                  });
                                  _textController.clear();
                                  Future.delayed(const Duration(milliseconds: 50))
                                      .then((_) => _scrollDown());
                                }
                              },
                              child: Container(padding:const EdgeInsets.all(0),
                                  child: Icon(Icons.send_rounded,
                                    color: appColor,size: 20.h,))
                            )
                          ),
                          SizedBox(width: 1.w,)
                        ]
                      )
                    )
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Visibility(
                    visible: !isLoading,
                    child: InkWell(
                      onTap: () {
                        if (!_hasSpeech || speech.isListening) {
                        } else {
                          startListening();
                        }
                      },
                      child: Padding(
                          padding: EdgeInsets.all(5.w),
                          child: speech.isListening
                              ? Image.asset(
                            'assets/Images/wave_sound.png',
                            height: 20.h,
                            width: 20.w,
                            color: appColor,
                            fit: BoxFit.cover,
                          )
                              : Image.asset(
                            'assets/Images/recording.png',
                            height: 20.h,
                            width: 20.w,
                            color: appColor,
                            // fit: BoxFit.cover,
                          ),
                        ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView _buildList() {
    // here we set the timer to call the event
    Timer(const Duration(milliseconds: 500), () => _scrollController.jumpTo(_scrollController.position.maxScrollExtent));

    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        var message = _messages[index];
        return ChatMessageWidget(img : img1,
          text: message.text,
          time: message.time,
          chatMessageType: message.chatMessageType,
        );
      },
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  const ChatMessageWidget(
      {super.key, required this.img,required this.text,required this.time, required this.chatMessageType});

  final String text,img,time;
  final ChatMessageType chatMessageType;



  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
      Share.share(text);
    },
    child:  Column(children: [Row(mainAxisAlignment: chatMessageType == ChatMessageType.bot ?
    MainAxisAlignment.start : MainAxisAlignment.end,children : [
      IntrinsicWidth(child: Container
      (constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width / 1.3),
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color:  chatMessageType == ChatMessageType.bot ?
        Colors.grey.withOpacity(.15) :
        appColor.withOpacity(.15),
        borderRadius: BorderRadius.only(
            bottomLeft : chatMessageType != ChatMessageType.bot ?
            Radius.circular(25.r) :Radius.circular(0.r),
            topLeft :  Radius.circular(25.r,),
            bottomRight: chatMessageType == ChatMessageType.bot ?Radius.circular(25.r,)
                : Radius.circular(0.r,),
            topRight: Radius.circular(25.r,)
      )),
      child:  Padding(padding: EdgeInsets.all(8.w),child:SelectableText(
                    text.trim(),
                    style: GoogleFonts.roboto(fontSize: 14.sp,color: Colors.black,fontWeight: FontWeight.w400,letterSpacing: .5,wordSpacing: 1),
            )),
          ))]),
      Align(alignment: chatMessageType == ChatMessageType.bot ? Alignment.bottomLeft:Alignment.bottomRight,child:Padding(padding: EdgeInsets.only(
          left : chatMessageType == ChatMessageType.bot ? 14.w : 0.w,
          right: chatMessageType == ChatMessageType.bot ? 0.w : 14.w,top: 3.w,bottom: 3.h),
          child:Text(DateFormat.jm().format(DateTime.parse(time)),style: GoogleFonts.roboto(fontWeight: FontWeight.w300,color: Colors.grey,fontSize: 12.sp),)))
    ],));
  }
}
