import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:sms_autofill/sms_autofill.dart';

class SmsVerificationPage extends StatefulWidget {
  const SmsVerificationPage({Key? key}) : super(key: key);

  @override
  State<SmsVerificationPage> createState() => _SmsVerificationPageState();
}

class _SmsVerificationPageState extends State<SmsVerificationPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  int levelClock = 2 * 60;
  //this is app signature which is required to fetch sms automatically and should be sent with sms
  final String appSignature = 'kJkzitrofmS';
  // void _sendSMS(String message, List<String> recipents) async {
  //   String _result =
  //       await sendSMS(message: message, recipients: recipents, sendDirect: true)
  //           .catchError((onError) {
  //     print(onError);
  //   });
  //   print(_result);
  // }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(seconds: levelClock));

    _animationController!.forward();
    // _sendSMS(
    //   'Sms Test: Your code is 1234\n$appSignature',
    //   ['+923461504405'],
    // );

    _listenSmsCode();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    _animationController!.dispose();
    super.dispose();
  }

  _listenSmsCode() async {
    await SmsAutoFill().listenForCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F4FD),
      appBar: AppBar(
        title: const Text("SMS OTP AutoFill"),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Text("Verification"),
                  Text(
                    "We sent you a SMS Code",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "On number: +923461504405",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
            Center(
              child: PinFieldAutoFill(
                codeLength: 4,
                autoFocus: true,
                decoration: UnderlineDecoration(
                  lineHeight: 2,
                  lineStrokeCap: StrokeCap.square,
                  bgColorBuilder: PinListenColorBuilder(
                      Colors.green.shade200, Colors.grey.shade200),
                  colorBuilder: const FixedColorBuilder(Colors.transparent),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Resend code after: "),
                Countdown(
                  animation: StepTween(
                    begin: levelClock, // THIS IS A USER ENTERED NUMBER
                    end: 0,
                  ).animate(_animationController!),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
            height: 56,
            width: 200,
            child: ElevatedButton(
              onPressed: () async {
                //?  use this code to get sms signature for your app
                final String signature = await SmsAutoFill().getAppSignature;
                print("Signature: $signature");

                _animationController!.reset();
                _animationController!.forward();
              },
              child: const Text("Resend"),
            ),
          ),
          SizedBox(
            height: 56,
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                //Confirm and Navigate to Home Page
              },
              child: const Text("Confirm"),
            ),
          ),
        ],
      ),
    );
  }
}

class Countdown extends AnimatedWidget {
  const Countdown({Key? key, required this.animation})
      : super(key: key, listenable: animation);
  final Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';
    return Text(
      timerText,
      style: TextStyle(
        fontSize: 18,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
