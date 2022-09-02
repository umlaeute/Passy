import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:passy/common/common.dart';
import 'package:passy/passy_flutter/theme.dart';
import 'package:passy/passy_flutter/widgets/widgets.dart';

import 'assets.dart';

import 'backup_and_restore_screen.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({Key? key}) : super(key: key);

  static const routeName = '${BackupAndRestoreScreen.routeName}/backup';

  @override
  State<StatefulWidget> createState() => _BackupScreen();
}

class _BackupScreen extends State<BackupScreen> {
  void _onPassyBackup(String username) {
    FilePicker.platform
        .getDirectoryPath(dialogTitle: 'Backup Passy')
        .then((buDir) {
      if (buDir == null) return;
      data.backupAccount(username, buDir);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String _username =
        ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: PassyTheme.appBarButtonPadding,
          splashRadius: PassyTheme.appBarButtonSplashRadius,
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Backup'),
        centerTitle: true,
      ),
      body: ListView(children: [
        PassyPadding(ThreeWidgetButton(
          center: const Text('Passy backup'),
          left: SvgPicture.asset(
            logoCircleSvg,
            width: 25,
            color: PassyTheme.lightContentColor,
          ),
          right: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => _onPassyBackup(_username),
        )),
      ]),
    );
  }
}
