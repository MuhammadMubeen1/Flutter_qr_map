
import 'package:get/get.dart';
import 'package:sms_autofill/sms_autofill.dart';



  
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


import '../home/home_screen.dart';


class OTPControllerScreen extends StatefulWidget
{
  final String phone;
  final String codeDigits;
  String signature = "{{ app signature }}";
  String _code="";
  OTPControllerScreen({required this.phone, required this.codeDigits,});

  @override
  _OTPControllerScreenState createState() => _OTPControllerScreenState();
}



class _OTPControllerScreenState extends State<OTPControllerScreen> 
{
  final GlobalKey<ScaffoldState> _scaffolkey = GlobalKey<ScaffoldState>();
  TextEditingController _pinOTPCodeController = TextEditingController();
  final FocusNode _pinOTPCodeFoucus = FocusNode();
  
  var messageOtpCode = ''.obs;
  String? varificationCode;
String codeValue = "";
 String? appSignature;
  String? otpCode;
  final BoxDecoration pinOTPCodeDecoration = BoxDecoration(
      color: Colors.blueAccent,
      borderRadius: BorderRadius.circular(10.0),
      border: Border.all(
        color: Colors.grey,
      )
  );

@override



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
      
    _listenSmsCode();
    verifyPhoneNumber();
       _pinOTPCodeController = TextEditingController();
  super.initState();



  
  }


  _listenSmsCode() async {
    await SmsAutoFill().listenForCode();
  }
  @override
  void dispose() {
   
      SmsAutoFill().unregisterListener();
   
    super.dispose();
  }

  


  verifyPhoneNumber() async {
   await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "${widget.codeDigits + widget.phone }",
      verificationCompleted: (PhoneAuthCredential credential) async
      {
        await FirebaseAuth.instance.signInWithCredential(credential).then((value){
        setState(() {
          String otpValue = credential.smsCode.toString();
        });
          if(value.user != null)
          {
            Navigator.of(context).push(MaterialPageRoute(builder: (c) => HomeScreen()));
          }
        });
      },
      verificationFailed: (FirebaseAuthException e)
      {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message.toString()),
            duration:const  Duration(seconds: 3),
          ),
        );
      },
      codeSent: (String vID, int? resendToken)
      {
        setState(() {
         
          varificationCode = vID;
        
        });
      },
      codeAutoRetrievalTimeout: (String vID)
      {
        
        setState(() {
          varificationCode = vID;
        });
      },
      timeout: const Duration(seconds:20),
    );

    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffolkey,
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset("images/otp.png"),
          ),

          Container(
            margin:const  EdgeInsets.only(top: 20),
            child: Center(
              child: GestureDetector(
                onTap: (){
                  verifyPhoneNumber();
                },
                child: Text(
                  "Verifying : ${widget.codeDigits}-${widget.phone}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),

          Padding(
            padding:const  EdgeInsets.all(40.0),
            child:   PinFieldAutoFill(
              textInputAction: TextInputAction.done,
              focusNode: _pinOTPCodeFoucus,
              controller: _pinOTPCodeController,
             
              decoration: UnderlineDecoration(
                
                textStyle: const TextStyle(fontSize: 16, color: Colors.blue),
                colorBuilder: const FixedColorBuilder(
                  Colors.transparent,
                ),
                bgColorBuilder: FixedColorBuilder(
                  Colors.grey.withOpacity(0.2),
                ),
              ),
              currentCode: messageOtpCode.value,
              onCodeSubmitted: (code) async{
              
              },
              onCodeChanged: (code) async{
                   
              messageOtpCode.value = code!;
              
                if (code.length == 6) {
                   try{
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider
                      .credential(verificationId: varificationCode!, smsCode:code))
                      .then((value) {
                        if(value.user != null)
                        {
                          Navigator.of(context).push(MaterialPageRoute(builder: (c) => HomeScreen()));
                        }
                  });
                }
                catch(e){
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                   const  SnackBar(
                      content: Text("Invalid OTP"),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              
                
            
                  // To perform some operation
                }
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
         
        ]),
    );
    
  }
  
}
