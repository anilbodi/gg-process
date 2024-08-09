#!/bin/bash
EMAIL_LIST="support@dbsbank.com"
OIFS=$IFS
IFS=" "
NIFS=$IFS

function status {
    OUTPUT=$($/u01/app/ogg/ggsci << EOF
    info all
    exit
EOF
)
}

function alert {
    for line in $OUTPUT; do
        if [[ $(echo "${line}" | egrep 'STOP|ABEND' >/dev/null; echo $?) = 0 ]]; then
            GNAME=$(echo "${line}" | awk -F" " '{print $3}')
            GSTAT=$(echo "${line}" | awk -F" " '{print $2}')
            GTYPE=$(echo "${line}" | awk -F" " '{print $1}')
            case $GTYPE in
                "MANAGER")
                    cat $GG_HOME/dirrpt/MGR.rpt | mailx -s "${HOSTNAME} - GoldenGate ${GTYPE} ${GSTAT}" $NOTIFY
                    ;;
                "EXTRACT"|"REPLICAT")
                    cat $GG_HOME/dirrpt/"${GNAME}".rpt | mailx -s "${HOSTNAME} - GoldenGate ${GTYPE} ${GNAME} ${GSTAT}" $EMAIL_LIST
                    ;;
            esac
        fi
    done
}

export GG_HOME=/goldengate/install/software/gghome_1
export ORACLE_HOME=/oracle/app/oracle/product/12.1.0/db_1
export LD_LIBRARY_PATH=$ORACLE_HOME/lib

status
alert
