import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:lantern/common/common.dart';
import 'package:lantern/replica/common.dart';

class ReplicaUploadDescription extends StatefulWidget {
  final File fileToUpload;
  final String fileTitle;

  ReplicaUploadDescription({
    Key? key,
    required this.fileToUpload,
    required this.fileTitle,
  });

  @override
  State<StatefulWidget> createState() => ReplicaUploadDescriptionState();
}

class ReplicaUploadDescriptionState extends State<ReplicaUploadDescription> {
  final formKey = GlobalKey<FormState>(debugLabel: 'replicaUploadDescription');
  late final textEditingController =
      CustomTextEditingController(formKey: formKey);
  late String fileDescription;

  @override
  void initState() {
    fileDescription = '';
    textEditingController.text = fileDescription;
    ReplicaUploader.inst.init();
    super.initState();
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
        padHorizontal: true,
        title: 'add_description'.i18n,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              renderDescriptionField(),
              renderReviewButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget renderDescriptionField() {
    return CTextField(
      minLines: 10,
      keyboardType: TextInputType.text,
      controller: textEditingController,
      label: 'add_description'.i18n,
      style: tsBody2,
      initialValue: 'description_initial_value'.i18n,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (value) async {
        setState(() {
          fileDescription = value;
        });
      },
    );
  }

  Widget renderReviewButton() {
    return Align(
      alignment: FractionalOffset.bottomCenter,
      child: Button(
        width: 200,
        text: 'review'.i18n,
        onPressed: () async => await context.pushRoute(
          ReplicaUploadReview(
            fileToUpload: widget.fileToUpload,
            fileTitle: widget.fileTitle,
            fileDescription: fileDescription,
          ),
        ),
      ),
    );
  }
}
