import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';


/**
 * 카카오톡이 미설치된 디바이스의 경우 카톡 네이티브 앱 대신 브라우저(팝업)으로 공유하기를 할 수 있도록 지원하는데,
 * 해당 케이스의 경우 카톡 공유가 정상적으로 처리되었음에도 try~catch 문에서 예외가 발생하면서 log에 에러 메시지가 찍힘
 * 해당 오류는 공유하기가 카카오톡 네이티브 앱이 아닌 웹에서 실행되기 때문에 카카오 sdk에서 공유 성공 여부를 알지 못해 발생하는 오류라고 함
 * 카카오톡 측에서도 어쩔 수 없는 오류라고 하여, 해당 오류에 한해서만 정상 로직으로 처리되게 하라고 권장함
 * 관련 문서: https://incurio.tistory.com/9
 */

Future<FeedTemplate> makeTemplate(
    Uint8List uint8list, String stmPaperName, String stmName) async {
  Directory tempDir = await getApplicationDocumentsDirectory();
  String tempPath = '${tempDir.path}/abc.txt';
  // print("경로: ${tempPath}");

  File file = File(tempPath);
  await file.writeAsBytes(uint8list);

  try {
    // 카카오 이미지 서버로 업로드
    ImageUploadResult imageUploadResult =
        await ShareClient.instance.uploadImage(image: file);
     print('이미지 업로드 성공'
         '\n${imageUploadResult.infos.original.url}');

    final FeedTemplate template = FeedTemplate(
      content: Content(
        title: stmPaperName == "전체 정산서"
            ? "Yemon에서 정산한 '$stmName'의 정산서가 도착했어요"
            : "Yemon에서 정산한 '$stmPaperName' 님의 '$stmName' 정산서가 도착했어요!",
        imageUrl: Uri.parse("https://i.ibb.co/QMJfGnR/Yemon-Icon-text.png"),
        imageHeight: 600,
        imageWidth: 1024,
        link: Link(
            webUrl: Uri.parse(imageUploadResult.infos.original.url),
            mobileWebUrl: Uri.parse(imageUploadResult.infos.original.url)),
      ),
      buttons: [
        Button(
          title: "정산서 보기",
          link: Link(
              webUrl: Uri.parse(imageUploadResult.infos.original.url),
              mobileWebUrl: Uri.parse(imageUploadResult.infos.original.url)),
        ),
      ],
    );

    return template;
  } catch (error) {
     print('이미지 업로드 실패 $error');
  }

  exit(0);
}

void shareMessage(Uint8List image, String stmPaperName, String stmName) async {
  final createdTemplate = await makeTemplate(image, stmPaperName, stmName);

  // 카카오톡 실행 가능 여부 확인
  bool isKakaoTalkSharingAvailable =
      await ShareClient.instance.isKakaoTalkSharingAvailable();

  if (isKakaoTalkSharingAvailable) {
    try {
      Uri uri =
          await ShareClient.instance.shareDefault(template: createdTemplate);
      await ShareClient.instance.launchKakaoTalk(uri);
      print('카카오톡 공유 완료');
    } catch (error) {
        print('카카오톡 공유 실패 $error');
    }
  } else { //카카오 미설치 사용자 일 시 웹으로 카카오톡 공유하기 기능 지원
    try {
      Uri shareUrl = await WebSharerClient.instance
          .makeDefaultUrl(template: createdTemplate);
      await launchBrowserTab(shareUrl, popupOpen: true);
    } catch (error) {
      //해당 에러에 한해서만 정상 로직으로 처리되게 코드 리팩토링
      if(error.runtimeType.toString() ==  "PlatformException") {
        print('카카오톡 공유 완료');
      } else {
        print('카카오톡 공유 실패 $error');
      }
    }
  }
}
