import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

// final FeedTemplate defaultFeed = FeedTemplate(
//   content: Content(
//     title: '딸기 치즈 케익',
//     description: '#케익 #딸기 #삼평동 #카페 #분위기 #소개팅',
//     imageUrl: Uri.parse(
//         'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
//     link: Link(
//         webUrl: Uri.parse('https://developers.kakao.com'),
//         mobileWebUrl: Uri.parse('https://developers.kakao.com')),
//   ),
//   itemContent: ItemContent(
//     profileText: 'Kakao',
//     profileImageUrl: Uri.parse(
//         'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
//     titleImageUrl: Uri.parse(
//         'https://mud-kage.kakao.com/dn/Q2iNx/btqgeRgV54P/VLdBs9cvyn8BJXB3o7N8UK/kakaolink40_original.png'),
//     titleImageText: 'Cheese cake',
//     titleImageCategory: 'cake',
//     items: [
//       ItemInfo(item: 'cake1', itemOp: '1000원'),
//       ItemInfo(item: 'cake2', itemOp: '2000원'),
//       ItemInfo(item: 'cake3', itemOp: '3000원'),
//       ItemInfo(item: 'cake4', itemOp: '4000원'),
//       ItemInfo(item: 'cake5', itemOp: '5000원')
//     ],
//     sum: 'total',
//     sumOp: '15000원',
//   ),
//   social: Social(likeCount: 286, commentCount: 45, sharedCount: 845),
//   buttons: [
//     Button(
//       title: '웹으로 보기',
//       link: Link(
//         webUrl: Uri.parse('https: //developers.kakao.com'),
//         mobileWebUrl: Uri.parse('https: //developers.kakao.com'),
//       ),
//     ),
//     Button(
//       title: '앱으로보기',
//       link: Link(
//         androidExecutionParams: {'key1': 'value1', 'key2': 'value2'},
//         iosExecutionParams: {'key1': 'value1', 'key2': 'value2'},
//       ),
//     ),
//   ],
// );


Future<FeedTemplate> makeTemplate(Uint8List uint8list) async {

  Directory tempDir = await getApplicationDocumentsDirectory();
  String tempPath = '${tempDir.path}/abc.txt';
  log("경로: ${tempPath}");

  File file = File(tempPath); await file.writeAsBytes(uint8list);

  try {
    // 카카오 이미지 서버로 업로드
    ImageUploadResult imageUploadResult =
        await ShareClient.instance.uploadImage(image: file);
    print('이미지 업로드 성공'
        '\n${imageUploadResult.infos.original}');

    final FeedTemplate template = FeedTemplate(
      content: Content(
        title: "정산서",
        imageUrl: Uri.parse(imageUploadResult.infos.original.url),
        link: Link(
            mobileWebUrl: Uri.parse('https://developers.kakao.com')),
      ),
    );

    return template;

  } catch (error) {
    print('이미지 업로드 실패 $error');
  }

  exit(0);
}

void shareMessage(Uint8List image) async {

  final createdTemplate = await makeTemplate(image);

  // 카카오톡 실행 가능 여부 확인
  bool isKakaoTalkSharingAvailable = await ShareClient.instance
      .isKakaoTalkSharingAvailable();

  if (isKakaoTalkSharingAvailable) {
    try {
      Uri uri =
      await ShareClient.instance.shareDefault(template: createdTemplate);
      await ShareClient.instance.launchKakaoTalk(uri);
      log('카카오톡 공유 완료');
    } catch (error) {
      log('카카오톡 공유 실패 $error');
    }
  }
  else {
    try {
      Uri shareUrl = await WebSharerClient.instance
          .makeDefaultUrl(template: createdTemplate);
      await launchBrowserTab(shareUrl, popupOpen: true);
    } catch (error) {
      log('카카오톡 공유 실패 $error');
    }
  }

}


