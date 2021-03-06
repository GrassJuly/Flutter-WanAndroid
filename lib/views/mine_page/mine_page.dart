import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bugly/flutter_bugly.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_wanandroid/api/common_service.dart';
import 'package:flutter_wanandroid/model/store.dart';
import 'package:flutter_wanandroid/model/theme.dart';
import 'package:flutter_wanandroid/model/user.dart';
import 'package:flutter_wanandroid/model/user_model.dart';
import 'package:flutter_wanandroid/routers/application.dart';
import 'package:flutter_wanandroid/routers/router_path.dart';
import 'package:flutter_wanandroid/utils/shared_preferences.dart';
import 'package:flutter_wanandroid/utils/toast.dart';
import 'package:flutter_wanandroid/utils/update_dialog.dart';
import 'package:flutter_wanandroid/widgets/list_item.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class MinePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MinePageState();
  }
}

class MinePageState extends State<MinePage> with WidgetsBindingObserver,AutomaticKeepAliveClientMixin {

  GlobalKey<UpdateDialogState> _dialogKey = new GlobalKey();
  String _userName = "未登录";
  String _version = "";


  @override
  bool get wantKeepAlive => true;

  void _getUserName() {
    if (mounted) {
      User().getUserInfo().then((username) {
        if (username != null && username.isNotEmpty) {
          User().setLogin(true);
          setState(() {
            _userName = username;
          });
        } else {
          User().setLogin(false);
          setState(() {
            _userName = "未登录";
          });
        }
      });
    }
  }

  @override
  void initState() {
    _getUserName();
    super.initState();
    WidgetsBinding.instance.addObserver(this); //注册监听器

    _packageInfo();

  }

  void _packageInfo() async{
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    //APP名称
    String appName = packageInfo.appName;
    //包名
    String packageName = packageInfo.packageName;
    //版本名
    String  version = packageInfo.version;
    //版本号
    String buildNumber = packageInfo.buildNumber;

    _version = version +"+"+ buildNumber;
  }


  @override
  void deactivate() {
    super.deactivate();
    var bool = ModalRoute.of(context).isCurrent;
    print("页面返回：" + bool.toString());
    if (bool) {
      _getUserName();
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this); //移除监听器
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: <Widget>[
        Container(
          height: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        EasyRefresh.custom(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildListDelegate([
                // 顶部栏
                Stack(
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: 220.0,
                      color: Colors.white,
                    ),
                    ClipPath(
                      clipper: TopBarClipper(
                          MediaQuery.of(context).size.width, 200.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200.0,
                        child: Container(
                          width: double.infinity,
                          height: 240.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    // 名字
                    Container(
                      margin: EdgeInsets.only(top: 40.0),
                      child: new InkWell(
                        onTap: () {
                          User().getUserInfo().then((userName){
                            if(userName.length > 0){
                              print("显示用户信息");
                            }else{
                              Application.router.navigateTo(context, RouterPath.login);
                            }
                          });
                        },
                        child: Center(
                            child: Text(
                          _userName,
                          style: TextStyle(fontSize: 30.0, color: Colors.white),
                        )),
                      ),
                    ),
                    // 头像
                    Container(
                        margin: EdgeInsets.only(top: 100.0),
                        child: Center(
                            child: Container(
                                width: 100.0,
                                height: 100.0,
                                child: ClipOval(
                                    child: ExtendedImage.network(
                                  "https://hbimg.huabanimg.com/2955e079403940e85df439dab8baab2dea441c042e0a2-Ndy7fz_fw658",
                                  fit: BoxFit.fill,
                                ))))),
                  ],
                ),
                // 内容
                _buildItem(context, Colors.blue, Icons.favorite, "我的收藏", "",() {
                  User().getUserInfo().then((userName){
                    if(userName.length > 0){
                      Application.router.navigateTo(context, RouterPath.myCollect);
                    }else{
                      Application.router.navigateTo(context, RouterPath.login);
                    }
                  });

                }),
                _buildItem(context, Colors.deepPurpleAccent, Icons.score, "积分排行榜","", () {
                  Application.router.navigateTo(context, RouterPath.coinRank);
                }),
                _buildItem(context, Colors.deepOrange, Icons.info, "关于页面","", () {
                  Application.router.navigateTo(context, RouterPath.about);
                }),
                _buildItem(context, Colors.green, Icons.exit_to_app, "修改主题色", "",() {
                  _showChangeThemeDialog();
                }),
                _buildItem(context, Colors.orangeAccent, Icons.exit_to_app, "检测更新",_version, () {
                  _checkUpdate();
                }),
                _buildItem(context, Colors.pink, Icons.exit_to_app, "退出登录","", () {
                  _logout();
                }),
              ]),
            ),
          ],
        ),
      ],
    );
  }

  void _checkUpdate(){
    if (Platform.isAndroid) {
      FlutterBugly.checkUpgrade();
      FlutterBugly.getUpgradeInfo().then((_info) {
        FlutterBugly.getUpgradeInfo().then((UpgradeInfo info) {
          if (info != null && info.id != null) {
            showUpdateDialog(info.versionName, info.newFeature, info.apkUrl);
          }else{
            ToastUtil.showBasicToast("暂未检测到新版本");
          }
        });
      });
    }
  }

  void showUpdateDialog(String versionName, String feature, String url) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => _buildDialog(versionName,feature, url),
    );
  }

  Widget _buildDialog(String versionName, String feature, String url) {
    return new UpdateDialog(
      key:_dialogKey,
      version:versionName,
      feature:feature,
      onClickWhenDownload:(_msg) {
        //2. 提示不要重复下载
        print("---------提示不要重复下载---------${_msg}");
      },
      onClickWhenNotDownload:() {

        // 1. 直接使用浏览器下载
        _launchURL(url);
        // 2. 本地下载
        // 下载apk，完成后打开apk文件，建议使用dio+open_file插件
        print("---------下载apk，完成后打开apk文件,建议使用dio+open_file 插件---------");
      },
    );
  }

  /// 跳转应用市场升级
  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// 退出登录
  void _logout() {
    CommonService().logout((UserModel _userModel) {
      if (_userModel.errorCode == 0) {
        ToastUtil.showBasicToast("您已退出登录");

        /// 删除本地缓存
        User().clearUserInfor();
        _getUserName();
      } else if (_userModel.errorCode == -1) {
        ToastUtil.showBasicToast(_userModel.errorMsg);
      }
    });
  }

  /// 修改主题色
  void _showChangeThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('选择主题颜色'),
            content: Container(
              height: 300,
              child: ListView.builder(
                itemCount: AppTheme.materialColors.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        Store.value<AppTheme>(context).changeTheme(index);
                        Navigator.of(context).pop();
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(10.0),
                              color: AppTheme.materialColors[index],
                              height: 40),
                          Opacity(
                            opacity: index == SPUtils.getThemeColorIndex()
                                ? 1.0
                                : 0.0,
                            child: Center(
                              child: Icon(Icons.done, color: Colors.white),
                            ),
                          )
                        ],
                      ));
                },
              ),
            ));
      },
    );
  }
}

Widget _buildItem(BuildContext context, Color color, IconData icons, String title,[String version,Function callback]) {
  return Container(
    width: double.infinity,
    color: Colors.white,
    padding: EdgeInsets.all(10.0),
    child: Card(
        color: color,
        child: Container(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              ListItem(
                icon: Icon(
                  icons,
                  color: Colors.white,
                ),
                title: title,
                titleColor: Colors.white,
                describeColor: Colors.white,
                rightWidget: versionText(version),
                onPressed: () {
                  callback();
                },
              )
            ],
          ),
        )),
  );
}

Widget versionText(version){
  return Text(version,style: TextStyle(color: Colors.white),);
}

// 顶部栏裁剪
class TopBarClipper extends CustomClipper<Path> {
  // 宽高
  double width;
  double height;

  TopBarClipper(this.width, this.height);

  /// 获取剪裁区域的接口
  /// 返回斜对角的图形 path
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0.0, 0.0);
    path.lineTo(width, 0.0);
    path.lineTo(width, height / 2);
    path.lineTo(0.0, height);
    return path;
  }

  /// 接口决定是否重新剪裁
  /// 如果在应用中，剪裁区域始终不会发生变化时应该返回 false，这样就不会触发重新剪裁，避免不必要的性能开销。
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
