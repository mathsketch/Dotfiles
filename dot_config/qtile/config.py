import os
import subprocess
import json
import re

from libqtile import bar, layout, widget, hook, qtile
from libqtile.config import Group, Match, Screen, KeyChord, Rule, ScratchPad, DropDown
from libqtile.config import EzKey as Key, EzClick as Click, EzDrag as Drag
from libqtile.lazy import lazy
from libqtile.scratchpad import ScratchPad as sp

from libqtile.log_utils import logger


mod = "mod4"
special_groups = [
    {
        "config": {
            "name": "browser",
            "persist": False,
            "matches": [Match(role="browser"),
                        Match(wm_class=re.compile("^Vivaldi")),],
            "label": "",
        },
        "deny_move": True,
    },
    {
        "config": {
            "name": "music",
            "persist": False,
            "matches": [Match(wm_class=re.compile("^netease-cloud-music"))],
            "label": "",
        },
        "deny_move": True,
    },
    {
        "config": {
            "name": "game",
            "persist": False,
            "matches": [Match(wm_class=re.compile('^Steam')),
                        Match(wm_class=re.compile("^Minecraft")),
                        Match(wm_instance_class="minecraft-launcher"),
                        Match(wm_class="org.jackhuang.hmcl.Launcher")],
            "label": "",
        },
        "deny_move": False,
    },
    {
        "config": {
            "name": "design",
            "persist": False,
            "matches": [Match(wm_class=re.compile('^Gimp.*?')),
                        Match(wm_class="Blender"),
                        Match(wm_class="Inkscape"),
                        Match(wm_class="Aseprite"),],
            "label": "",
        },
        "deny_move": True,
    },
    {
        "config": {
            "name": "doc",
            "persist": False,
            "matches": [Match(wm_class="wps"),
                        Match(wm_class="wpp"),
                        Match(wm_class="et")],
            "label": "",
        },
        "deny_move": True,
    },
    {
        "config": {
            "name": "develop",
            "persist": False,
            "matches": [Match(wm_class="jetbrains-idea-ce")],
            "label": "﬏",
        },
        "deny_move": True,
    },
    {
        "config": {
            "name": "msic",
            "persist": False,
            "matches": [Match(wm_class="VirtualBox Manager"),
                        Match(wm_class="Virt-manager"),
                        Match(wm_class="obs")],
            "label": "",
        },
        "deny_move": True,
    },
]
special_groups_name = [ entry["config"]["name"] for entry in special_groups ]
group_window_map = []


@hook.subscribe.restart
@hook.subscribe.startup_once
def autostart():
    path = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.Popen([path])

@hook.subscribe.client_managed
@hook.subscribe.client_urgent_hint_changed
@hook.subscribe.client_killed
@hook.subscribe.setgroup
@hook.subscribe.group_window_add
@hook.subscribe.current_screen_change
@hook.subscribe.changegroup
@hook.subscribe.addgroup
async def eww_workspace(*args, **kwargs):
    workspace_data = []
    for group in qtile.groups:
        if isinstance(group, sp):
            continue
        if group.windows:
            class_tag = "ws-button-busy"
            icon = u""
        else:
            class_tag = "ws-button"
            icon = u""
        if group == qtile.current_group:
            class_tag = "ws-button-visible"
            icon = u""
        if group.name in special_groups_name:
            class_tag += " ws-button-specified"
            icon = group.label

        workspace_data.append({
            "class": class_tag,
            "click": """ python -c '
from libqtile.command.client import InteractiveCommandClient
c = InteractiveCommandClient()
c.group["{}"].toscreen()' &
            """.format(group.name),
            "icon": icon,
        })

    workspace_data = json.dumps(workspace_data)
    subprocess.Popen(["eww", "update", "workspace_data={}".format(workspace_data)])

@hook.subscribe.layout_change
@hook.subscribe.changegroup
@hook.subscribe.current_screen_change
@hook.subscribe.setgroup
async def eww_layout_update(*args, **kwargs):
    layout_name = qtile.current_layout.name
    subprocess.Popen(["eww", "update", "layout_name={}".format(layout_name)])

@hook.subscribe.enter_chord
async def eww_enter_chord(_):
    subprocess.Popen(["eww", "update", "chord_mode=chord_on"])

@hook.subscribe.leave_chord
async def eww_leave_chord():
    subprocess.Popen(["eww", "update", "chord_mode=chord_off"])

@hook.subscribe.client_new
async def float_to_front(_):
    for window in qtile.current_group.windows:
        if hasattr(window, "floating") and window.floating:
            window.cmd_bring_to_front()

#
# for qtile window auto toggle minimize
#
# @hook.subscribe.focus_change
# async def auto_unminimize():
#     win = qtile.current_window
#     if win.minimized:
#         win.minimized = False

# @hook.subscribe.float_change
# async def auto_minimize_no_focus():
#     win = qtile.current_window
#     if win.minimized:
#         win.group.cmd_focus_back()

#
# fix plank covered by other windows
#
# plank_wid = 0
# @hook.subscribe.client_new
# @hook.subscribe.group_window_add
# @hook.subscribe.float_change
# async def plank_always_top(*args, **kwargs):
#     global plank_wid
#     if not plank_wid and plank_wid not in qtile.windows_map:
#         for window in qtile.windows_map.values():
#             if window.get_wm_class() == ['plank', 'Plank'] and window.get_wm_type() == "dock":
#                 plank_wid = window.wid

#     if plank_wid and plank_wid in qtile.windows_map:
#         qtile.windows_map[plank_wid].cmd_bring_to_front()

@hook.subscribe.client_new
async def float_steam(window):
    wm_class = window.window.get_wm_class()
    w_name = window.window.get_name()
    if wm_class == ("Steam", "Steam") and (
        w_name != "Steam"
        # w_name == "Friends List"
        # or w_name == "Screenshot Uploader"
        # or w_name.startswith("Steam - News")
        or "PMaxSize" in window.window.get_wm_normal_hints().get("flags", ())
    ):
        window.floating = True

@hook.subscribe.client_new
async def float_pycharm(window):
    wm_class = window.window.get_wm_class()
    w_name = window.window.get_name()
    if (wm_class == ("jetbrains-pycharm-ce", "jetbrains-pycharm-ce") and w_name == " ") or (
        wm_class == ("java-lang-Thread", "java-lang-Thread") and w_name == "win0"
    ):
        window.floating = True

@hook.subscribe.startup
@hook.subscribe.startup_complete
async def auto_delete_group(*args, **kwargs):
    for group in qtile.config.groups:
        match_list = group.matches
        matched = False

        if group.persist or group.name in qtile.groups_map and qtile.groups_map[group.name].windows:
            continue
        for window in qtile.windows_map.values():
            for rule in match_list:
                if rule.compare(window):
                    matched = True
                    window.cmd_togroup(group.name)
        if matched:
            continue
        qtile.cmd_delgroup(group.name)

@lazy.function
def group_toscreen(qtile, group, screen=None, toggle=False, special_follow=False):
    if isinstance(group, int):
        work_groups = [g for g in qtile.groups if not isinstance(g, sp)]
        if group >= len(work_groups):
            grp = work_groups[-1]
        else:
            grp = work_groups[group]
    elif isinstance(group, str):
        if group not in qtile.groups_map:
            return
        grp = qtile.groups_map[group]
    else:
        return

    if special_follow:
        for i, m in enumerate(group_window_map):
            if grp in m:
                m[2].cmd_togroup(grp.name)
                group_window_map.pop(i)
                break
    grp.cmd_toscreen(screen=screen, toggle=toggle)

@lazy.function
def window_togroup(qtile, group, switch_group = False, toggle = False):
    if isinstance(group, int):
        work_groups = [g for g in qtile.groups if not isinstance(g, sp)]
        if group >= len(work_groups):
            grp = work_groups[-1]
        else:
            grp = work_groups[group]
    elif isinstance(group, str):
        if group not in qtile.groups_map:
            return
        grp = qtile.groups_map[group]
    else:
        return
    current_group = qtile.current_group
    window = qtile.current_window

    disabled_groups = [i["config"]["name"] for i in special_groups if i["deny_move"]]

    if current_group.name in disabled_groups or grp.name in disabled_groups:
        return
    window.cmd_togroup(grp.name, switch_group=switch_group, toggle=toggle)

@lazy.function
def toggle_group_window(qtile, group_name):
    if group_name not in qtile.groups_map:
        logger.warn("{} not in groups".format(group_name))
        return

    global group_window_map
    current_group = qtile.current_group
    special_group = qtile.groups_map[group_name]

    if current_group == special_group:
        return
    for i, m in enumerate(group_window_map):
        if special_group in m:
            if current_group in m:
                m[2].cmd_togroup(m[1].name)
                group_window_map.pop(i)
            else:
                m[2].cmd_togroup(current_group.name)
                m[0] = current_group
            return

    window = special_group.current_window
    window.cmd_togroup()
    group_window_map.append([current_group, special_group, window])

@lazy.function
def next_window(qtile):
    group = qtile.current_group
    if not group.windows:
        return
    if group.current_window.floating:
        nxt = (
            group.floating_layout.focus_next(group.current_window)
            or group.layout.focus_first()
            or group.floating_layout.focus_first(group=group)
        )
    else:
        nxt = (
            group.layout.focus_next(group.current_window)
            or group.floating_layout.focus_first(group=group)
            or group.layout.focus_first()
        )

    if nxt.floating:
        nxt.cmd_bring_to_front()
    group.focus(nxt, True)

@lazy.function
def prev_window(qtile):
    group = qtile.current_group
    if not group.windows:
        return
    if group.current_window.floating:
        nxt = (
            group.floating_layout.focus_previous(group.current_window)
            or group.layout.focus_last()
            or group.floating_layout.focus_last(group=group)
        )
    else:
        nxt = (
            group.layout.focus_previous(group.current_window)
            or group.floating_layout.focus_last(group=group)
            or group.layout.focus_last()
        )

    if nxt.floating:
        nxt.cmd_bring_to_front()
    group.focus(nxt, True)

@lazy.function
def resize_floating_window(qtile, ratio=2, increase=True):
    window = qtile.current_window
    window_size = window.cmd_get_size()
    if increase:
        fin_w, fin_h = (int(n * ratio) for n in window_size)
    else:
        fin_w, fin_h = (int(n / ratio) for n in window_size)

    window.cmd_set_size_floating(fin_w, fin_h)
    window.cmd_center()
    window.window.warp_pointer(fin_w // 2, fin_h // 2)

# kill window
@lazy.function
def forced_kill_window(qtile):
    window_pid = qtile.current_window.get_pid()
    os.kill(window_pid, 9)

keys = [
    # For window
    Key("M-w", lazy.window.kill(), desc="Kill focused window"),
    Key("M-S-w", forced_kill_window(), desc="Forced kill focused window"),
    Key("M-c", next_window(), desc="Switch window focus to next window in group"),
    Key("M-S-c", prev_window(), desc="Switch window focus to previous window in group"),
    Key("M-f", lazy.window.toggle_fullscreen(), desc="Switch window focus to previous window in group"),
    Key("M-e", lazy.window.toggle_floating(), desc="Put the focused window to/from floating mode"),

    # For layout
    Key("M-h", lazy.layout.left().when(layout=["columns", "monadtall", "monadwide"])),
    Key("M-l", lazy.layout.right().when(layout=["columns", "monadtall", "monadwide"])),
    Key("M-j", lazy.layout.down().when(layout=["columns", "stack", "monadtall", "monadwide"])),
    Key("M-k", lazy.layout.up().when(layout=["columns", "stack", "monadtall", "monadwide"])),

    Key("M-S-h", lazy.layout.shuffle_left().when(layout=["columns", "monadtall", "monadwide"])),
    Key("M-S-l", lazy.layout.shuffle_right().when(layout=["columns", "monadtall", "monadwide"])),
    Key("M-S-j", lazy.layout.shuffle_down().when(layout=["columns", "stack", "monadtall", "monadwide"])),
    Key("M-S-k", lazy.layout.shuffle_up().when(layout=["columns", "stack", "monadtall", "monadwide"])),

    Key("M-C-h", lazy.layout.grow_left().when(layout=["columns", "bsp"])),
    Key("M-C-l", lazy.layout.grow_right().when(layout=["columns", "bsp"])),
    Key("M-C-j", lazy.layout.grow_down().when(layout=["columns", "bsp"])),
    Key("M-C-k", lazy.layout.grow_up().when(layout=["columns", "bsp"])),

    Key("M-r", lazy.layout.flip().when(layout=["monadtall", "monadwide"])),
    Key("M-C-k", lazy.layout.grow().when(layout=["monadtall", "monadwide"])),
    Key("M-C-j", lazy.layout.shrink().when(layout=["monadtall", "monadwide"])),
    Key("M-C-l", lazy.layout.grow_main().when(layout=["monadtall", "monadwide"])),
    Key("M-C-h", lazy.layout.shrink_main().when(layout=["monadtall", "monadwide"])),

    Key("M-s", lazy.layout.toggle_split().when(layout=["columns", "stack"])),
    Key("M-n", lazy.layout.normalize().when(layout=["columns", "monadtall", "monadwide"])),
    Key("M-S-n", lazy.layout.reset().when(layout=["columns", "monadtall", "monadwide"])),
    Key("M-m", lazy.layout.maximize().when(layout=["columns", "monadtall", "monadwide"])),
    Key("M-<Right>", lazy.layout.increase_ratio()),
    Key("M-<Left>", lazy.layout.decrease_ratio()),

    Key("M-<period>", lazy.next_layout(), desc="previous layouts"),
    Key("M-<comma>", lazy.prev_layout(), desc="previous layout"),

    # For group
    Key("M-<Tab>", lazy.screen.toggle_group(), desc="Move to the last visited group"),
    Key("M-<bracketright>", lazy.screen.next_group(skip_empty=True), desc="Move to the group on the right"),
    Key("M-<bracketleft>", lazy.screen.prev_group(skip_empty=True), desc="Move to the group on the left"),

    # For execution
    Key("M-<Return>", lazy.spawn("st"), desc="Launch terminal"),
    Key(
        "M-b",
        lazy.spawn(os.path.expanduser("~/.config/eww/scripts/toggleww")),
        desc="toggle eww subbar",
    ),
    Key("M-S-b", lazy.spawn("eww open --toggle topbar"), desc="toggle eww topbar"),
    Key(
        "M-<grave>",
        lazy.spawn("rofi -show drun -theme-str '*{tc:@yl;}' -show-icons -selected-row 0"),
        desc="open application launcher",
    ),
    Key(
        "M-q",
        lazy.spawn("rofi -show window -theme-str '*{tc:@yl;}' -show-icons -selected-row 0"),
        desc="open window selector",
    ),
    Key("M-S-<grave>", lazy.spawn(os.path.expanduser("~/.config/rofi/bin/setting.sh")), desc="open settitng",),
    Key(
        "M-v",
        lazy.spawn(os.path.expanduser("~/.config/rofi/bin/cliprint.sh")),
        desc="open history clipboard",
    ),
    Key(
        "M-A-<Delete>",
        lazy.spawn(os.path.expanduser("~/.config/rofi/bin/menu_powermenu.sh")),
        desc="open powermenu",
    ),
    Key("M-S-d", lazy.spawn("ocr_dict"), desc="goldendict and ocr"),
    Key("M-S-o", lazy.spawn("hide_window"), desc="hide and show window"),

    # For Media key
    Key("<XF86TouchpadToggle>", lazy.spawn("touchpad_toggle"), desc="toggle touchpad"),
    Key("<XF86AudioMute>", lazy.spawn("notify -vm"), desc="audio mute"),
    Key("<XF86AudioRaiseVolume>", lazy.spawn("notify -vi 5"), desc="audio raise volume"),
    Key("<XF86AudioLowerVolume>", lazy.spawn("notify -vd 5"), desc="audio lower volume"),
    Key("<XF86MonBrightnessUp>", lazy.spawn("notify -li 2"), desc="brightness up"),
    Key("<XF86MonBrightnessDown>", lazy.spawn("notify -ld 2"), desc="brightness down"),
    Key("<Print>", lazy.spawn("flameshot gui"), desc="screnn print"),
    Key(
        "<XF86Calculator>",
        lazy.spawn(
            "rofi -show calc -modi calc -no-show-match -normalize-match -no-sort -selected-row 0 -no-persist-history -calc-command 'greenclip print '{result}''"
        ),
        desc="Calculator",
    ),

    # For Playerctl
    Key("C-A-<Left>", lazy.spawn("playerctl previous"), desc="play previous"),
    Key("C-A-<Right>", lazy.spawn("playerctl next"), desc="play next"),
    Key("C-A-<Up>", lazy.spawn("playerctl volume 0.02+"), desc="player volume up"),
    Key("C-A-<Down>", lazy.spawn("playerctl volume 0.02-"), desc="player volume down"),
    Key("C-A-p", lazy.spawn("playerctl play-pause"), desc="toggle play and pause"),

    # For qtile
    Key("M-A-r", lazy.reload_config(), desc="Reload the config"),
    Key("M-A-S-r", lazy.restart(), desc="Restart Qtile"),
    Key("M-A-q", lazy.shutdown(), desc="Shutdown Qtile"),

    # test
    # Key("M-d", float_to_front)
    # KeyChord([mod], "x", [
    #   Key("d", float_to_front)
    # ])
]

groups = [Group(i) for i in "1234"] + [Group(**i["config"]) for i in special_groups]

chord_list = []
for index, _ in enumerate(groups):
    if index < 9:
        key = index + 1
        keys.extend([
            Key("M-{}".format(key), group_toscreen(index, toggle=True)),
            Key("M-S-{}".format(key), window_togroup(index)),
        ])
    elif index == 9:
        keys.extend([
            Key("M-{}".format(0), group_toscreen(index, toggle=True)),
            Key("M-S-{}".format(0), window_togroup(index)),
        ])
    else:
        key = "qwertyuiop"[index - 10]
        chord_list.append(Key(key, group_toscreen(index, toggle=True)))
        chord_list.append(Key("S-{}".format(key), window_togroup(index)))

# browser special binding
keys.extend([
    Key("M-u", group_toscreen("browser", toggle=True, special_follow=True)),
    Key("M-S-u", toggle_group_window("browser")),
])
keys.append(KeyChord([mod], "x", chord_list))   # type: ignore

# scratchpad
groups.extend(
    [
        ScratchPad(
            "session",
            dropdowns=[
                DropDown(
                    "terminal",
                    "st -e sh -c 'tmux has-session 2>/dev/null || tmux new && tmux attach'",
                    height=0.65,
                    width=0.8,
                    x=0.125,
                    y=-0.065,
                    on_focus_lost_hide=True,
                    opacity=1.0,
                ),
                DropDown(
                    "ncmpcpp",
                    "st -A 100 -e mpp",
                    height=0.38,
                    width=0.58,
                    x=0.02,
                    y=0.59,
                    on_focus_lost_hide=True,
                    opacity=1.0,
                ),
            ],
        )
    ]
)

keys.extend(
    [
        Key("M-S-<Return>", lazy.group["session"].dropdown_toggle("terminal")),
        Key("M-S-m", lazy.group["session"].dropdown_toggle("ncmpcpp")),
    ]
)

layout_default_style = dict(
    border_focus="#f2e5bc",
    border_normal="#3c3836",
    border_width=2,
    margin=20,
)

layouts = [
    layout.MonadTall(new_client_position="top", **layout_default_style),  # type: ignore
    layout.Stack(num_stacks=1, **layout_default_style),  # type: ignore
]


screens = [
    Screen(
        top=bar.Gap(61),
    ),
]

# Drag floating layouts.
mouse = [
    Drag(
        "M-1",
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        "M-3", lazy.window.set_size_floating(), start=lazy.window.get_size()
    ),
    Click("M-2", lazy.window.bring_to_front()),
    Click("M-5", lazy.screen.next_group()),
    Click("M-4", lazy.screen.prev_group()),
    Click("M-9", resize_floating_window(increase=True)),
    Click("M-8", resize_floating_window(increase=False)),
]

floating_layout = layout.Floating( # type: ignore
    float_rules=[
        *layout.Floating.default_float_rules, # type: ignore
        Match(role="pop-up"),
        Match(wm_class="Pavucontrol"),
        Match(wm_class="Anki"),
        Match(wm_class="Pinentry-gtk-2"),
    ],
    border_focus='#f2e5bc',
    border_normal='#83a598',
    border_width=2,
)

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = True
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = False
wl_input_rules = None
wmname = "LG3D"


# experiment
# from experiment import *
# keys.extend([
#     Key("M-<period>", float_cycle_forward),
#     Key("M-<comma>", float_cycle_backward),
# ])
