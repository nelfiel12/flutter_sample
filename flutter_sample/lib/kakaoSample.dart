import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/all.dart';

import 'Log.dart';

class KakaoSample extends StatefulWidget {
  @override
  KakaoSampleState createState() {
    // TODO: implement createState
    return KakaoSampleState();
  }
}

class KakaoSampleState extends State<KakaoSample> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text('Kakao test'),),
      body: Center(
        child: ListView(
          children: [
            Card(
              child: ListTile(title: Text('login'), onTap: () async {
                AccessToken accessToken = await _kakaoLogin();

                if(accessToken == null) {
                  debug('no token');
                } else {
                  debug('accessToken : ${accessToken.accessToken}');
                  debug('refreshToken: ${accessToken.refreshToken}');
                  debug('accessTokenExpiresAt : ${accessToken.accessTokenExpiresAt}');
                  debug('refreshTokenExpiresAt : ${accessToken.refreshTokenExpiresAt}');
                }
              },),
            ),

            Card(
              child: ListTile(title: Text('getToken'), onTap: () async {
                await _getKakaoToken();
              },),
            )
          ],
        ),
      ),
    );
  }

  Future<AccessToken> _kakaoLogin() async {

    bool bAlreadyLogin = false;

    try {
      AccessToken token = await AccessTokenStore.instance.fromStore();
      bAlreadyLogin = token != null && token.refreshToken != null;

      if(bAlreadyLogin) {
        debug('already login');
        return token;
      }

    } catch (e) {
      error(e.toString());
    }

    bool kakaoTalkInstalled = false;
    String authCode;

    try {
      kakaoTalkInstalled = await isKakaoTalkInstalled();

      if(kakaoTalkInstalled) {
        authCode = await AuthCodeClient.instance.requestWithTalk();
      }
    } catch(e) {
      //공기계에 카카오톡 설치 되어 있는 경우 NotSupport exception 발생
      error(e.toString());
    }

    if(!kakaoTalkInstalled) {
      try {
        authCode = await AuthCodeClient.instance.request();
      } on PlatformException catch(e) {
        switch(e.code) {
          case 'CANCELED':
            break;
        }
        error(e.toString());
      } catch(e) {
        error(e.toString());
      }
    }

    debug('authCode : ${authCode != null ? authCode : 'null'}');

    if(authCode != null) {
      try {
        AccessTokenResponse token = await AuthApi.instance.issueAccessToken(authCode);
        return await AccessTokenStore.instance.toStore(token);
      } catch(e) {
        error(e.toString());
      }
    }

    return null;
  }

  Future<AccessToken> _getKakaoToken() async {
    AccessToken accessToken = await AccessTokenStore.instance.fromStore();

    if(accessToken.accessToken == null || accessToken.refreshToken == null) {
      debug('no token');
      await AccessTokenStore.instance.clear();
      return null;
    } else {
      if(accessToken.accessTokenExpiresAt.isBefore(DateTime.now())) {
        String log = 'accessToken ${accessToken.accessTokenExpiresAt} -> ';

        AccessTokenResponse response = await AuthApi.instance.refreshAccessToken(accessToken.refreshToken);
        accessToken = await AccessTokenStore.instance.toStore(response);

        log += '${accessToken.accessTokenExpiresAt}';
        debug(log);
      }

      debug('accessToken : ${accessToken.accessToken}');
      debug('refreshToken: ${accessToken.refreshToken}');
      debug('accessTokenExpiresAt : ${accessToken.accessTokenExpiresAt}');
      debug('refreshTokenExpiresAt : ${accessToken.refreshTokenExpiresAt}');

      return accessToken;
    }
  }
}