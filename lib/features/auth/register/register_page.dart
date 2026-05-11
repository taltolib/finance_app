import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:progress/core/providers/auth_provider.dart';
import 'package:progress/core/theme/colors/app_colors.dart';
import 'package:progress/core/theme/colors/theme_custom.dart';
import 'package:progress/domain/enums/auth_status.dart';
import 'package:progress/generated/fonts/app_fonts.dart';
import 'package:progress/generated/image/app_image.dart';
import 'package:progress/generated/tr/locale_keys.dart';
import 'package:progress/shared/widget/%20top_snackbar.dart';
import 'package:progress/shared/widget/google_sign_in_button.dart';
import 'package:progress/shared/widget/push_button.dart';
import 'package:provider/provider.dart';

import '../../../shared/widgets/push_button.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    ///создай провайдер или блок и поклучи его здесь если  не обходимо
    final size = MediaQuery.of(context).size;

    return Scaffold(
      /// Сейчас задний фон  цветной работает и менятся через тему замени это что задным фоне была картинка которая у меня находится в ассест/имаже чтобы в зависемости от цвета фона она меналось
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.42,
              child: Stack(
                children: [
                  ///здесь должен быть имейдж
                  Container(
                    height: size.height * 0.42,
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(40),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          '',
                          style: AppFonts.mulish.s24w700(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                        color: ///здесь должен быть цвет темы ,
                        borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: colors.shadow.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [

                  Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: colors.backgroundWhiteOrDark///здесь цвет который ночетается с темати например если черный тема (в моем случии чут чус голубоватая ) чтобы с контейнером не перешалась найди подходаший цвет,
                    borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: prov.passwordController,
                obscureText: prov.obscurePassword,
                style: TextStyle(color: colors.text),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'[a-zA-Z0-9]'),
                  ),
                ],
                decoration: InputDecoration(
                    hintText: ''//текст чо что нужно ,
                    hintStyle: const TextStyle(color: Colors.grey ,fontSize: 14) //класс аппфондс,
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 16),
                suffixIcon: GestureDetector(
                  onTap: prov.togglePasswordVisibility,
                  child: Icon(
                    prov.obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: colors.text,
                    size: 16,
                  ),
                ),
              ),
            ),
      ),
                  const SizedBox(height: 10),
                  PushButton(
                    height: 70,
                    color: AppColors.green,
                    colorShadow: AppColors.blue,
                    border: Border.all(width: 2, color: AppColors.blueDark),
                    fontSize: 18,
                    colorText: AppColors.textWhite /// чтобы меналось в зависемости от темы,
                    borderRadius: 15,
                    language: prov.isLoading ? LocaleKeys.loading.tr() : LocaleKeys.login.tr() /// без локал кейсн просто нужный текст стринг,
                    flagAsset: prov.isLoading
                  ? const SizedBox(
                  width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ) : const SizedBox.shrink(),
              onTap: prov.isLoading ? () {} : () {
                prov.handleLogin(context, context.read<AuthProvider>(),);
                !AppPrefs.isSeen;
              } ,
              isSelected: false,
            ),
    //// и нужнн  тест если 2 кратной аутификации нет то можно нечего не писать
          ],
        ),
      ),
    ),
    ),
    ],
    ),
    ),
    );
  }
}
