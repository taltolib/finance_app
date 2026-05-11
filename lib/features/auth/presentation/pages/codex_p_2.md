Ты работаешь в проекте finance_app.

Задача: восстановить последние правильные изменения по auth flow, которые были потеряны после переключения ветки.

ВАЖНО:
Не откатывай мои изменения, где я перевёл API слой на Dio вместо http.
Dio оставь. Не возвращай http.
Все изменения ниже нужно реализовать поверх текущего Dio ApiService.

Что нужно восстановить:

1. Auth backend contract

Backend работает так:

POST /auth/send-code

Body:
{
"phone": "+998901234567"
}

Response:
{
"success": true,
"phone_code_hash": "...",
"message": "Код отправлен в Telegram"
}

POST /auth/verify-code

Body:
{
"phone": "+998901234567",
"phone_code_hash": "...",
"code": "12345"
}

Response:
{
"success": true,
"session_token": "...",
"user": {
"id": 123,
"name": "...",
"first_name": "...",
"last_name": "...",
"username": "...",
"phone": "+998...",
"photo_base64": "..."
}
}

2. Исправить auth_models.dart

SendCodeResponse должен хранить phoneCodeHash, а не requestId.

Нужно:
- success
- message
- phoneCodeHash

Парсить:
json['phone_code_hash']

VerifyCodeResponse должен парсить:
json['session_token']
json['user']

UserInfo должен поддерживать поля backend:
- id
- phone
- name
- first_name
- last_name
- username
- photo_base64

id может приходить как int, поэтому парсить через toString().

3. Исправить AuthApiService

Файл:
lib/features/auth/data/services/auth_api_service.dart

Оставить Dio через текущий ApiService.

sendCode должен отправлять:

body: {
'phone': phoneNumber,
}

НЕ отправлять:
'phone_number'

verifyCode должен принимать:
- phoneNumber
- phoneCodeHash
- code
- optional password

И отправлять:

body: {
'phone': phoneNumber,
'phone_code_hash': phoneCodeHash,
'code': code,
if (password != null && password.isNotEmpty) 'password': password,
}

НЕ отправлять:
'phone_number'

4. Исправить AuthProvider

Файл:
lib/features/auth/presentation/providers/auth_provider.dart

Добавить состояние:

String? _phoneCodeHash;
String? get phoneCodeHash => _phoneCodeHash;

Добавить enum:

enum AuthStatus {
initial,
loading,
success,
error,
}

Добавить:

AuthStatus _status = AuthStatus.initial;
AuthStatus get status => _status;

sendCode должен:
- поставить loading
- вызвать _apiService.sendCode(phoneNumber: phoneNumber)
- если success и phoneCodeHash != null:
    - сохранить _phoneNumber = phoneNumber
    - сохранить _phoneCodeHash = response.phoneCodeHash
    - status = success
    - вернуть true
- если phoneCodeHash нет:
    - error = 'Backend не вернул phone_code_hash'
    - status = error
    - вернуть false

verifyCode должен:
- проверить, что _phoneNumber не null
- проверить, что _phoneCodeHash не null
- вызвать:

_apiService.verifyCode(
phoneNumber: _phoneNumber!,
phoneCodeHash: _phoneCodeHash!,
code: code,
)

- если success и sessionToken != null:
    - сохранить _sessionToken
    - сохранить _user
    - _isAuthenticated = true
    - записать session_token в FlutterSecureStorage
    - ApiService().setSessionToken(response.sessionToken!)
    - вернуть true

logout должен очищать:
- _phoneNumber
- _phoneCodeHash
- _sessionToken
- _user
- _isAuthenticated
- _error
- secure storage session_token
- ApiService token

5. Добавить OtpProvider

Создать файл:
lib/features/auth/presentation/providers/otp_provider.dart

Он должен:
- создавать 6 TextEditingController
- создавать 6 FocusNode
- иметь getter code, который склеивает все controllers
- иметь onChanged(index, value):
    - если ввели цифру, переходить на следующий FocusNode
    - если удалили, переходить на предыдущий FocusNode
    - notifyListeners()
- dispose должен чистить controllers и focusNodes

6. Исправить OtpPage

Файл:
lib/features/auth/presentation/pages/otp_page.dart

OtpPage должен принимать:

final String phone;
final VoidCallback onOTPVerified;

Внутри использовать:

final authProv = context.watch<AuthProvider>();
final otpProv = context.watch<OtpProvider>();
final isLoading = authProv.isVerifyingCode;

Кнопка "Подтвердить":
- если isLoading, не нажимается
- иначе вызывает _handleVerify(context)

_handleVerify:
- берёт code из otpProvider.code
- если пусто: TopSnackBar.show(context, 'Введите код')
- если длина не 6: TopSnackBar.show(context, 'Введите полный код из 6 цифр')
- вызывает authProvider.verifyCode(code)
- если success:
    - TopSnackBar.show(context, 'Код подтверждён')
    - onOTPVerified()
- иначе:
    - показать authProvider.error ?? 'Неверный код'

7. Исправить GoRouter

В route телефона:

PhoneAuthPage(
onPhoneSubmitted: (phone) {
context.go('/auth/otp', extra: phone);
},
)

В route OTP:

GoRoute(
path: '/auth/otp',
name: 'otp',
builder: (context, state) {
final phone = state.extra as String? ?? '';

    return ChangeNotifierProvider(
      create: (_) => OtpProvider(),
      child: OtpPage(
        phone: phone,
        onOTPVerified: () {
          context.go('/auth/password');
        },
      ),
    );
},
)

Обязательно импортировать:
import 'package:provider/provider.dart';
import '../../features/auth/presentation/providers/otp_provider.dart';

8. PhoneAuthPage

Оставить текущий дизайн.
Логику оставить такую:
- пользователь вводит только 9 цифр после +998
- fullPhone = '+998$rawPhone'
- authProvider.sendCode(fullPhone)
- если success:
    - TopSnackBar.show(context, 'Код отправлен в Telegram')
    - widget.onPhoneSubmitted(fullPhone)

9. Фон темы

В PhoneAuthPage не создавать отдельный BackgroundProvider.
Использовать реальную тему:

final isDark = Theme.of(context).brightness == Brightness.dark;

И картинку:

Image.asset(
isDark
? 'assets/images/kanban_bg_dark.png'
: 'assets/images/kanban_bg.png',
key: ValueKey(isDark),
fit: BoxFit.cover,
)

Не использовать отдельную логику authBackgroundAsset, если она конфликтует с Theme.of(context).

10. ApiService

Не откатывать Dio.
Dio оставить.
Но убедиться, что post отправляет JSON нормально через Dio.
Если сейчас используется jsonEncode(body), можно оставить, если headers Content-Type application/json.
Главное не возвращать старый http-клиент.

11. Проверить после изменений

Проверить, что flow работает:

- Ввод номера
- POST /auth/send-code получает body { "phone": "+998..." }
- Backend возвращает phone_code_hash
- AuthProvider сохраняет phoneCodeHash
- GoRouter переводит на /auth/otp
- Ввод OTP
- POST /auth/verify-code получает body:
  {
  "phone": "+998...",
  "phone_code_hash": "...",
  "code": "..."
  }
- Backend возвращает session_token
- Flutter сохраняет session_token

12. Нельзя делать

- Не возвращать http вместо Dio
- Не отправлять phone_number
- Не удалять TopSnackBar
- Не ломать дизайн PhoneAuthPage
- Не убирать PushButton
- Не делать отдельный background provider
- Не хранить OTP controllers в AuthProvider
- Не подключать OtpProvider глобально, только на OTP route

Сделай изменения аккуратно, минимальным diff, без переписывания всего проекта.

 то что уже реализовано нетрогай по не обходимости
 
сперва сказируй вес проект и потом только начни