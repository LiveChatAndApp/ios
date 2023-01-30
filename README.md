# 延伸的 野火IM解决方案

有興趣可以到 野火團隊 去 下載 代碼  https://github.com/wildfirechat

這邊是 用於學習方面 野火沒有給的 admin 管理介面和 ui 對於 程序員 教學 或是 學習 使用

此版本已經驗證 


| [GitHub仓库地址](https://github.com/LiveChatAndApp)       | 说明                                                                                      
| ------------------------------------------------------------  | --------------------------------------------------------------------------
| [im-server](https://github.com/LiveChatAndApp/im-server)          | 野火社区版IM服务，野火IM的核心服务，处理所有IM相关业务。  |
| [app_server](https://github.com/LiveChatAndApp/app_server)       | Demo应用服务，模拟客户的应用服登陆处理逻辑及部分二次开发示例。 |
| [admin-ui](https://github.com/LiveChatAndApp/admin-ui)       | Demo应用服务，基於vue admin element 的 admin 管理介面。 |
| [admin-api](https://github.com/LiveChatAndApp/im-admin)       | Demo应用服务，admin 後台 api 開發。 |
| [android-chat](https://github.com/LiveChatAndApp/Android) | 野火IM Android SDK源码和App源码。 |
| [ios-chat](https://github.com/LiveChatAndApp/ios)             | 野火IM iOS SDK源码和App源码。|


## 说明
本工程为野火IM iOS App。开发过程中，充分考虑了二次开发和集成需求，可作为SDK集成到其他应用中，或者直接进行二次开发。

开发一套IM系统真的很艰辛，请路过的朋友们给点个star，支持我们坚持下去🙏🙏🙏🙏🙏

### 联系我们


1. 邮箱: kchaintw@gmail.com 

### 工程说明

工程中有3个项目，其中1个是应用，另外两个2个是库。chatclient库是IM的通讯能力，是最底层的库，chatuikit是IM的UI控件库，依赖于chatclient。chat是IM的demo，依赖于这两个库，chat需要正确配置服务器地址。

### 配置

在项目的Config.m文件中，修改IM服务器地址配置。把```IM_SERVER_HOST```和```IM_SERVER_PORT```设置成火信的地址和端口。另外需要搭配应用服务器，请按照说明部署好[应用服务器](https://github.com/wildfirechat/app_server)，然后把```APP_SERVER_HOST```和```APP_SERVER_PORT```设置为应用服务器的地址和端口。

### 登陆
使用手机号码及验证码登陆，
> 在没有短信供应商时，可以使用[superCode](https://github.com/wildfirechat/app_server#短信资源)进行测试验证。

### 集成
在集成到其他应用中时，如果使用了UIKit库，需要在应用的```Info.plist```文件中添加属性```CFBundleAllowMixedLocalizations```值为true。项目下的脚本[release_libs.sh](./release_libs.sh)可以把chatclient和chatuikit打包成动态库，把生成的库和资源添加到工程依赖中，注意库是动态库，需要"Embed"。此外还可以把chatclient和chatuikit项目直接添加到工程依赖中。

### 第三方动态库
1. [SDWebImage](https://github.com/SDWebImage/SDWebImage)
2. [ZLPhotoBrowser](https://github.com/longitachi/ZLPhotoBrowser)
> UI层使用了它们的动态库，如果需要源码可以去对应地址下载，可以自己编译替换第三方动态库。

### 鸣谢
本工程使用了[mars](https://github.com/tencent/mars)及其它大量优秀的开源项目，对他们的贡献表示感谢。本工程使用的Icon全部来源于[icons8](https://icons8.com)，对他们表示感谢。Gif动态图来源于网络，对网友的制作表示感谢。如果有什么地方侵犯了您的权益，请联系我们删除🙏🙏🙏


### License
1. Under the Creative Commons Attribution-NoDerivs 3.0 Unported license. See the [LICENSE](https://github.com/wildfirechat/ios-chat/blob/master/LICENSE) file for details.
2. Under the 996ICU License. See the [LICENSE](https://github.com/996icu/996.ICU/blob/master/LICENSE) file for details.
