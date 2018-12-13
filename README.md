# ZBSnippetTools
ZBSnippetTools


#### 1.跑起来后在工程的 Products 文件夹里看到 [ZBSnippetTools.app] 打开对应Finder
#### 2.将文件copy 到应用程序里面,run 一下
#### 3.在 [系统偏好设置] ->扩展-> [ZBSnippetTools] ->[Xcode Source Editor] 选中
#### 4.重启Xcode ,打开->Key Bindings -> 搜索 ZBAddImport 设置快捷键



### 功能1  快捷import

选中文案->快捷 添加 import  

会追加在顶部import最后一行;

```Objective-C

ZBPeopleOBject

->

#import "ZBPeopleOBject.h"

```

### 功能2  快捷Str->implementation

选中文案->快捷添加方法

放到到当前选中文案的方法之下;

如果当前选中不是方法,则在@end之上;

如果选择的line,含有EventTouchUpInside,将全局搜索,定位到其他btn事件所在的位置之上;


```
[btn addTarget:self action:NSSelectorFromString(@"btnClick") forControlEvents:UIControlEventTouchUpInside];

[btn addTarget:self action:@selector(btnClick:::) forControlEvents:UIControlEventTouchUpInside];


- (void)btnClick:(id)arg1 arg2:(id)arg2 arg3:(id)arg3
{

}

- (void)btnClick
{

}


```
### 功能3  快捷Enum->Switch


必须选中含有 "NS_ENUM" 或者 "NS_OPTIONS" 开始

以 "}" 作为结束;


```Objective-C
typedef NS_ENUM(NSInteger, ZBAAAAType) {
    ZBAAAATypePic,         //图文
    ZBAAAATypeProduct,     //商品
};
    switch (<#expression#>) {
        case ZBAAAATypePic:
            <#statements#>
            break;
        case ZBAAAATypeProduct:
            <#statements#>
            break;
        default:
            break;
    }
```