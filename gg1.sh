#!/bin/bash
OIFS=$IFS
IFS="
"
NIFS=$IFS

# Change this directory
GG_HOME="/u01/app/ogg"
TOMCAT_PATH="/opt/tomcat/apache-tomcat-9.0.56/webapps/ROOT"

cat gg_monitoring_header > status.html

function status {
	OUTPUT=`$GG_HOME/ggsci << EOF
		info all
		exit
	EOF`
}

function monitoring {
	for line in $OUTPUT
	do
		if [[ $(echo "${line}"|egrep 'STOP|ABEND' >/dev/null;echo $?) = 0 ]]
		then
			GNAME=$(echo "${line}" | awk -F" " '{print $3}')
			GSTAT=$(echo "${line}" | awk -F" " '{print $2}')
			GTYPE=$(echo "${line}" | awk -F" " '{print $1}')
			GTIME=$(echo "${line}" | awk -F" " '{print $5}')

			HTML_BLOCK=$(cat <<-END
				<div class="box">
					<h2 class="online-text">${GNAME} </h2>
					<div class="offline-indicator">
					<span class="blink"></span>
					</div>
					<h2 class="online-text"> ${GTIME} </h2>
				</div>
			END
			)
			echo $HTML_BLOCK >> status.html

		fi
		if [[ $(echo "${line}"|egrep 'RUNNING' >/dev/null;echo $?) = 0 ]]
		then
			GNAME=$(echo "${line}" | awk -F" " '{print $3}')
			GSTAT=$(echo "${line}" | awk -F" " '{print $2}')
			GTYPE=$(echo "${line}" | awk -F" " '{print $1}')
			GTIME=$(echo "${line}" | awk -F" " '{print $5}')

					
			HTML_BLOCK=$(cat <<-END
				<div class="box">
					<h2 class="online-text">${GNAME} </h2>
					<div class="online-indicator">
					<span class="blink"></span>
					</div>
					<h2 class="online-text"> ${GTIME} </h2>
				</div>
			END
			)
			echo $HTML_BLOCK >> status.html
		fi
	done
}

status
monitoring

CURRENT_TIME=`date +"%Y-%m-%d %T"`
echo "<p>Last update: ${CURRENT_TIME}</p>" >> status.html

cat gg_monitoring_footer >> status.html

cp status.html ${TOMCAT_PATH}/status.html
