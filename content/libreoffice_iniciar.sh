#!/bin/sh

nohup /usr/bin/libreoffice --nologo --norestore --invisible --headless --accept='socket,host=0,port=8100,tcpNoDelay=1;urp;'  >myscript.log 2>&1 &