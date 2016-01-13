#!/bin/sh
#########################################################
LocalDir=""
#########################################################

iterate () {
    cat logs_list.txt | while read l
    do
        IFS=':' read -a arr <<< "${l}"
        host=${arr[0]}
        port=${arr[1]}
        user=${arr[2]}
        key=${arr[3]}
        log_path=${arr[4]}


        #Skip on comments
        if [ "${l:0:1}" == "#" ];then
            continue
        fi


        #check user
        if [ "$user" == "" ]; then
           user="root"
        fi

        #check user
        if [ "$port" == "" ]; then
           port=22
        fi


        echo "Storing KEY for host $host"

        ssh-keyscan -p $port -H $host >> ~/.ssh/known_hosts

        get_log $host $port $user $key $log_path

        echo "---------------------------------------------"

    done
}


get_log () {
    echo "Getting log from host ${1} using port ${2} and user ${3}"

    #Check if copying multiple files
    dest_path=$(basename "$log_path")
    if [ dest_path == "*" ]; then dest_path = ""; fi

    if [ "$key" != "" ];then
        echo "Using key: $4"
        scp -i $4 -P $2 $3@$1:$log_path $LocalDir/$dest_path  &> log_$1
    else
        scp -P $2 $3@$1:$log_path $LocalDir/$dest_path &> log_$1
    fi
}


#init------
echo "Starting `date -u`"
iterate
echo "Completed - `date -u`"