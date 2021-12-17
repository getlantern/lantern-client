import 'dart:io';
import 'package:lantern/common/ui/button.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:lantern/common/ui/base_screen.dart';
import 'package:lantern/common/ui/colors.dart';
import 'package:lantern/common/ui/custom/asset_image.dart';
import 'package:lantern/common/ui/custom/list_item_factory.dart';
import 'package:lantern/common/ui/custom/text.dart';
import 'package:lantern/common/ui/image_paths.dart';
import 'package:lantern/common/ui/text_styles.dart';
import 'package:lantern/i18n/i18n.dart';
import 'package:lantern/replica/logic/uploader.dart';
import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

// ReplicaUploadFileScreen renders a single-item ListView with the contents of
// 'fileToUpload', allowing the user to change the display name of the upload.
class ReplicaUploadFileScreen extends StatefulWidget {
  final File fileToUpload;
  ReplicaUploadFileScreen({Key? key, required this.fileToUpload});

  @override
  State<StatefulWidget> createState() => _ReplicaUploadFileScreenState();
}

class _ReplicaUploadFileScreenState extends State<ReplicaUploadFileScreen> {
  final _textEditingController = TextEditingController();
  late String _displayName;

  @override
  void initState() {
    _displayName =
        path.withoutExtension(path.basename(widget.fileToUpload.path));
    _textEditingController.text = _displayName;
    ReplicaUploader.inst.init();
    super.initState();
  }

  Widget renderSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 30.0),
      child: TextFormField(
        controller: _textEditingController,
        textInputAction: TextInputAction.search,
        onFieldSubmitted: (query) async {
          setState(() {
            _displayName = query;
          });
        },
        decoration: InputDecoration(
          labelText: 'name_your_file'.i18n,
          prefixIcon: const Icon(Icons.edit),
          contentPadding:
              const EdgeInsetsDirectional.fromSTEB(20.0, 10.0, 20.0, 10.0),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: blue4,
              width: 2.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: blue4,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget renderUploadList() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
          scrollDirection: Axis.vertical,
          // Shrinkwrap is true for convenience since this will always be a
          // single element list
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return ListItemFactory.uploadEditItem(
                leading: const CAssetImage(path: ImagePaths.spreadsheet),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  verticalDirection: VerticalDirection.down,
                  children: [
                    CText(
                      _displayName,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: tsSubtitle1Short,
                    ),
                    // Render mime type
                    // If mimetype is nil, just render 'app/unknown'
                    Row(
                      children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.0)),
                        if (path.extension(widget.fileToUpload.path).isNotEmpty)
                          CText(
                            path
                                .extension(widget.fileToUpload.path)
                                .toUpperCase()
                                .replaceAll('.', ''),
                            style: tsBody1.copiedWith(color: pink4),
                          )
                        else
                          CText(
                            'image_unknown'.i18n,
                            style: tsBody1.copiedWith(color: pink4),
                          ),
                      ],
                    )
                  ],
                ));
          },
          separatorBuilder: (context, index) => const SizedBox.shrink(),
          itemCount: 1),
    );
  }

  Widget renderUploadButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Align(
          alignment: FractionalOffset.bottomCenter,
          child: Button(
            width: 200,
            text: 'upload'.i18n,
            onPressed: () async {
              await ReplicaUploader.inst.uploadFile(
                  widget.fileToUpload,
                  // Add the display name with the extension
                  '$_displayName.${path.extension(widget.fileToUpload.path)}');
              Navigator.of(context).pop();
            },
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Dismiss keyboard when clicking anywhere
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: BaseScreen(
            showAppBar: true,
            title: 'upload_file_screen'.i18n,
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  renderSearchBar(),
                  renderUploadList(),
                  renderUploadButton()
                ],
              ),
            )));
  }

  // agreeAction: () => ,
}
