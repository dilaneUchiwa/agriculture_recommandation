import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:agriculture_recommandation/controllers/homeController.dart';
import 'package:agriculture_recommandation/themes/theme.dart';
import 'package:agriculture_recommandation/utils/appImages.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final _homeController = Get.find<Homecontroller>();

  var loggedInOptions = [
    {
      "title": "home_more_option.my_wallet".tr,
      "onClickFun": () => Get.toNamed('/wallet_account'),
      "image": "assets/drawerLoggedIn/my_wallet.png"
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(children: [
      Container(
          height: 200,
          width: double.infinity,
          color: Theme.of(context).primaryColor,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SafeArea(
              child: Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                  ), // top: 10.h
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(.7),
                                        width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 5,
                                        blurRadius: 10,
                                      ),
                                    ]),
                                child: Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  width: 54,
                                  height: 54,
                                  child: FutureBuilder(
                                      future: null,
                                      builder: (context,
                                          AsyncSnapshot<Map<String, String>>
                                              snapshot) {
                                        if (!snapshot.hasData) {
                                          return Image.asset(AppImages.avatar);
                                        }
                                        return false
                                            ? Image(
                                                image: NetworkImage("url",
                                                    headers: snapshot.data),
                                                errorBuilder:
                                                    (context, error, trace) =>
                                                        Image.asset(
                                                            AppImages.avatar),
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Image.asset(
                                                      AppImages.avatar);
                                                },
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(AppImages.avatar);
                                      }),
                                )),
                            SizedBox(
                              width: 54,
                              height: 54,
                              child: Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Scaffold.of(context).closeDrawer();
                                  },
                                  child: const Icon(
                                    Icons.clear,
                                    size: 25,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ]),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: SizedBox(
                          height: 30,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "---",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'phone: @username',
                                style: Themes.smallTextStyle.merge(
                                    const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400)),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  GetStorage().read('lastLoginTime') != null
                                      ? "${'input.home.screen.last_login'.tr} : "
                                      : '---',
                                  style: Themes.smallTextStyle.merge(TextStyle(
                                      color: AppColors.lightGreyColor1,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14)),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  GetStorage().read('lastLoginTime') != null
                                      ? "${GetStorage().read('lastLoginTime')}"
                                      : '',
                                  style: Themes.smallTextStyle.merge(TextStyle(
                                      color: AppColors.lightGreyColor1,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  _homeController.logoutUser('logout'.tr);
                                });
                                Get.back();
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 0),
                                child: Row(
                                  children: [
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: Icon(Icons.logout,
                                            size: 15,
                                            color: AppColors.primary)),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'logout'.tr,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
            ),
          )),
      Expanded(
        child: list(),
      ),
    ]));
  }

  Widget list() {
    return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: loggedInOptions.length,
        itemBuilder: (context, index) => MaterialButton(
              onPressed: loggedInOptions[index]['onClickFun'] as VoidCallback,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minWidth: 0,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(color: Colors.blue[100]!, width: 0.5))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Card(
                        elevation: 4.0,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Padding(
                            padding: const EdgeInsets.all(5.5),
                            child: Image(
                              image: AssetImage(
                                  loggedInOptions[index]['image']!.toString()),
                              color: AppColors.primary,
                            ))),
                    SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        loggedInOptions[index]['title']!.toString(),
                        style: TextStyle(
                          color: AppColors.navTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ));
  }
}
