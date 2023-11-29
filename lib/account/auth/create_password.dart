import '../../common/common.dart';

@RoutePage<void>(name: 'CreatePassword')
class CreatePassword extends StatefulWidget {
  const CreatePassword({super.key});

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  final _passwordFormKey = GlobalKey<FormState>();
  late final _passwordController = CustomTextEditingController(
    formKey: _passwordFormKey,
  );
  bool obscureText = false;

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      title: 'enter_password'.i18n,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildHeader(),
            const SizedBox(height: 24),
            Form(
              key: _passwordFormKey,
              child: CTextField(
                controller: _passwordController,
                label: "enter_password".i18n,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                maxLines: 1,
                prefixIcon: SvgPicture.asset(ImagePaths.lock),
                // actionIconPath:ImagePaths.eye ,
                suffixIcon:SvgPicture.asset(ImagePaths.eye),
                // suffix: SvgPicture.asset(ImagePaths.eye),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Button(

                // disabled: _passwordController.text.isEmpty ||
                //     _passwordFormKey?.currentState?.validate() == false,
                text: 'continue'.i18n,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SvgPicture.asset(
          ImagePaths.lantern_logo,
          height: 42,
        ),
        const SizedBox(width: 15),
        SvgPicture.asset(
          ImagePaths.free_logo,
          height: 25,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFormKey.currentState?.dispose();
    super.dispose();
  }
}
