// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

// Project imports:
import './../../../utils/styles.dart';
import './../../constants/zego_page_constant.dart';
import './../../firebase/zego_login_manager.dart';

class SettingsLogoutBlock extends StatelessWidget {
  const SettingsLogoutBlock({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          height: 98.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: StyleColors.settingsCellBackgroundColor,
          ),
          child: Center(
              child: Text(AppLocalizations.of(context)!.settingPageLogout,
                  textAlign: TextAlign.center,
                  style: StyleConstant.settingLogout))),
      onTap: () {
        logout(context);
      },
    );
  }

  Future<void> logout(BuildContext context) async {
    await GoogleSignIn().signOut();
    ZegoLoginManager.shared.logout();

    Navigator.pushReplacementNamed(context, PageRouteNames.login);
  }
}
