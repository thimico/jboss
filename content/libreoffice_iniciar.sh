#!/bin/sh

nohup /usr/bin/libreoffice --nologo --norestore --invisible --headless --accept='socket,host=0,port=8100,tcpNoDelay=1;urp;'  >myscript.log 2>&1 &
/opt/jboss-as-7.1.1.Final/bin/standalone.sh -b 0.0.0.0