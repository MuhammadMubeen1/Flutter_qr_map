import 'dart:io';
import 'package:flutter/material.dart';


Future<dynamic>longitude(context) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          alignment: Alignment.centerRight,
          content: Container(
            height: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Do you want to exit?"),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          print('yes selected');
                          exit(0);
                        },
                        child:
                            Text("Yes", style: TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(primary: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                        child: ElevatedButton(
                      onPressed: () {
                       
                           
                            Navigator.of(context).pop();
                          
                      },
                      child: Text("No", style: TextStyle(color: Colors.black)),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                      ),
                    )),
                  ],
                )
              ],
            ),
          ),
        );
      });
}
