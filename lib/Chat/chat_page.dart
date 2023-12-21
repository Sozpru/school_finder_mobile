import 'dart:async';
import 'dart:io';
import 'package:e_tutor/Chat/zoom_img.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as p;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_tutor/Chat/pdf_show.dart';
import 'package:e_tutor/Chat/providers/chat_provider.dart';
import 'package:e_tutor/Constants/sharedpref.dart';
import 'package:e_tutor/Views/CustomWidgets/show_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../Constants/constants.dart';
import '../Views/CustomWidgets/custom_app_bar.dart';
import '../Views/CustomWidgets/utilss.dart';
import 'constants/color_constants.dart';
import 'constants/firestore_constants.dart';
import 'loading_view.dart';
import 'models/message_chat.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.arguments});

  final ChatPageArguments arguments;

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late final String currentUserId;

  List<QueryDocumentSnapshot> listMessage = [];
  int _limit = 20;
  final int _limitIncrement = 20;
  String groupChatId = "";

  CroppedFile? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
    FirebaseFirestore? firebaseFirestore = FirebaseFirestore.instance;
    FirebaseStorage? firebaseStorage = FirebaseStorage.instance;

  String myEmail="";

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  _scrollListener() {
    if (!listScrollController.hasClients) return;
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange &&
        _limit <= listMessage.length) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  Future<void> readLocal() async {
    // if (authProvider.getUserFirebaseId()?.isNotEmpty == true) {

      SharedPred.getEmail().then((value) {
        currentUserId =  value;
        String peerId = widget.arguments.peerId;
        if (currentUserId.compareTo(peerId) > 0) {
          groupChatId = '$currentUserId-$peerId';
        } else {
          groupChatId = '$peerId-$currentUserId';
        }

        updateDataFirestore(
          FirestoreConstants.pathUserCollection,
          currentUserId,
          {FirestoreConstants.chattingWith: peerId},
        );
      });
  }

  UploadTask uploadFile2(CroppedFile image, String fileName) {
    Reference reference = firebaseStorage!.ref().child(fileName);
    File myImage = File(image.path);
    UploadTask uploadTask = reference.putFile(myImage);
    return uploadTask;
  }

  Future<void> updateDataFirestore(String collectionPath, String docPath, Map<String, dynamic> dataNeedUpdate) {
    return firebaseFirestore!.collection(collectionPath).doc(docPath).update(dataNeedUpdate);
  }


  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  pickFile() async {

    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom,allowedExtensions: ['pdf']);

    String? ext = result?.files[0].name;
    final extension = p.extension(ext!);

    if (result != null) {
      if(extension.contains('.pdf') || extension.contains('.PDF')) {
        File file = File(result.files.single.path.toString());
        uploadPdfToStorage(file);
      }else{
        if(!mounted) return;
        showSnackBar(context, "Only pdf file allowed");
      }
    } else {
      // User canceled the picker
    }
  }

  Future<String?> uploadPdfToStorage(File pdfFile) async {
    try {
      Reference ref =
      FirebaseStorage.instance.ref().child('pdfs/${DateTime.now().millisecondsSinceEpoch}');
      UploadTask uploadTask = ref.putFile(pdfFile, SettableMetadata(contentType: 'pdf'));

      TaskSnapshot snapshot = await uploadTask;

      String url = await snapshot.ref.getDownloadURL();

      onSendMessage(url, TypeMessage.pdf);
      return url;
    } catch (e) {
      return null;
    }
  }


  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = uploadFile2(imageFile!, fileName);
    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, e.message.toString());
      // Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      sendMessage(content, type, groupChatId, currentUserId, widget.arguments.peerId);
      if (listScrollController.hasClients) {
        listScrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    } else {
      showSnackBar(context, "Nothing to send");
    }
  }

  void sendMessage(String content, int type, String groupChatId, String currentUserId, String peerId) {
    DocumentReference documentReference = firebaseFirestore!
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    MessageChat messageChat = MessageChat(
      idFrom: currentUserId,
      idTo: peerId,
      timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: type,
    );

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        documentReference,
        messageChat.toJson(),
      );
    });
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageChat messageChat = MessageChat.fromDocument(document);
      if (messageChat.idFrom == currentUserId) {
        // Right (my message)
        return Column(
            children: <Widget>[ Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
        messageChat.type == TypeMessage.text
            // Text
            ? IntrinsicWidth(child: Container
          (constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 1.3),
          margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
          decoration: BoxDecoration(color:
              appColor.withOpacity(.15),
              borderRadius: BorderRadius.only(
                  bottomLeft :
                  Radius.circular(25.r),
                  topLeft :  Radius.circular(25.r,),bottomRight: Radius.circular(0.r,),
                  topRight: Radius.circular(25.r,)
              )),
          child:  Padding(padding: EdgeInsets.all(8.w),child:SelectableText(
            messageChat.content,
            style: GoogleFonts.roboto(fontSize: 14.sp,color: Colors.black,fontWeight: FontWeight.w400,letterSpacing: .5,wordSpacing: 1),
          )),
        ))
            : messageChat.type == TypeMessage.image
                // Image
                ? Container(
                    margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShowImagePage( arguments: messageChat.content,
                            ),
                          ),
                        );
                      },
                      style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0))),
                      child: Material(
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        clipBehavior: Clip.hardEdge,
                        child: Image.network(
                          messageChat.content,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              decoration: const BoxDecoration(
                                color: ColorConstants.greyColor2,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              width: 200.w,
                              height: 200.h,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: ColorConstants.themeColor,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, object, stackTrace) {
                            return Material(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                // Sticker
                :messageChat.type == TypeMessage.pdf ? GestureDetector(onTap: (){

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ShowPdfPage(
                    arguments: messageChat.content)));
        },child:Container
          (constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width / 2.0),
          margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
          decoration: BoxDecoration(color:
          appColor.withOpacity(.15),
              borderRadius: BorderRadius.only(
                  bottomLeft :
                  Radius.circular(25.r),
                  topLeft :  Radius.circular(25.r,),bottomRight: Radius.circular(0.r,),
                  topRight: Radius.circular(25.r,)
              )),
          child:  Padding(padding: EdgeInsets.all(8.w),child:Column(children: [Row(children: [
            Icon(Icons.picture_as_pdf_rounded,color: Colors.red,size: 18.h,),
            SizedBox(width: 110.w,child:Padding(padding: EdgeInsets.only(left:8.w),child:
            Text(messageChat.content.split('/').last,overflow: TextOverflow.ellipsis,maxLines: 1,)))
          ],)],)),
        )):Container(
                    margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                    child: Image.asset(
                      'assets/Images/${messageChat.content}.gif',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
          ],
        ), Container(alignment: Alignment.bottomRight,
                margin: EdgeInsets.only(right: 14.w, top: 5.h, bottom: 5.h),
                child: Text(
                  DateFormat('dd MMM kk:mm')
                      .format(DateTime.fromMillisecondsSinceEpoch(int.parse(messageChat.timestamp))),
                  style: const TextStyle(color: ColorConstants.greyColor, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              )
                  ]);
      } else {
        // Left (peer message)
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  messageChat.type == TypeMessage.text
                      ? IntrinsicWidth(child: Container
                    (constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 1.3),
                    margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                    decoration: BoxDecoration(color:
                    Colors.grey.withOpacity(.15),
                        borderRadius: BorderRadius.only(
                            bottomLeft :
                            Radius.circular(0.r),
                            topLeft :  Radius.circular(25.r,),
                            bottomRight: Radius.circular(25.r,),
                            topRight: Radius.circular(25.r,)
                        )),
                    child:  Padding(padding: EdgeInsets.all(8.w),
                        child:SelectableText(
                      messageChat.content,
                      style: GoogleFonts.roboto(fontSize: 14.sp,color: Colors.black,fontWeight: FontWeight.w400,letterSpacing: .5,wordSpacing: 1),
                    )),
                  ))       :
                  messageChat.type == TypeMessage.pdf ? GestureDetector(onTap: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShowPdfPage(
                                arguments: messageChat.content)));
                  },child:Container
                    (constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width / 2.0),
                    margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
                    decoration: BoxDecoration(color:
                    appColor.withOpacity(.15),
                        borderRadius: BorderRadius.only(
                            bottomLeft :
                            Radius.circular(0.r),
                            topLeft :  Radius.circular(25.r,),
                            bottomRight: Radius.circular(25.r,),
                            topRight: Radius.circular(25.r,)
                        )),
                    child:  Padding(padding: EdgeInsets.all(8.w),child:Column(children: [Row(children: [
                      Icon(Icons.picture_as_pdf_rounded,color: Colors.red,size: 18.h,),
                      SizedBox(width: 110.w,child:Padding(padding: EdgeInsets.only(left:8.w),child:
    Text(messageChat.content.split('/').last,overflow: TextOverflow.ellipsis,maxLines: 1,)))
                    ],)],)),
                  ))
                      : messageChat.type == TypeMessage.image
                          ? Container(
                              margin: const EdgeInsets.only(left: 10),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShowImagePage( arguments: messageChat.content,
                                      ),
                                    ),
                                  );
                                },
                                style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(0))),
                                child: Material(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  clipBehavior: Clip.hardEdge,
                                  child: Image.network(
                                    messageChat.content,
                                    loadingBuilder:
                                        (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: const BoxDecoration(
                                          color: ColorConstants.greyColor2,
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(8),
                                          ),
                                        ),
                                        width: 200,
                                        height: 200,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: ColorConstants.themeColor,
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, object, stackTrace) => Material(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20 : 10, right: 10),
                              child: Image.asset(
                                'assets/Images/${messageChat.content}.gif',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                ],
              ),
             Container(
                      margin: EdgeInsets.only(left: 14.w, top: 5.h, bottom: 5.h),
                      child: Text(
                        DateFormat('dd MMM kk:mm')
                            .format(DateTime.fromMillisecondsSinceEpoch(int.parse(messageChat.timestamp))),
                        style: const TextStyle(color: ColorConstants.greyColor, fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    )
            ],
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) == currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get(FirestoreConstants.idFrom) != currentUserId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      updateDataFirestore(
        FirestoreConstants.pathUserCollection,
        currentUserId,
        {FirestoreConstants.chattingWith: null},
      );
      Navigator.pop(context);
    }

    return Future.value(false);
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
              onPressed: () {
                focusNode.unfocus();
                Navigator.pop(context);
              }
            ),
            title: Text(
              widget.arguments.peerNickname,
              style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 19),
            ),
            backgroundColor: appColor,
            shape: const CustomAppBarShape(multi: 0.08),
          )),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: onBackPress,
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  // List of messages
                  buildListMessage(),

                  // Sticker
                  isShowSticker ? buildSticker() : const SizedBox.shrink(),

                  // Input content
                  buildInput(),
                ],
              ),

              // Loading
              buildLoading()
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSticker() {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)), color: Colors.white),
        padding: const EdgeInsets.all(5),
        height: 180.h,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi1', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/Images/mimi1.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi2', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/Images/mimi2.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi3', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/Images/mimi3.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi4', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/Images/mimi4.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi5', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/Images/mimi5.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi6', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/Images/mimi6.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi7', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/Images/mimi7.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi8', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/Images/mimi8.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi9', TypeMessage.sticker),
                  child: Image.asset(
                    'assets/Images/mimi9.gif',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const LoadingView() : const SizedBox.shrink(),
    );
  }

   openCameraDialog(BuildContext context) {
    return SizedBox(
      height: 130.h,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r)),
        child: Padding(
          padding:  EdgeInsets.all(5.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                  icon: Icon(
                    Icons.photo_library,
                    color: appColor,
                    size: 18.h,
                  ),
                  label: const Text("From Gallery",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                  await Utils.pickImageFromGallery()
                      .then((pickedFile) async {
                    // Step #2: Check if we actually picked an image. Otherwise -> stop;
                    if (pickedFile == null) return;

                    // Step #3: Crop earlier selected image
                    await Utils.cropSelectedImage(
                        pickedFile.path)
                        .then((croppedFile) {
                      // Step #4: Check if we actually cropped an image. Otherwise -> stop;
                      if (croppedFile == null) return;
                        imageFile = CroppedFile(croppedFile.path);
                        if (imageFile != null) {
                          setState(() {
                            isLoading = true;
                          });
                          uploadFile();
                        }
                    });
                  });
                  }),
              TextButton.icon(
                icon: Icon(
                  Icons.photo_camera_rounded,
                  color: appColor,
                  size: 18.h,
                ),
                label: const Text("From Camera",
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                await Utils.pickImageFromCamera()
                    .then((pickedFile) async {
     // Step #2: Check if we actually picked an image. Otherwise -> stop;
     if (pickedFile == null) return;

     // Step #3: Crop earlier selected image
     await Utils.cropSelectedImage(
     pickedFile.path)
         .then((croppedFile) {
     // Step #4: Check if we actually cropped an image. Otherwise -> stop;
     if (croppedFile == null) return;
     imageFile = CroppedFile(croppedFile.path);
     if (imageFile != null) {
     setState(() {
     isLoading = true;
     });
     uploadFile();
     }
     });
                });
                },
              ),
              TextButton.icon(
                icon: Icon(
                  Icons.picture_as_pdf_rounded,
                  color: appColor,
                  size: 18.h,
                ),
                label: Text("Pdf File",
                  style: GoogleFonts.roboto(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  pickFile();
                  //Navigator.of(context).pop();
                },
              )
            ],
          ),
        ),
      ),
    );
  }


  Widget buildInput() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: ColorConstants.greyColor2, width: 0.5)), color: Colors.white),
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            color: Colors.white,
            child: IconButton(
              icon: Icon(Icons.attach_file_rounded,color: appColor,size: 18.h,),
              onPressed : ()  =>{
                showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
              content: openCameraDialog(ctx),
              ),
              )
    } ,
              color: ColorConstants.primaryColor,
            ),
          ),
          Material(
            color: Colors.white,
            child: IconButton(
              icon: Icon(Icons.face,color: appColor,size: 18.h,),
              onPressed: getSticker,
              color: ColorConstants.primaryColor,
            ),
          ),

          // Edit text
          Flexible(
            child: TextField(
              onSubmitted: (value) {
                onSendMessage(textEditingController.text, TypeMessage.text);
              },
              style: const TextStyle(color: ColorConstants.primaryColor, fontSize: 15),
              controller: textEditingController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: ColorConstants.greyColor),
              ),
              focusNode: focusNode,
              autofocus: true,
            ),
          ),

          // Button send message
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: Icon(Icons.send,color: appColor,size: 20.h,),
                onPressed: () => onSendMessage(textEditingController.text, TypeMessage.text),
                color: ColorConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Stream<QuerySnapshot> getChatStream(String groupChatId, int limit) {
    return FirebaseFirestore.instance
        .collection(FirestoreConstants.pathMessageCollection)
        .doc(groupChatId)
        .collection(groupChatId)
        .orderBy(FirestoreConstants.timestamp, descending: true)
        .limit(limit)
        .snapshots();
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(FirestoreConstants.pathMessageCollection)
                  .doc(groupChatId)
                  .collection(groupChatId)
                  .orderBy(FirestoreConstants.timestamp, descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = snapshot.data!.docs;
                  if (listMessage.isNotEmpty) {
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemBuilder: (context, index) => buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: listScrollController,
                    );
                  } else {
                    return const Center(child: Text("No message here yet..."));
                  }
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: ColorConstants.themeColor,
                    ),
                  );
                }
              },
            )
          : const Center(
              child: CircularProgressIndicator(
                color: ColorConstants.themeColor,
              ),
            ),
    );
  }
}

class ChatPageArguments {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  ChatPageArguments({required this.peerId, required this.peerAvatar, required this.peerNickname});
}
