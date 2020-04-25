---
title: "pyecharts 之 JsCode 的妙用"
date: 2020-04-20T01:00:00+08:00
author: sunhailin-Leo
---

## 题外话

* 这周又双叒拖更了
* Emm, 接下来到 4 月底的时间会变得异常地紧凑，因此各种 issue，和群聊的问题只能见缝插针的回复了；
* 新版本的 `pyecharts` 又得等一段时间了，目前涉及到一些 Feature 的排期和是否采纳的纠结当中。
* 当然还有就是将来在 2.X 中的最大变化（`ChartItem`），为了规范各种类型的数据参数，强制使用对象进行数据传递（可能会涉及到一些性能的问题，毕竟解析的是一堆对象，而不是单纯的数据）。
* 话不多说，进入正题 --- `JsCode` 的使用

## 什么是 `JsCode`

* `JsCode` 对于 `pyecharts` 其实并没有任何意义，因为无论怎么写都不会影响 pyecharts 的渲染, 它只是一段字符串包含着 `Javascript` 的代码, 在渲染到 `html` 的时候变成 `html` 可识别的 `js 匿名函数`。
* Q: 那么 `JsCode` 的到底是什么？
* A: `JsCode` 简单来说就是一段 `Javascript` 的代码，其作用是为对应能够使用 `JsCode` 的参数在 `Echarts` 渲染是提供的回调函数。
* Q: 什么是回调函数？
* A: 简单来说就是定义一个函数 A 为回调函数，现有一个函数 B 的参数 C 可以传入一个函数作为参数，并在函数 B 内确定了这个参数 C 的执行时机。
* Q：什么是 `Javascript` 匿名函数
* A：在 `Javascript` 中，匿名函数顾名思义就是一个没有函数名的函数，不能被外部调用，只能通过自执行调用，或者在匿名函数后面加上参数列表变为普通函数调用方式。对于 `pyecharts` 的 `JsCode` 来说，需要遵循 `Javascript` 的语法进行匿名函数（回调函数）的编写。

## `JsCode` in `pyecharts`

* 最关键的的用法模块到了，由于 `Echarts` 的文档对于回调函数的参数描述比较模糊，加上用 `pyecharts` 的同学又未必都了解 `Javascript` 的语法, 因此这篇教程的操作会比较重要；当然实操也是必须的。不自己去实操一遍，是没有任何意义的。
* 在 `pyecharts` 中，源码层面大量使用 `type hints`（类型提示），因此使用 `Pycharm` 的同学可以很轻易的查看函数参数对应的类型；在 pyecharts 里面通过一个自定义的类型对于该类型参数进行提示：`JSFunc = Union[str, JsCode]`; 这其中的 `JsCode` 也可以单独作为类型提示的类型进行 `type hints` 的操作。
* 在 `pyecharts` 中 `JSCode` 实际上就是一段字符串，通过前后的特殊符号，在渲染的过程中进行替换。

![image](https://pic4.zhimg.com/80/v2-3cc4cdc0c9b2bc3bab31059a0a0455e6_1440w.png)

## 怎么用 `JsCode`

* 对于 `pyecharts` 来说，任何一个支持使用的 `JsFunc` 或者 `JsCode` 的参数都可以编写回调函数的代码。
* 接下来用几个例子进行讲解：

#### 例子 -- 让 `Bar` 图 `stack` 模式支持展示百分比

* 代码:

{{< highlight python >}}
from pyecharts import options as opts
from pyecharts.charts import Bar
from pyecharts.commons.utils import JsCode
from pyecharts.globals import ThemeType

list2 = [
    {"value": 12, "percent": 12 / (12 + 3)},
    {"value": 23, "percent": 23 / (23 + 21)},
    {"value": 33, "percent": 33 / (33 + 5)},
    {"value": 3, "percent": 3 / (3 + 52)},
    {"value": 33, "percent": 33 / (33 + 43)},
]

list3 = [
    {"value": 3, "percent": 3 / (12 + 3)},
    {"value": 21, "percent": 21 / (23 + 21)},
    {"value": 5, "percent": 5 / (33 + 5)},
    {"value": 52, "percent": 52 / (3 + 52)},
    {"value": 43, "percent": 43 / (33 + 43)},
]

c = (
    Bar(init_opts=opts.InitOpts(theme=ThemeType.LIGHT))
    .add_xaxis([1, 2, 3, 4, 5])
    .add_yaxis("product1", list2, stack="stack1", category_gap="50%")
    .add_yaxis("product2", list3, stack="stack1", category_gap="50%")
    .set_series_opts(
        label_opts=opts.LabelOpts(
            position="right",
            formatter=JsCode(
                "function(x){return Number(x.data.percent * 100).toFixed() + '%';}"
            ),
        )
    )
    .render("stack_bar_percent.html")
)
{{< /highlight >}}

* 效果:

![image](https://pic4.zhimg.com/80/v2-115efa7d4257da8495483a70bdae8c60_1440w.png)

* 讲解:
    * 1、通过封装自定义字段 `value` 和 `percent`到数据 `list2` 和 `list3` 中, 由于 `percent` 这个字段不属于 `Echarts Bar` 图的 `data` 参数的下的任何一个字段，因此 `percent` 字段会被保留下来
    * 2、此时在考虑数值是由 `LabelOpts` 进行渲染的，而 `LabelOpts` 目前是没有百分比的展示进行配置的, 其中 `formatter` 就是为了让用户自定义 `Label` 的展示结果，且 `formatter` 参数支持使用 `JsCode`，这时候我们就可以让 `JsCode` 派上用场了!
    * 3、到这一步，许多同学就会问，我们应该怎么写呢？不着急，往下看!
    * 4、对于任何一个 JsCode 我们都可以先写下这样一个万能的回调函数。
    {{< highlight javascript >}}
    function (x) { console.log(x); return x; }
    {{< /highlight >}}
    * 5、上面这个万能的回调函数，即不影响原本的结果渲染，又能通过 `Javascript` 的语法输出 `x` 的对象信息。
    * 6、接下来来看看使用了万能回调函数之后，浏览器控制台的显示的信息有什么（需要把上面代码的 `JsCode` 参数换成这个万能回调函数即可）
    
    ![image](https://pic1.zhimg.com/80/v2-4f9a27603be7bca59cd23971808922b3_1440w.png)
    
    * 7、根据上图可以看到我们的在数据中设置的 `value` 和 `percent` 都被保留了下来，因此我们只需要让我们的匿名函数把 `return` 的结果访问到 `percent` 处即可。在 `Javascript` 中，Object 对象的属性都可以通过 `.` 操作符进行方法, 因此访问我们设置的 `percent` 字段的 `js` 就可以写成 `x.data.percent` 了；此时，我们得到的结果是我们预设 `percent` 的值 0.8 （直接传入 字符串 80% 也是可以的），因此我们需要转化一下。
    * 8、将小数转化为百分比数据，首先需要 ` * 100 `,
    然后通过精度保留函数取整。最后关键的函数变成了 `Number(x.data.percent * 100).toFixed()`; `toFixed()` 函数默认为 0，最大位数为 20 位；最后再拼上百分号即可。
    
## `JsCode` 小结

* 关于 `JsCode` 怎么在代码引入：`from pyecharts.commons.utils import JsCode`
* 任何参数的 `JsCode` 在不知道怎么使用的情况下，均可以使用万能回调函数和浏览器控制台去查看。
    * 万能回调函数: `JsCode("funtion(x) {console.log(x); return x;}")`
    * 浏览器控制台：F12 --> 选择 Console / 控制台选项卡（再找不到的，自行百度；此处不做过多教程）
* 不是任何回调函数都只有一个参数的，部分回调函数在测试过程中可以写成：`JsCode("function(params, item) { console.log(params, item); return params;}")`

## 总结

* `JsCode` 作为 `pyecharts` 的其中一个中高阶的用法，对于各位使用者来说需要掌握多一门语言的部分语法，因此对于使用者的门槛要求相对较高；通过上述的例子，能够清晰的得出如何去调试并编写一个回调函数 `JsCode` 的流程。
* 万能回调函数：
    * 单参数：`JsCode("funtion(x) {console.log(x); return x;}")`
    * 双参数：`JsCode("function(params, item) { console.log(params, item); return params;}")`
* `JsCode` 难度并不大，当使用者了解 `Javascript` 后，通过一段时间的使用之后就可以很容易的上手了 `JsCode` 了。
