#!/usr/bin/python3
from logitech_receiver import hidpp20
from logitech_receiver import Receiver, Device
from logitech_receiver.base import receivers, wired_devices
import os
import asyncio
import time


class MouseInfo():
    def __init__(self):
        self.last_status = int(os.popen('cat /proc/bus/input/devices | grep -i logitech -c').read())

    def get_mouse_info(self, force=False):
        battery = None
        while battery is None:
            try:
                if self.last_status == 1:
                    for dev_info in receivers():
                        rev = Receiver.open(dev_info)
                        for dev in rev:
                            dev.online = True
                            battery = hidpp20.get_voltage(dev)
                elif self.last_status == 2:
                    for dev_info in wired_devices():
                        dev = Device.open(dev_info)
                        dev.online = True
                        battery = hidpp20.get_voltage(dev)
                else:
                    break
            except Exception:
                time.sleep(1)
                continue
            finally:
                # print(battery)
                if force:
                    time.sleep(0.5)
                else:
                    break

        if battery:
            level, status, voltage, *arg = battery
            if status == 'recharging':
                print('%{F#fabd2f}󰍽%{F-} ')
            elif int(voltage) <= 3770:
                print('%{F#fb4934}󰍽%{F-} ')
                os.system("notify-send -u critical '鼠标电量较低'")
            else:
                if status == 'full':
                    os.system("notify-send -u low '鼠标电量已满'")
                print('%{F#8ec07c}󰍽%{F-} ')

    async def mouse_status(self):
        while True:
            now_status = int(os.popen('cat /proc/bus/input/devices | grep -i logitech -c').read())
            # print(now_status)
            if self.last_status != now_status:
                self.last_status = now_status
                # print("s %d" %(self.last_status))
                if now_status:
                    await asyncio.sleep(1)
                    self.get_mouse_info(force=True)
            await asyncio.sleep(1)

    async def polybar_display(self):
        self.get_mouse_info(force=True)
        while True:
            self.get_mouse_info()
            await asyncio.sleep(1200)

    async def main(self):
        await asyncio.gather(
            self.mouse_status(),
            self.polybar_display()
        )

    def run(self):
        asyncio.run(self.main())


if __name__ == '__main__':
    mouse = MouseInfo()
    mouse.run()
