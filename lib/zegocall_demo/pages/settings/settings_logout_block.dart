// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/zego_call_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Project imports:
import './../../styles.dart';
import './../../core/login_manager.dart';

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
    LoginManager.shared.logout();
  }
}
