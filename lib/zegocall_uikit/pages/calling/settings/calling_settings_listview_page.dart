// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:zego_call_flutter/utils/styles.dart';
import 'package:zego_call_flutter/zegocall/core/zego_call_defines.dart';
import '../../../../zegocall/core/interface/zego_device_service.dart';
import 'calling_settings_defines.dart';
import 'calling_settings_item.dart';

import 'package:zego_call_flutter/zegocall/core/interface_imp/zego_device_service'
    '_impl.dart';

class CallingSettingsListViewPage<T> extends StatelessWidget {
  final String title;

  final String selectedValue;
  final Map<T, String> model;

  final ValueChanged<int> pageIndexChanged;
  final void Function(T) onSelected;

  const CallingSettingsListViewPage(
      {required this.title,
      required this.selectedValue,
      required this.model,
      required this.pageIndexChanged,
      required this.onSelected,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(32.0.w, 23.0.h, 32.0.w, 40.0.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
            child: Container(
                //  transparent decoration's target is make gesture work if click empty space
                decoration: const BoxDecoration(color: Colors.transparent),
                height: 85.h,
                child: header()),
            onTap: () {
              pageIndexChanged(CallingSettingPageIndexExtension
                  .valueMap[CallingSettingPageIndex.mainPageIndex]!);
            }),
        SizedBox(
          width: double.infinity,
          height: 600.h,
          child: body(context),
        )
      ]),
    );
  }

  Widget header() {
    return Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            SizedBox(
              width: 56.w,
              child: Image.asset(StyleIconUrls.settingBack),
            ),
            SizedBox(
              width: 18.w,
            ),
            Text(title, style: StyleConstant.callingSettingTitleText),
          ],
        ));
  }

  Widget body(BuildContext context) {
    return ListView.builder(
      itemExtent: 148.h,
      padding: EdgeInsets.only(left: 32.w, right: 32.w),
      itemCount: model.length,
      itemBuilder: (_, i) {
        var key = model.keys.elementAt(i);
        String value = model[key]!;
        return CallingSettingsListItem<T>(
          title: value,
          value: key,
          isChecked: selectedValue == value,
          onSelected: (T selectedValue) {
            onSelected(selectedValue);

            pageIndexChanged(CallingSettingPageIndexExtension
                .valueMap[CallingSettingPageIndex.mainPageIndex]!);
          },
        );
      },
    );
  }
}

class CallingVideoResolutionSettingsPage extends StatelessWidget {
  final ValueChanged<int> pageIndexChanged;
  final ValueChanged<String> valueChanged;
  final String selectedValue;

  const CallingVideoResolutionSettingsPage(
      {required this.pageIndexChanged,
      required this.valueChanged,
      required this.selectedValue,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CallingSettingsListViewPage<ZegoVideoResolution>(
        title: 'Resolution Settings',
        selectedValue: selectedValue,
        model: listModel(context),
        pageIndexChanged: pageIndexChanged,
        onSelected: (ZegoVideoResolution selectedValue) {
          var deviceService = context.read<IZegoDeviceService>();
          deviceService.setVideoResolution(selectedValue);

          valueChanged(getResolutionString(selectedValue));
        });
  }

  Map<ZegoVideoResolution, String> listModel(BuildContext context) {
    Map<ZegoVideoResolution, String> model = {};
    model[ZegoVideoResolution.v180P] =
        getResolutionString(ZegoVideoResolution.v180P);
    model[ZegoVideoResolution.v270P] =
        getResolutionString(ZegoVideoResolution.v270P);
    model[ZegoVideoResolution.v360P] =
        getResolutionString(ZegoVideoResolution.v360P);
    model[ZegoVideoResolution.v540P] =
        getResolutionString(ZegoVideoResolution.v540P);
    model[ZegoVideoResolution.v720P] =
        getResolutionString(ZegoVideoResolution.v720P);
    model[ZegoVideoResolution.v1080P] =
        getResolutionString(ZegoVideoResolution.v1080P);

    return model;
  }
}

class CallingAudioBitrateSettingsPage extends StatelessWidget {
  final ValueChanged<int> pageIndexChanged;
  final ValueChanged<String> valueChanged;
  final String selectedValue;

  const CallingAudioBitrateSettingsPage(
      {required this.pageIndexChanged,
      required this.valueChanged,
      required this.selectedValue,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CallingSettingsListViewPage<ZegoAudioBitrate>(
        title: 'Audio Bitrate Settings',
        selectedValue: selectedValue,
        model: listModel(context),
        pageIndexChanged: pageIndexChanged,
        onSelected: (ZegoAudioBitrate selectedValue) {
          var deviceService = context.read<IZegoDeviceService>();
          deviceService.setAudioBitrate(selectedValue);

          valueChanged(getBitrateString(selectedValue));
        });
  }

  Map<ZegoAudioBitrate, String> listModel(BuildContext context) {
    Map<ZegoAudioBitrate, String> model = {};
    model[ZegoAudioBitrate.b16] = getBitrateString(ZegoAudioBitrate.b16);
    model[ZegoAudioBitrate.b48] = getBitrateString(ZegoAudioBitrate.b48);
    model[ZegoAudioBitrate.b56] = getBitrateString(ZegoAudioBitrate.b56);
    model[ZegoAudioBitrate.b96] = getBitrateString(ZegoAudioBitrate.b96);
    model[ZegoAudioBitrate.b128] = getBitrateString(ZegoAudioBitrate.b128);

    return model;
  }
}
