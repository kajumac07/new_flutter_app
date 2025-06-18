class QuestionAnswerModel {
  int? status;
  List<Data>? data;

  QuestionAnswerModel({this.status, this.data});

  QuestionAnswerModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  int? id;
  String? question;
  String? typeOfAns;
  Null? redirectUrl;
  int? status;
  List<Options>? options;

  Data({
    this.id,
    this.question,
    this.typeOfAns,
    this.redirectUrl,
    this.status,
    this.options,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    question = json['question'];
    typeOfAns = json['type_of_ans'];
    redirectUrl = json['redirect_url'];
    status = json['status'];
    if (json['options'] != null) {
      options = <Options>[];
      json['options'].forEach((v) {
        options!.add(Options.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = this.id;
    data['question'] = this.question;
    data['type_of_ans'] = this.typeOfAns;
    data['redirect_url'] = this.redirectUrl;
    data['status'] = this.status;
    if (this.options != null) {
      data['options'] = this.options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Options {
  int? id;
  int? questionId;
  String? option;
  Null? redirectUrl;
  String? nextQuestionId;
  int? status;

  Options({
    this.id,
    this.questionId,
    this.option,
    this.redirectUrl,
    this.nextQuestionId,
    this.status,
  });

  Options.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    questionId = json['question_id'];
    option = json['option'];
    redirectUrl = json['redirect_url'];
    nextQuestionId = json['next_question_id'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['question_id'] = this.questionId;
    data['option'] = this.option;
    data['redirect_url'] = this.redirectUrl;
    data['next_question_id'] = this.nextQuestionId;
    data['status'] = this.status;
    return data;
  }
}
