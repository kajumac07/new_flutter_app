// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:jj_app/app/global/models/que_ans.dart';

// class QuestionAnswerSession extends StatefulWidget {
//   const QuestionAnswerSession({super.key});

//   @override
//   State<QuestionAnswerSession> createState() => _QuestionAnswerSessionState();
// }

// class _QuestionAnswerSessionState extends State<QuestionAnswerSession> {
//   bool isLoading = false;
//   bool isSubmitting = false;
//   final String getApiUrl = "https://api.nexever.org/api/questions-with-answers";
//   final String postApiUrl = "https://api.nexever.org/api/save-user-answer";
//   final String headervalue = "ba6h94mh4-x5h2-70s0-9217-v037v57810e7272fz";

//   late QuestionAnswerModel modeldata;
//   List<ChatMessage> chatMessages = [];
//   int currentQuestionIndex = 0;
//   Map<int, dynamic> selectedAnswers = {};
//   Map<int, TextEditingController> textControllers = {};
//   ScrollController scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     fetchQuestions();
//   }

//   @override
//   void dispose() {
//     for (var controller in textControllers.values) {
//       controller.dispose();
//     }
//     scrollController.dispose();
//     super.dispose();
//   }

//   void fetchQuestions() async {
//     setState(() {
//       isLoading = true;
//       chatMessages.add(
//         ChatMessage(text: "Loading questions...", isMe: false, isSystem: true),
//       );
//     });

//     try {
//       final response = await http.get(
//         Uri.parse(getApiUrl),
//         headers: {'x-api-key': headervalue},
//       );

//       if (response.statusCode == 200) {
//         final apiData = jsonDecode(response.body.toString());
//         modeldata = QuestionAnswerModel.fromJson(apiData);

//         // Initialize text controllers
//         for (var question in modeldata.data!) {
//           if (question.typeOfAns == "input") {
//             textControllers[question.id!] = TextEditingController();
//           }
//         }

//         setState(() {
//           isLoading = false;
//           chatMessages.removeLast();
//           showNextQuestion();
//         });

//         log("Questions loaded successfully. Total: ${modeldata.data?.length}");
//       } else {
//         log("Failed to load questions. Status: ${response.statusCode}");
//         setState(() {
//           chatMessages.add(
//             ChatMessage(
//               text: "Failed to load questions. Please try again.",
//               isMe: false,
//               isSystem: true,
//             ),
//           );
//         });
//       }
//     } catch (e) {
//       log("Error loading questions: ${e.toString()}");
//       setState(() {
//         chatMessages.add(
//           ChatMessage(
//             text: "An error occurred. Please try again.",
//             isMe: false,
//             isSystem: true,
//           ),
//         );
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   void showNextQuestion() {
//     if (currentQuestionIndex < modeldata.data!.length) {
//       final question = modeldata.data![currentQuestionIndex];
//       setState(() {
//         chatMessages.add(
//           ChatMessage(
//             text: "${question.id}. ${question.question!}",
//             isMe: false,
//             questionData: question,
//           ),
//         );
//         _scrollToBottom();
//       });
//     } else {
//       // All questions completed
//       setState(() {
//         chatMessages.add(
//           ChatMessage(
//             text: "You've completed all questions!",
//             isMe: false,
//             isSystem: true,
//           ),
//         );
//         _scrollToBottom();
//       });
//       // Show thank you dialog
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         showDialog(
//           context: context,
//           builder:
//               (context) => AlertDialog(
//                 title: Text("Thank You!"),
//                 content: Text("Thank you for submitting all answers."),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: Text("OK"),
//                   ),
//                 ],
//               ),
//         );
//       });
//     }
//   }

//   Future<void> submitAnswer(dynamic answer, Data question) async {
//     // Get the answer text to display in chat
//     String answerText = "";
//     if (question.typeOfAns == "input") {
//       answerText = answer;
//     } else {
//       // For radio/checkbox, find the selected option text
//       final selectedOption = question.options?.firstWhere(
//         (opt) => opt.id == answer,
//         orElse: () => Options(option: "Selected option"),
//       );
//       answerText = selectedOption?.option ?? "Selected option";
//     }

//     setState(() {
//       isSubmitting = true;
//       // Add user's answer to chat
//       chatMessages.add(
//         ChatMessage(text: answerText, isMe: true, answerData: answer),
//       );
//       _scrollToBottom();
//     });

//     try {
//       // Prepare answer data based on question type
//       Map<String, dynamic> answerData = {"question_id": question.id.toString()};

//       if (question.typeOfAns == "input") {
//         answerData["custom_answer"] = answer;
//       } else {
//         answerData["answer_id"] = answer.toString();
//       }

//       log("Submitting answer: $answerData");

//       final response = await http.post(
//         Uri.parse(postApiUrl),
//         headers: {'x-api-key': headervalue, 'Content-Type': 'application/json'},
//         body: jsonEncode(answerData),
//       );

//       if (response.statusCode == 200) {
//         log("Answer submitted successfully: ${response.body}");
//         setState(() {
//           // Store answer differently based on question type
//           if (question.typeOfAns == "checkbox") {
//             selectedAnswers[question.id!] ??= [];
//             if (selectedAnswers[question.id!].contains(answer)) {
//               selectedAnswers[question.id!].remove(answer);
//             } else {
//               selectedAnswers[question.id!].add(answer);
//             }
//           } else {
//             selectedAnswers[question.id!] = answer;
//           }
//           currentQuestionIndex++;
//           showNextQuestion();
//         });
//       } else {
//         log("Failed to submit answer. Status: ${response.statusCode}");
//         setState(() {
//           chatMessages.add(
//             ChatMessage(
//               text: "Failed to save answer. Please try again.",
//               isMe: false,
//               isSystem: true,
//             ),
//           );
//           _scrollToBottom();
//         });
//       }
//     } catch (e) {
//       log("Error submitting answer: ${e.toString()}");
//       setState(() {
//         chatMessages.add(
//           ChatMessage(
//             text: "An error occurred. Please try again.",
//             isMe: false,
//             isSystem: true,
//           ),
//         );
//         _scrollToBottom();
//       });
//     } finally {
//       setState(() {
//         isSubmitting = false;
//       });
//     }
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (scrollController.hasClients) {
//         scrollController.animateTo(
//           scrollController.position.maxScrollExtent,
//           duration: Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Question Answer Chat")),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: scrollController,
//               padding: EdgeInsets.all(8),
//               itemCount: chatMessages.length,
//               itemBuilder: (context, index) {
//                 final message = chatMessages[index];

//                 if (message.isSystem) {
//                   return Center(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(vertical: 8),
//                       child: Text(
//                         message.text,
//                         style: TextStyle(
//                           color: Colors.grey,
//                           fontStyle: FontStyle.italic,
//                         ),
//                       ),
//                     ),
//                   );
//                 }

//                 return Align(
//                   alignment:
//                       message.isMe
//                           ? Alignment.centerRight
//                           : Alignment.centerLeft,
//                   child: Container(
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.8,
//                     ),
//                     margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: message.isMe ? Colors.blueAccent : Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(12),
//                         topRight: Radius.circular(12),
//                         bottomLeft:
//                             message.isMe
//                                 ? Radius.circular(0)
//                                 : Radius.circular(12),
//                         bottomRight:
//                             message.isMe
//                                 ? Radius.circular(12)
//                                 : Radius.circular(0),
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           message.text,
//                           style: TextStyle(
//                             color: message.isMe ? Colors.white : Colors.black,
//                           ),
//                         ),
//                         if (message.questionData != null && !message.isMe)
//                           _buildQuestionOptions(message.questionData!),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           if (isSubmitting)
//             Padding(
//               padding: EdgeInsets.all(8),
//               child: CircularProgressIndicator(),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuestionOptions(Data question) {
//     if (question.typeOfAns == "radio") {
//       return Column(
//         children:
//             question.options!
//                 .map(
//                   (option) => ListTile(
//                     title: Text(option.option!),
//                     leading: Radio(
//                       activeColor: Colors.blueAccent,
//                       value: option.id,
//                       groupValue:
//                           selectedAnswers[question.id] is List
//                               ? null
//                               : selectedAnswers[question.id],
//                       onChanged: (value) => submitAnswer(value, question),
//                     ),
//                   ),
//                 )
//                 .toList(),
//       );
//     } else if (question.typeOfAns == "checkbox") {
//       return Column(
//         children:
//             question.options!
//                 .map(
//                   (option) => CheckboxListTile(
//                     activeColor: Colors.blueAccent,
//                     title: Text(option.option!),
//                     value:
//                         selectedAnswers[question.id] is List
//                             ? (selectedAnswers[question.id] ?? []).contains(
//                               option.id,
//                             )
//                             : false,
//                     onChanged: (value) => submitAnswer(option.id, question),
//                   ),
//                 )
//                 .toList(),
//       );
//     } else if (question.typeOfAns == "input") {
//       return Padding(
//         padding: EdgeInsets.only(top: 8),
//         child: Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: textControllers[question.id],
//                 decoration: InputDecoration(
//                   hintText: "Type your answer...",
//                   border: OutlineInputBorder(),
//                   contentPadding: EdgeInsets.symmetric(horizontal: 8),
//                 ),
//               ),
//             ),
//             IconButton(
//               icon: CircleAvatar(
//                 backgroundColor: Colors.blueAccent,
//                 child: Icon(Icons.send, color: Colors.white),
//               ),
//               onPressed: () {
//                 final answer = textControllers[question.id]?.text;
//                 if (answer != null && answer.isNotEmpty) {
//                   submitAnswer(answer, question);
//                   textControllers[question.id]?.clear();
//                 }
//               },
//             ),
//           ],
//         ),
//       );
//     }
//     return SizedBox();
//   }
// }

// class ChatMessage {
//   final String text;
//   final bool isMe;
//   final bool isSystem;
//   final Data? questionData;
//   final dynamic answerData;

//   ChatMessage({
//     required this.text,
//     this.isMe = false,
//     this.isSystem = false,
//     this.questionData,
//     this.answerData,
//   });
// }
