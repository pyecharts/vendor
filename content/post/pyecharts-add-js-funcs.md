---
title: "pyecharts 彩蛋函数 -- add_js_funcs"
date: 2020-04-13T12:58:05+08:00
author: sunhailin-Leo
---

## 简介

* 这次主要讲一个内置的函数 -- add_js_funcs
* 这个函数的作用顾名思义就是添加一个自定义的 javascript 函数

## Demo

* 下面通过一个简单的例子给大家展示一下
* 话不多说直接上 Demo Code：

```bash
from pyecharts import options as opts
from pyecharts.charts import Bar
from pyecharts.commons.utils import JsCode
from pyecharts.faker import Faker

c = (
    Bar(
        init_opts=opts.InitOpts(
            bg_color={"type": "pattern", "image": JsCode("img"), "repeat": "no-repeat"},
        )
    )
    .add_xaxis(Faker.choose())
    .add_yaxis("商家A", Faker.values())
    .add_yaxis("商家B", Faker.values())
    .set_global_opts(
        title_opts=opts.TitleOpts(
            title="Bar-背景图基本示例",
            subtitle="我是副标题",
            title_textstyle_opts=opts.TextStyleOpts(color="white"),
        )
    )
)
c.add_js_funcs(
    """
    var img = new Image(); img.src = 'https://s1.ax1x.com/2020/04/02/GJ1ggS.jpg';
    """
)
c.render()
```

## 效果
<figure>
    <img src="https://pic4.zhimg.com/80/v2-00cadd718fb9bdc142e88a02581788bf_1440w.jpg" width="800"/>
  <figcaption><center>图1</center></figcaption>
</figure>

## 讲解
* 这张图之所以能够放到我们画的背后主要有以下几个点：
    * 1、`InitOpts` 中 `bg_Color` 的字典（核心是：`JsCode("img")`）
    * 2、代码中的 `add_js_funcs` 代码块（下面这段代码的作用就是实例化一个 `Image` 的对象赋值给 img 变量，然后给它的 `src` 属性赋值为图片的 URL 链接）
    * 3、最后回到只要把这个变量放到第一点所提到的 `JsCode` 中即可
    ```javascript
    var img = new Image(); img.src = 'https://s1.ax1x.com/2020/04/02/GJ1ggS.jpg';
    ```

## 分析（Part 1）
* `pyecharts` 和 `JavaScript` 的代码不难理解，现在来看看究竟这段 `JavaScript` 代码是如何有效的。（下面为 `pyecharts` 生成的 `html` 文件中的部分代码）

<figure>
    <img src="https://pic1.zhimg.com/80/v2-6922ff826bfc250793dc332e984d9a14_1440w.jpg" width="800"/>
  <figcaption><center>图2</center></figcaption>
</figure>

* 第一个红框是不是很眼熟呢？Bingo！就是我们在 `add_js_funcs` 中写的 `JavaScript`代码了。
* 第二个红框就是 `pyecharts` 中的 `bg_color`，对应 `Echarts` 就是 `backgroundColor` 这个属性

## 分析（Part 2）
* 那段的 `JavaScript` 究竟是怎么填到那个位置的呢？先来了解一下 pyecharts 的渲染方式.
* 简单来说 `pyecharts` 的原理实际上是通过 `Jinja2` 模版引擎将所有的 html 代码块生成出来。
* 代码中通过高度抽象的画图类封装成最终 `Echarts` 需要的 `json` 配置，最后在通过 `RenderEngine` 这个类进行渲染。（默认调用的是最普通的 `render` 方法，即生成一个普通但不平凡的 `html` 文件）


## 分析（Part 3）
* 回到正题，既然了解了大致的渲染逻辑和流程，那么最关键的就是模版了。
* 在普通模式下 `RenderEngine` 最先找到的就是 `simple_chart.html` 这个模版。
* 在当前模版下会发现需要引入 `macro` 这个文件，此时 `Jinja2` 就会去调用 `macro` 中的 `render_chart_content` 这个方法。


<figure>
    <img src="https://pic4.zhimg.com/80/v2-5b378d2c74daf86aabb159089dbec67f_1440w.jpg" width="800"/>
  <figcaption><center>图3</center></figcaption>
</figure>


<figure>
    <img src="https://pic2.zhimg.com/80/v2-2685bb7d2a24a2a0161ee50e6a94cd39_1440w.jpg" width="800" />
  <figcaption><center>图4</center></figcaption>
</figure>

* 图四箭头中指向的红框就是核心部分了，所有通过 `add_js_funcs` 添加的代码块都会通过内部变量 `js_functions` 渲染到画图的配置之前。
* 至此，除了 `pyecharts` 代码部分的逻辑没有展示以外，大致的流程已经阐述完毕，相信各位看官已经有所了解～


## 分析（Last Part）
* `Bar` 继承自 `RectChart`，`RectChart` 继承自 `Chart`，`Chart` 继承自 `Base`，`Base` 有一个 `Mixin` 类 `ChartMixin`。
* `add_js_funcs` 就隐藏在 `ChartMixin` 中，对应的变量即 `self.js_functions`

<figure>
    <img src="https://pic4.zhimg.com/80/v2-d4d89f725b90eaad98b55e4f1f59bd47_1440w.jpg" width="800" />
  <figcaption><center>图5</center></figcaption>
</figure>

* 最终在 `class Base` 中调用的 `render` 函数就会进行 Part 3 中的渲染逻辑，渲染出最终呈现的 `html` 了。

## 总结
* 其实 `pyecharts` 的源码并没有想象中的难，只是通过高度抽象之后变得有点绕，但经过抽丝剥茧后就会发现其实也就那么一回事。Easy to coding，easy to drawing.
* 最后，希望这个专栏也不要沉下去，我尽量保持每周都写一篇文章发到这个专栏上。同时，也希望各位读者或者开发者可以分享一下自己的使用经历或者使用的 Demo。
* 最后的最后，希望各位数据开发者在读源码的过程中能够多一步，深一度。👀
