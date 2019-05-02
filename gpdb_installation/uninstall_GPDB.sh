#!/bin/bash
# use this script to clear existing GPDB package and data, run this one on master server

SegmentList="/home/gpadmin/all_segment_hosts.txt"
GP_HOME="/opt"
GP_DATA_MASTER="/data/master"
GP_DATA_SEGMENT="/data/segment"

echo -e "Getting the installed build under [$GP_HOME]:\n"

count=0
declare -A GPDB_BUILD


uninstallGPDB()
{
    build=$1
    gp_ver=`echo $build | sed 's/greenplum_//g'`

    gp_home=${GP_HOME}/${build}
    master_data_folder="${GP_DATA_MASTER}/master_${gp_ver}"
    segment_data_folder="${GP_DATA_SEGMENT}/segment_${gp_ver}"

    echo "Going to uninstall GPDB installed under [$gp_home]"
    echo "
Below folder will be removed if exists:

    ${gp_home}: 
    ${master_data_folder}: 
    ${segment_data_folder}: 

Please confirm if you would like to continue: [y/n]
"
    read confirm
    if [ "x$confirm" = 'xy' ] || [ "x$confirm" = 'xyes' ] || [ "x$confirm" = 'xY' ] || [ "x$confirm" = 'xYes' ]
    then

        ### TBD: check if the build is running. too lazy to add more code here...###
        #source $gp_home/greenplum_path.sh
        #gpstop -q -a -M fast

        [ -d ${gp_home} ] && rm -rf $gp_home && echo "Removed [$gp_home]"
        [ -d ${master_data_folder} ] && rm -rf $master_data_folder && echo "Removed [$master_data_folder]"
        for server in `cat $SegmentList`
        do
            ssh $server "[ -d ${segment_data_folder} ] && rm -rf $segment_data_folder"
            echo "Removed $segment_data_folder on segment host [$server]"
        done
    else
        echo "Cancelled by user, exit.."
    fi
}

for build in `ls $GP_HOME | grep greenplum_`
do
    count=$(($count+1))
    echo -e "    [$count]:  $build"
    GPDB_BUILD+=(["$count"]="$build")
done

echo -e "\nplease choose which build you want to uninstall:"
read input
build_2_remove=${GPDB_BUILD[$input]}

if [ "x$build_2_remove" = 'x' ]
then
    echo "Unable to find build with input [$input], exit!"
    exit 1
else
    
    uninstallGPDB $build_2_remove
fi

