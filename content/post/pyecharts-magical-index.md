---
title: "pyecharts 之神奇的轴索引"
date: 2020-04-13T18:58:05+08:00
author: sunhailin-Leo
---

## 题外话
* 这周忙着工作上的事情，拖更了好久。本来这周打算周中发布新篇的，结果拖到周日才有空开始写。
* emm 以后尽量尽量周三、四更新 😄；
* 话不多说，进入正题哈 👀

## 简介
* 这周讲一下大家可能会比较疑惑的，比较少用，但在用的时候时候非常必要的部分参数。

## 轴索引
* 轴索引这个概念，顾名思义就是给 `pyecharts / Echarts` 的轴系图（带直角坐标系的图）赋予了索引，能够让数据映射到对应的轴上，从而实现一些高阶的直角坐标系的图。
* 在各位开发者使用 `pyecharts` 中经常会使用到 `Overlap`，`Grid` 之类的布局组件，或者在画一些多 `X / Y` 轴的图的时候会使用到。

## 进入正题
* 下面通过几个 Demo 的讲解，让各位读者更深入的去理解轴索引的使用。

## Demo 1（多 Y 轴的索引）
* Demo 1 的地址：[多 Y 轴的示例](http://gallery.pyecharts.org/#/Bar/multiple_y_axes)
* Demo 1 的代码：
{{< highlight python >}}
import pyecharts.options as opts
from pyecharts.charts import Bar, Line

colors = ["#5793f3", "#d14a61", "#675bba"]
x_data = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
legend_list = ["蒸发量", "降水量", "平均温度"]
evaporation_capacity = [
    2.0, 4.9, 7.0, 23.2, 25.6, 76.7, 135.6, 162.2, 32.6,  20.0, 6.4, 3.3,
]
rainfall_capacity = [
    2.6, 5.9, 9.0, 26.4, 28.7, 70.7, 175.6, 182.2, 48.7, 18.8, 6.0, 2.3,
]
average_temperature = [
    2.0, 2.2, 3.3, 4.5, 6.3, 10.2, 20.3, 23.4, 23.0, 16.5, 12.0, 6.2,
]

bar = (
    Bar(init_opts=opts.InitOpts(width="1680px", height="800px"))
    .add_xaxis(xaxis_data=x_data)
    .add_yaxis(
        series_name="蒸发量",
        yaxis_data=evaporation_capacity,
        yaxis_index=0,
        color=colors[1],
    )
    .add_yaxis(
        series_name="降水量", 
        yaxis_data=rainfall_capacity, 
        yaxis_index=1, 
        color=colors[0],
    )
    .extend_axis(
        yaxis=opts.AxisOpts(
            name="蒸发量",
            type_="value",
            min_=0,
            max_=250,
            position="right",
            axisline_opts=opts.AxisLineOpts(
                linestyle_opts=opts.LineStyleOpts(color=colors[1])
            ),
            axislabel_opts=opts.LabelOpts(formatter="{value} ml"),
        )
    )
    .extend_axis(
        yaxis=opts.AxisOpts(
            type_="value",
            name="温度",
            min_=0,
            max_=25,
            position="left",
            axisline_opts=opts.AxisLineOpts(
                linestyle_opts=opts.LineStyleOpts(color=colors[2])
            ),
            axislabel_opts=opts.LabelOpts(formatter="{value} °C"),
            splitline_opts=opts.SplitLineOpts(
                is_show=True, linestyle_opts=opts.LineStyleOpts(opacity=1)
            ),
        )
    )
    .set_global_opts(
        yaxis_opts=opts.AxisOpts(
            type_="value",
            name="降水量",
            min_=0,
            max_=250,
            position="right",
            offset=80,
            axisline_opts=opts.AxisLineOpts(
                linestyle_opts=opts.LineStyleOpts(color=colors[0])
            ),
            axislabel_opts=opts.LabelOpts(formatter="{value} ml"),
        ),
        tooltip_opts=opts.TooltipOpts(trigger="axis", axis_pointer_type="cross"),
    )
)

line = (
    Line()
    .add_xaxis(xaxis_data=x_data)
    .add_yaxis(
        series_name="平均温度", 
        y_axis=average_temperature, 
        yaxis_index=2, 
        color=colors[2]，
    )
)

bar.overlap(line).render("multiple_y_axes.html")
{{< /highlight >}}
<figure>
    <img src="https://pic1.zhimg.com/80/v2-acb5eb39323ef4a94584a146158100e4_1440w.jpg" width="800"/>
  <figcaption><center>图1</center></figcaption>
</figure>

## Demo 1 （多 Y 轴索引）的图例剖析
* 1、在 `pyecharts` 中，想要画出这样的图得使用 `Overlap` 组件，其次这图仅用两个基础类型的图 `Bar（柱状图）`，和 `Line （折线图）`。
* 2、柱状图的两个数据维度，蒸发量，降水量；单位都是 ml （毫升）；因此在观测上为了好看，可以将这两组维度的轴放在同侧进行观测。
* 3、折线图目前只有一个维度：平均温度；单位是摄氏度；为了区别于柱状图的轴，因此可以放在柱状图轴的另一侧进行观测。

## Demo 1 （多 Y 轴索引）的代码剖析
* **1、需要注意的是所有的轴索引的初始值都是 0。多轴的情况下，按照添加顺序进行排序。**
* 2、在上面图例剖析以及上面这点注意事项后可以得出一个画图的公式：`Bar + Line = Bar-Y-0 + Bar-Y-1 + Line-Y-2`
* Bar 图的代码中对轴的操作主要是 `add_yaxis`, `extend_axis` 以及 `set_global_opts` 中的 `AxisOpts` 配置。
{{< highlight python >}}
.add_yaxis(
    series_name="蒸发量",
    yaxis_data=evaporation_capacity,
    yaxis_index=0,
    color=colors[1],
)
{{< /highlight >}}
* 上面这行代码是添加第一个轴（蒸发量）的，因此它的轴索引是 0（默认值也是 0，因此在这段代码里面 `yaxis_index = 0` 可写可不写）
{{< highlight python >}}
.add_yaxis(
    series_name="降水量", 
    yaxis_data=rainfall_capacity, 
    yaxis_index=1, 
    color=colors[0],
)
{{< /highlight >}}
* 降水量的轴是第二个轴，因此轴索引值为 1 。
{{< highlight python >}}
.extend_axis(
   yaxis=opts.AxisOpts(
       name="蒸发量", type_="value", min_=0, max_=250,
       position="right",
       axisline_opts=opts.AxisLineOpts(
           linestyle_opts=opts.LineStyleOpts(color=colors[1])
       ),
       axislabel_opts=opts.LabelOpts(formatter="{value} ml"),
  )
)
{{< /highlight >}}
* 上面这段代码的作用是用来更加细致的配置第一个轴（蒸发量），其中 `position` 是用来配置轴的相对位置。 `axisline_opts` 是为了修改轴线的配置，`axislabel_opts` 则是用来修改轴上标签的配置。
{{< highlight python >}}
.extend_axis(
    yaxis=opts.AxisOpts(
        type_="value", name="温度", min_=0, max_=25,
        position="left",
        axisline_opts=opts.AxisLineOpts(
            linestyle_opts=opts.LineStyleOpts(color=colors[2])
        ),
        axislabel_opts=opts.LabelOpts(formatter="{value} °C"),
        splitline_opts=opts.SplitLineOpts(
            is_show=True, linestyle_opts=opts.LineStyleOpts(opacity=1)
        ),
    )
)
{{< /highlight >}}
* 上面这段代码是用来提前配置 `Line` 图中的 Y 轴，作用和上面配置蒸发量的轴的配置是几乎一样的，这里不涉及轴索引的配置，仅配置轴的样式。`splitline_opts` 的作用在于设置样例图中从左侧 Y 轴引出的刻度线。

{{< highlight python >}}
.set_global_opts(
    yaxis_opts=opts.AxisOpts(
        type_="value", name="降水量", min_=0, max_=250,
        position="right", offset=80,
        axisline_opts=opts.AxisLineOpts(
            linestyle_opts=opts.LineStyleOpts(color=colors[0])
        ),
        axislabel_opts=opts.LabelOpts(formatter="{value} ml"),
    ),
    tooltip_opts=opts.TooltipOpts(trigger="axis", axis_pointer_type="cross"),
)
{{< /highlight >}}
* 上面这段中的 `yaxis_opts` 就是用来配置降水量的轴，通过设置 `position` 与蒸发量同侧，设置 `offset` 让两个轴有间隔不会重叠。
{{< highlight python >}}
line = (
    Line()
    .add_xaxis(xaxis_data=x_data)
    .add_yaxis(
        series_name="平均温度", y_axis=average_temperature, 
        yaxis_index=2, 
        color=colors[2]，
    )
)
{{< /highlight >}}
* 上面这段代码是 `Line` 图的配置。根据我们上面提到的公式，因此 `Line` 图对应的 Y 轴索引为 2，所以在 `add_yaxis` 的 `yaxis_index` 值即为 2 。

## Demo 1 （多 Y 轴索引）总结
* 通过上面的代码段和代码说明，相信读到这里的同学应该已经对轴索引这个概念有个粗略的认识了。
* 讲完多 Y 轴之后，各位同学相信对多 X 轴的非常感兴趣。
* 其实多 Y 轴和多 X 轴的道理是相通的，这里给出 pyecharts-gallery 中的多 X 轴的示例给大家，大家按照上面的分析逻辑去分析多 X 轴的代码即可，相信大家能够理解多 X / Y 轴的图的特点，以及轴索引这个概念。

<center><a href="http://gallery.pyecharts.org/#/Line/multiple_x_axes">多 X 轴的示例</a></center>

---

## Demo 2 （Grid + Overlap + 复杂多轴示例）-- 高阶用法
* 建议将 Demo 1 吃透之后再看，否则会越看越晕的。（在画图的时候脑子里最好有图，否则经常会画不出来的 🐶）
* Demo 2 讲解的起点：**默认各位已经将 Demo 1 吃透，并理解了轴索引的概念。**
* Demo 2 的地址：[Grid + Overlap + 多 X / Y 轴示例](http://gallery.pyecharts.org/#/Grid/grid_overlap_multi_xy_axis)
* Demo 2 的代码：(代码有点长，建议用电脑访问~)
{{< highlight python >}}
from pyecharts import options as opts
from pyecharts.charts import Bar, Grid, Line

bar = (
    Bar()
    .add_xaxis(["{}月".format(i) for i in range(1, 13)])
    .add_yaxis(
        "蒸发量", [2.0, 4.9, 7.0, 23.2, 25.6, 76.7, 135.6, 162.2, 32.6, 20.0, 6.4, 3.3],
        yaxis_index=0,
        color="#d14a61",
    )
    .add_yaxis(
        "降水量", [2.6, 5.9, 9.0, 26.4, 28.7, 70.7, 175.6, 182.2, 48.7, 18.8, 6.0, 2.3],
        yaxis_index=1,
        color="#5793f3",
    )
    .extend_axis(
        yaxis=opts.AxisOpts(
            name="蒸发量", type_="value", min_=0, max_=250,
            position="right",
            axisline_opts=opts.AxisLineOpts(
                linestyle_opts=opts.LineStyleOpts(color="#d14a61")
            ),
            axislabel_opts=opts.LabelOpts(formatter="{value} ml"),
        )
    )
    .extend_axis(
        yaxis=opts.AxisOpts(
            type_="value", name="温度", min_=0, max_=25,
             osition="left",
            axisline_opts=opts.AxisLineOpts(
                linestyle_opts=opts.LineStyleOpts(color="#675bba")
            ),
            axislabel_opts=opts.LabelOpts(formatter="{value} °C"),
            splitline_opts=opts.SplitLineOpts(
                is_show=True, linestyle_opts=opts.LineStyleOpts(opacity=1)
            ),
        )
    )
    .set_global_opts(
        yaxis_opts=opts.AxisOpts(
            name="降水量", min_=0, max_=250,
            position="right",
            offset=80,
            axisline_opts=opts.AxisLineOpts(
                linestyle_opts=opts.LineStyleOpts(color="#5793f3")
            ),
            axislabel_opts=opts.LabelOpts(formatter="{value} ml"),
        ),
        title_opts=opts.TitleOpts(title="Grid-Overlap-多 X/Y 轴示例"),
        tooltip_opts=opts.TooltipOpts(trigger="axis", axis_pointer_type="cross"),
        legend_opts=opts.LegendOpts(pos_left="25%"),
    )
)

line = (
    Line()
    .add_xaxis(["{}月".format(i) for i in range(1, 13)])
    .add_yaxis(
        "平均温度", [2.0, 2.2, 3.3, 4.5, 6.3, 10.2, 20.3, 23.4, 23.0, 16.5, 12.0, 6.2],
        yaxis_index=2,
        color="#675bba",
        label_opts=opts.LabelOpts(is_show=False),
    )
)

bar1 = (
    Bar()
    .add_xaxis(["{}月".format(i) for i in range(1, 13)])
    .add_yaxis(
        "蒸发量 1", [2.0, 4.9, 7.0, 23.2, 25.6, 76.7, 135.6, 162.2, 32.6, 20.0, 6.4, 3.3],
        color="#d14a61",
        xaxis_index=1,
        yaxis_index=3,
    )
    .add_yaxis(
        "降水量 2", [2.6, 5.9, 9.0, 26.4, 28.7, 70.7, 175.6, 182.2, 48.7, 18.8, 6.0, 2.3],
        color="#5793f3",
        xaxis_index=1,
        yaxis_index=4,
    )
    .extend_axis(
        yaxis=opts.AxisOpts(
            name="蒸发量", type_="value", min_=0, max_=250,
            position="right",
            axisline_opts=opts.AxisLineOpts(
                linestyle_opts=opts.LineStyleOpts(color="#d14a61")
            ),
            axislabel_opts=opts.LabelOpts(formatter="{value} ml"),
        )
    )
    .extend_axis(
        yaxis=opts.AxisOpts(
            type_="value", name="温度", min_=0, max_=25,
            position="left",
            axisline_opts=opts.AxisLineOpts(
                linestyle_opts=opts.LineStyleOpts(color="#675bba")
            ),
            axislabel_opts=opts.LabelOpts(formatter="{value} °C"),
            splitline_opts=opts.SplitLineOpts(
                is_show=True, linestyle_opts=opts.LineStyleOpts(opacity=1)
            ),
        )
    )
    .set_global_opts(
        xaxis_opts=opts.AxisOpts(grid_index=1),
        yaxis_opts=opts.AxisOpts(
            name="降水量", min_=0, max_=250,
            position="right",
            offset=80,
            grid_index=1,
            axisline_opts=opts.AxisLineOpts(
                linestyle_opts=opts.LineStyleOpts(color="#5793f3")
            ),
            axislabel_opts=opts.LabelOpts(formatter="{value} ml"),
        ),
        tooltip_opts=opts.TooltipOpts(trigger="axis", axis_pointer_type="cross"),
        legend_opts=opts.LegendOpts(pos_left="65%"),
    )
)

line1 = (
    Line()
    .add_xaxis(["{}月".format(i) for i in range(1, 13)])
    .add_yaxis(
        "平均温度 1", [2.0, 2.2, 3.3, 4.5, 6.3, 10.2, 20.3, 23.4, 23.0, 16.5, 12.0, 6.2],
        color="#675bba",
        label_opts=opts.LabelOpts(is_show=False),
        xaxis_index=1,
        yaxis_index=5,
    )
)

overlap_1 = bar.overlap(line)
overlap_2 = bar1.overlap(line1)

grid = (
    Grid(init_opts=opts.InitOpts(width="1200px", height="800px"))
    .add(
        overlap_1, grid_opts=opts.GridOpts(pos_right="58%"), 
        is_control_axis_index=True
    )
    .add(
        overlap_2, grid_opts=opts.GridOpts(pos_left="58%"), 
        is_control_axis_index=True)
    .render("grid_overlap_multi_xy_axis.html")
)
{{< /highlight >}}

<figure>
    <img src="https://pic4.zhimg.com/80/v2-95b295a6c226e5c656b1d330ba02fb77_1440w.jpg" width="800"/>
  <figcaption><center>图2</center></figcaption>
</figure>

## Demo 2 （Grid + Overlap + 复杂多轴示例）的图例剖析：
* 眼尖的同学应该看的出这个图实际上和 Demo 1 的是一样的，仅仅是使用了 `Grid` 进行了水平布局而已。
* 虽然说起来简单，但是，这里面的轴索引与 Demo 1 就有了变化；出现了 `xaxis_index`

## Demo 2 （Grid + Overlap + 复杂多轴示例）的代码剖析：
* 1、在 Demo 1 中我们得出一个画图公式：
`Bar + Line = Bar-Y-0 + Bar-Y-1 + Line-Y-2`，在 Demo 2 中，由于我们会出现多个 X 轴，因此我们需要对 X 轴的进行合并。
* 2、根据 Demo 1 的公式，在 Demo 2 中可以推出：
`(Bar0 + Line0) + (Bar1 + Line1) = (X0 + Bar-Y-0 + Bar-Y-1 + Line-Y-2) + (X1 + Bar-Y-3 + Bar-Y-4 + Line-Y-5)`
* 3、因此我们得出 X 轴的轴索引范围是 [0, 1]，Y 轴的轴索引范围是 [0, 5]。
* 4、根据我们新推出的公式和取值范围后，我们就很容易写出两部分代码了 `Ovelap0 = Bar0 + Line0` 和 `Overlap1 = Bar1 + Line1`
* 5、现在我们来针对多轴情况下对 `Grid` 的特别处理进行说明 ：
    * 5.1、一般情况 `Overlap` 的图，我们都会自己设置轴索引，因此我们需要在 `Grid` 组件 `add` 图的时候配置 `is_control_axis_index` 的值为 `True`；这个配置的作用在于让我们之前设置的轴索引配置生效，否则会让 `pyecharts` 中的默认规则进行渲染。
    * 5.2、默认规则的代码段如下：
{{< highlight python >}}
if not is_control_axis_index:
    for s in self.options.get("series"):
        s.update(xAxisIndex=self._axis_index, yAxisIndex=self._axis_index)
{{< /highlight >}}

## Demo 2 （Grid + Overlap + 复杂多轴示例）的总结：
* 当理解了 Demo 1 多 Y 轴的使用之后，实际上 Demo 2 中仅仅加入了多 X 轴的配置（类似多 Y 轴的方式）以及 `Grid` 参数即可。
最重要的是理清楚轴索引的位置即可，因此各位同学可以在写代码画图之前，先画草图，规划好轴的索引，再开始从小图开始画起，最后在修改对应的轴索引。

## 总结：
* 在 Demo 1，2 的剖析中都提到了公式，按照所给出的公式推理方式，可以让各位同学画图的时候更加容易在脑海里形成图形的框架。
* 轴索引的概念其实并不难，最重要的是细心 😊，慢工出细活 🔨