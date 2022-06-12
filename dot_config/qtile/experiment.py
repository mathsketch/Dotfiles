from libqtile.command import lazy
import time
import asyncio

floating_window_index = 0

# def float_cycle(qtile, forward: bool):
#     global floating_window_index
#     floating_windows = []
#     for window in qtile.current_group.windows:
#         if window.floating:
#             floating_windows.append(window)
#     if not floating_windows:
#         return
#     floating_window_index = min(floating_window_index, len(floating_windows) -1)
#     if forward:
#         floating_window_index += 1
#     else:
#         floating_window_index += 1
#     if floating_window_index >= len(floating_windows):
#         floating_window_index = 0
#     if floating_window_index < 0:
#         floating_window_index = len(floating_windows) - 1
#     win = floating_windows[floating_window_index]
#     win.cmd_bring_to_front()
#     win.cmd_focus()

def float_cycle(qtile, forward: bool):
    group = qtile.current_group
    window = qtile.current_window
    floating_layout = group.floating_layout
    if forward:
        win = (
            floating_layout.focus_next(window)
            or floating_layout.focus_first()
            or floating_layout.focus_first(group=group)
        )
    else:
        win = (
            floating_layout.focus_previous(window)
            or floating_layout.focus_last()
            or floating_layout.focus_last(group=group)
        )

    if win:
        win.cmd_focus()
        win.cmd_bring_to_front()

@lazy.function
def float_cycle_backward(qtile):
    float_cycle(qtile, False)

@lazy.function
def float_cycle_forward(qtile):
    float_cycle(qtile, True)
