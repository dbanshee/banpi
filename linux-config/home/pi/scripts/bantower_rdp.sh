#! /bin/bash

xfreerdp /u:banshee /p:wdrizztdo0 /w:1920 /h:1080 /v:192.168.15.101
#xfreerdp -u banshee -z --disable-menu-animations --disable-theming --disable-menu-animations banpi.bansheerocks.com:7089

# Algunos comandos como 'sudo rc_gui' fallan con 'cannot open display :11:0'
# Ejecutar xhost +
