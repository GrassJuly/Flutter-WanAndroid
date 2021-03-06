import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter_wanandroid/api/Api.dart';
import 'package:flutter_wanandroid/model/article.dart';
import 'package:flutter_wanandroid/model/banner.dart';
import 'package:flutter_wanandroid/model/cat.dart';
import 'package:flutter_wanandroid/model/navi_bean.dart';
import 'package:flutter_wanandroid/model/project_model.dart';
import 'package:flutter_wanandroid/model/user.dart';
import 'package:flutter_wanandroid/model/user_model.dart';
import 'package:flutter_wanandroid/api/dio_manager.dart';

class CommonService{

  Options _getOptions() {
    Map<String,String> map = new Map();
    List<String> cookies = User().cookie;
    print("网络请求携带 cookie:"+cookies.toString());
    map["Cookie"] = cookies.toString();
    map["responseType"] = "ResponseType.json";
    return Options(headers: map);
  }

  /// 获取首页 banner 数据
  void getBanner(Function callback) async {
    DioManager.singleton.dio.get(Api.HOME_BANNER, options: _getOptions()).then((response) {
      callback(BannerModel(response.data));
    });
  }

  /// 获取首页文章列表
  void getArticleList(Function callback,int _page) async {
    print("url: "+Api.HOME_ARTICLE_LIST+"$_page/json");
    DioManager.singleton.dio.get(Api.HOME_ARTICLE_LIST+"$_page/json", options: _getOptions()).then((response) {
      callback(ArticleModel(response.data));
    });
  }

  /// 获取知识体系列表
  void getSystemTree(Function callback) async {
    DioManager.singleton.dio.get(Api.SYSTEM_TREE, options: _getOptions()).then((response) {
      print("返回的体系列表 response.data："+response.data.toString());
      callback(CatModel(response.data));
    });
  }
  /// 获取知识体系列表详情
  void getSystemTreeContent(Function callback,int _page,int _id) async {
      print("url："+Api.SYSTEM_TREE_CONTENT+"$_page/json?cid=$_id");
    DioManager.singleton.dio.get(Api.SYSTEM_TREE_CONTENT+"$_page/json?cid=$_id", options: _getOptions()).then((response) {
      callback(ArticleModel(response.data));
    });
  }
  /// 获取导航列表数据
  void getNaviList(Function callback) async {
    DioManager.singleton.dio.get(Api.NAVI_LIST, options: _getOptions()).then((response) {
      print("获取导航列表数据 ："+response.toString());
      callback(NaviBeanModel(response.toString()));
    });
  }
  /// 获取项目分类
  void getProjectTree(Function callback) async {
    DioManager.singleton.dio.get(Api.PROJECT_TREE, options: _getOptions()).then((response) {
      print("获取项目分类 response.data："+response.data.toString());
      callback(CatModel(response.data));
    });
  }
  /// 获取项目列表
  void getProjectList(Function callback,int _page,int _id) async {
    DioManager.singleton.dio.get(Api.PROJECT_LIST+"$_page/json?cid=$_id", options: _getOptions()).then((response) {
      print("数据："+response.toString());
      callback(ProjectModel.fromJson(json.decode(response.toString())));
    });
  }

  /// 获取搜索列表
  void getSearchList(Function callback, String k, int _page) async {
    DioManager.singleton.dio.post(Api.SEARCH_LIST+"$_page/json?k=$k", options:_getOptions()).then((response){
      print("搜索数据："+response.toString());
      callback(ArticleModel(response.data));
    });
  }

  /// splash 图片接口
  void splash(Function callback) async {
    DioManager.singleton.dio.get("https://cn.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=zh-CN").then((response){
      final data = response.toString();
      final responseJson = json.decode(data);
      Map<String, dynamic> imageJson = responseJson ;
      final imageUrl = imageJson['images'][0]['url'];
      callback(imageUrl);
    });
  }

  /// 登录接口
  void login(Function callback, String username, String password) async {
    DioManager.singleton.dio.post(Api.LOGIN+"?username=$username&password=$password", options:_getOptions()).then((response){
      print("登录结果："+response.toString());
      callback(UserModel(response.data),response);
    });
  }

  /// 注册接口
  void register(Function callback, String username, String password,String repassword) async {
    DioManager.singleton.dio.post(Api.REGISTER+"?username=$username&password=$password&repassword=$repassword", options:_getOptions()).then((response){
      print("注册结果："+response.toString());
      callback(UserModel(response.data));
    });
  }

  /// 退出接口
  void logout(Function callback) async {
    DioManager.singleton.dio.get(Api.LOGOUT, options:_getOptions()).then((response){
      print("退出结果："+response.toString());
      callback(UserModel(response.data));
    });
  }

  /// 我的收藏接口
  void getMyCollectList(Function callback,int page) async {
    DioManager.singleton.dio.get(Api.MY_COLLECT+"/$page/json", options:_getOptions()).then((response){
      print("我的收藏："+response.toString());
      callback(ArticleModel(response.data));
    });
  }
}