<chart>
id=132692695521406530
symbol=GER30
period=240
leftpos=1666
digits=2
scale=2
graph=2
fore=0
grid=1
volume=0
scroll=1
shift=0
ohlc=1
one_click=0
one_click_btn=1
askline=0
days=0
descriptions=0
shift_size=20
fixed_pos=0
window_left=1
window_top=360
window_right=862
window_bottom=703
window_type=2
background_color=0
foreground_color=16777215
barup_color=65280
bardown_color=65280
bullcandle_color=0
bearcandle_color=16777215
chartline_color=65280
volumes_color=3329330
grid_color=10061943
askline_color=255
stops_color=255

<window>
height=100
fixed_height=0
<indicator>
name=main
<object>
type=10
object_name=Fibo 28998
period_flags=0
create_time=1624797510
color=255
style=2
weight=1
background=0
filling=0
selectable=1
hidden=0
zorder=0
color2=65535
style2=0
weight2=1
time_0=1614819600
value_0=14292.632701
time_1=1613451600
value_1=13660.937441
levels_ray=0
level_0=0.0000
description_0=0.0
level_1=0.2360
description_1=23.6
level_2=0.3820
description_2=38.2
level_3=0.5000
description_3=50.0
level_4=0.6180
description_4=61.8
level_5=1.0000
description_5=100.0
level_6=1.6180
description_6=161.8
level_7=2.6180
description_7=261.8
level_8=4.2360
description_8=423.6
</object>
<object>
type=10
object_name=Fibo 29027
period_flags=0
create_time=1624797539
color=255
style=2
weight=1
background=0
filling=0
selectable=1
hidden=0
zorder=0
color2=65535
style2=0
weight2=1
time_0=1615582800
value_0=14273.192417
time_1=1615928400
value_1=14344.486493
levels_ray=0
level_0=0.0000
description_0=0.0
level_1=0.2360
description_1=23.6
level_2=0.3820
description_2=38.2
level_3=0.5000
description_3=50.0
level_4=0.6180
description_4=61.8
level_5=1.0000
description_5=100.0
level_6=1.6180
description_6=161.8
level_7=2.6180
description_7=261.8
level_8=4.2360
description_8=423.6
</object>
</indicator>
<indicator>
name=Envelopes
period=14
shift=0
method=0
apply=0
deviation=0.10
color=16711680
style=0
weight=1
color2=255
style2=0
weight2=1
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=14
shift=0
method=0
apply=0
color=255
style=0
weight=1
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=50
fixed_height=0
<indicator>
name=Average Directional Movement Index
period=14
apply=0
color=11186720
style=0
weight=1
color2=3329434
style2=2
weight2=1
color3=11788021
style3=2
weight3=1
period_flags=0
show_data=1
</indicator>
</window>

<expert>
name=MACD Sample
flags=275
window_num=0
<inputs>
TakeProfit=50.0
Lots=0.1
TrailingStop=30.0
MACDOpenLevel=3.0
MACDCloseLevel=2.0
MATrendPeriod=26
</inputs>
</expert>
</chart>

