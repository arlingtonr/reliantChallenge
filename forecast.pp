package{'jq':
  ensure => 'installed',
}

class forecast {
  file { "/usr/local/bin/forecast":
    ensure  => "present",
    before  => File['/usr/local/bin/forecastd'],
    mode    => 'u+x',
    content => "#!/bin/bash

start() {
   \${0}d & echo $!>\${0}d.pid
}

stop() {
   kill `cat \${0}d.pid`
   rm \${0}d.pid
}

case \${1} in
start)
   start
   ;;
stop)
   stop
   ;;
restart)
   \${0} stop
   \${0} start
   ;;
status)
   if [ -e \${0}d.pid ]; then
      echo \${0} is running, pid=`cat \${0}d.pid`
   else
      echo \${0} is NOT running
      exit 1
   fi
   ;;
*)
   echo Usage: \${0} {start|stop|status|restart}
esac

exit 0",
  }

  file { "/usr/local/bin/forecastd":
    ensure  => "present",
    mode    => 'u+x',
    content => "#!/bin/bash

path=\"/opt\"
lat=\"-7.1195\"
lon=\"-34.845\"
apiKey=\"6641249303ea2ba4d4713bbafed7e716\"

if [ -z \${lat} ];then
    ERR=10
    echo \"ERROR \${ERR}: No latitude specified. Check the attribute settings.\"
    exit \${ERR}
fi

if [ -z \${lon} ];then
    ERR=11
    echo \"ERROR \${ERR}: No longitude specified. Check the attribute settings.\"
    exit \${ERR}
fi

if [ -z \${apiKey} ];then
    ERR=12
    echo \"ERROR \${ERR}: No API Key specified. Check the attribute settings.\"
    exit \${ERR}
fi

exclude=\"minutely,hourly,daily,alerts\"
units=\"metric\"
intervalToWriteFile=60
URL=\"https://api.openweathermap.org/data/2.5/onecall?lat=\${lat}&lon=\${lon}&exclude=\${exclude}&units=\${units}&appid=\${apiKey}\"

while true; do
        date=\$(date +'%Y%m%d%H%M%S')
        fcData=\$( curl -s \${URL} )
        echo \${fcData} | jq \".\" > \${path}/forecast_\${date}.txt
        sleep \${intervalToWriteFile}
done",
  }

  service { "forecast":
    name    => "forecast",
    ensure  => "running",
    start   => "/usr/local/bin/forecast start",
    stop    => "/usr/local/bin/forecast stop",
    status  => "/usr/local/bin/forecast status",
    pattern => "/usr/local/bin/forecast"
  }
}

include forecast
