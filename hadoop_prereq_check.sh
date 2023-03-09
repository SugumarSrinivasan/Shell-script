#!/bin/bash

#==================================================================================================#
#                                                                                                  #
#       Author: Sugumar Srinivasan                                                                 #
#       Description: This is a pre-requisite validation script for Apache-Hadoop                   #
#       Date: 09/03/2023                                                                           #
#       Modified Date: 09/03/2023                                                                  #
#                                                                                                  #
#==================================================================================================#


function state() {
    local msg=$1
    local flag=$2
    if [ "$flag" -eq 0 ]; then
        echo -e "\e[92m PASS \033[0m $msg"
    elif [ "$flag" -eq 2 ]; then
        echo -e "\e[93m WARN \033[0m $msg"
    else
        echo -e "\e[91m FAIL \033[0m $msg"
    fi
}
function check_selinux() {
   local msg="System: SELinux should be disabled"
   case $(getenforce) in
        Disabled|Permissive) state "$msg" 0;;
        *)                   state "$msg. Actual: $(getenforce)" 1;;
   esac
}
function sudo_privilege_check() {
   local msg="System: User: `echo $USER` is having sudo privilege"
   if groups | grep "\<wheel\>" &> /dev/null; then
       state "$msg" 0
   else
       state "System: User: `echo $USER` don't have sudo privilege and the user must be the part of 'wheel' group to get sudo privilege. Actual: `groups`" 1
   fi
}
function check_thp_defrag() {
    local file
    file=$(find /sys/kernel/mm/ -type d -name '*transparent_hugepage')/defrag
    if [ -f "$file" ]; then
       local msg="System: $file should be disabled"
       if grep -F -q "[never]" "$file"; then
          state "$msg" 0
       else
          state "$msg. Actual: $(awk '{print $1}' "$file" | sed -e 's/\[//' -e 's/\]//')" 1
       fi
    else
          state "System: /sys/kernel/mm/*transparent_hugepage not found. Check skipped" 2
    fi
}

function check_thp_enabled() {
      local file
      file=$(find /sys/kernel/mm/ -type d -name '*transparent_hugepage')/enabled
      if [ -f "$file" ]; then
         local msg="System: $file should be disabled"
         if grep -F -q "[never]" "$file"; then
            state "$msg" 0
         else
            state "$msg. Actual: $(awk '{print $1}' "$file" | sed -e 's/\[//' -e 's/\]//')" 1
         fi
      else
            state "System: /sys/kernel/mm/*transparent_hugepage not found. Check skipped" 2
      fi
}
function check_thp_grub() {
    if [ -f "/etc/default/grub" ]; then
        local msg="System: /etc/default/grub should have 'transparent_hugepage=never' appended to GRUB_CMDLINE_LINUX"
        if grep -F -q "transparent_hugepage=never" "/etc/default/grub"; then
           state "$msg" 0
        else
           state "$msg. Actual: $(grep GRUB_CMDLINE_LINUX /etc/default/grub)" 1
        fi
    else
        state "System: /etc/default/grub not found. Check skipped" 2
    fi
}
function check_swappiness() {
   local swappiness
   local msg="System: /proc/sys/vm/swappiness should be 1"
   swappiness=$(cat /proc/sys/vm/swappiness)
      if [ "$swappiness" -eq 1 ]; then
          state "$msg" 0
      else
          state "$msg. Actual: $swappiness" 1
      fi
}
function check_ipv6() {
   local msg="Network: IPv6 is not supported and must be disabled"
   if ip addr show | grep -q inet6; then
       state "${msg}" 1
   else
       state "${msg}" 0
   fi
}
function check_java() {
    # The following candidate list is from CM agent:
    # Starship/cmf/agents/cmf/service/common/cloudera-config.sh
    local JAVA6_HOME_CANDIDATES=(
        '/usr/lib/j2sdk1.6-sun'
        '/usr/lib/jvm/java-6-sun'
        '/usr/lib/jvm/java-1.6.0-sun-1.6.0'
        '/usr/lib/jvm/j2sdk1.6-oracle'
        '/usr/lib/jvm/j2sdk1.6-oracle/jre'
        '/usr/java/jdk1.6'
        '/usr/java/jre1.6'
    )
    local OPENJAVA6_HOME_CANDIDATES=(
        '/usr/lib/jvm/java-1.6.0-openjdk'
        '/usr/lib/jvm/jre-1.6.0-openjdk'
    )
    local JAVA7_HOME_CANDIDATES=(
        '/usr/java/jdk1.7'
        '/usr/java/jre1.7'
        '/usr/lib/jvm/j2sdk1.7-oracle'
        '/usr/lib/jvm/j2sdk1.7-oracle/jre'
        '/usr/lib/jvm/java-7-oracle'
    )
    local OPENJAVA7_HOME_CANDIDATES=(
        '/usr/lib/jvm/java-1.7.0-openjdk'
        '/usr/lib/jvm/java-7-openjdk'
    )
    local JAVA8_HOME_CANDIDATES=(
        '/usr/java/jdk1.8'
        '/usr/java/jre1.8'
        '/usr/lib/jvm/j2sdk1.8-oracle'
        '/usr/lib/jvm/j2sdk1.8-oracle/jre'
        '/usr/lib/jvm/java-8-oracle'
    )
    local OPENJAVA8_HOME_CANDIDATES=(
        '/usr/lib/jvm/java-1.8.0-openjdk'
        '/usr/lib/jvm/java-8-openjdk'
    )
    local MISCJAVA_HOME_CANDIDATES=(
        '/Library/Java/Home'
        '/usr/java/default'
        '/usr/lib/jvm/default-java'
        '/usr/lib/jvm/java-openjdk'
        '/usr/lib/jvm/jre-openjdk'
    )
    local JAVA_HOME_CANDIDATES=(
        "${JAVA7_HOME_CANDIDATES[@]}"
        "${JAVA8_HOME_CANDIDATES[@]}"
        "${JAVA6_HOME_CANDIDATES[@]}"
        "${MISCJAVA_HOME_CANDIDATES[@]}"
        "${OPENJAVA7_HOME_CANDIDATES[@]}"
        "${OPENJAVA8_HOME_CANDIDATES[@]}"
        "${OPENJAVA6_HOME_CANDIDATES[@]}"
    )

    # Find and verify Java
    # https://www.cloudera.com/documentation/enterprise/release-notes/topics/rn_consolidated_pcm.html#pcm_jdk
    # JDK 7 minimum required version is JDK 1.7u55
    # JDK 8 minimum required version is JDK 1.8u31
    # excludes JDK 1.8u40, JDK 1.8u45, and JDK 1.8u60
    # OpenJDK minimum required version is 1.8u181
    java_found=false
    for candidate_regex in "${JAVA_HOME_CANDIDATES[@]}"; do
        # shellcheck disable=SC2045,SC2086
        for candidate in $(ls -rvd ${candidate_regex}* 2>/dev/null); do
            if [ -x "$candidate/bin/java" ]; then
                java_found=true
                JDK_VERSION=$($candidate/bin/java -version 2>&1 | head -1 | awk '{print $NF}' | tr -d '"')
                JDK_VERSION_REGEX='1\.([0-9])\.0_([0-9][0-9]*)'
                JDK_TYPE=$($candidate/bin/java -version 2>&1 | head -2 | tail -1 | awk '{print $1}')
                if [[ $JDK_TYPE = "Java(TM)" ]]; then
                    if [[ $JDK_VERSION =~ $JDK_VERSION_REGEX ]]; then
                        if [[ ${BASH_REMATCH[1]} -eq 7 ]]; then
                            if [[ ${BASH_REMATCH[2]} -lt 55 ]]; then
                                state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 1
                            else
                                state "Java: Supported Oracle Java: ${candidate}/bin/java" 0
                                check_jce ${candidate}
                            fi
                        elif [[ ${BASH_REMATCH[1]} -eq 8 ]]; then
                            if [[ ${BASH_REMATCH[2]} -lt 31 ]]; then
                                state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 1
                            elif [[ ${BASH_REMATCH[2]} -eq 40 ]]; then
                                state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 1
                            elif [[ ${BASH_REMATCH[2]} -eq 45 ]]; then
                                state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 1
                            elif [[ ${BASH_REMATCH[2]} -eq 60 ]]; then
                                state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 1
                            elif [[ ${BASH_REMATCH[2]} -eq 75 ]]; then
                                state "Java: Oozie will not work on this Java (OOZIE-2533): ${candidate}/bin/java" 2
                            else
                                state "Java: Supported Oracle Java: ${candidate}/bin/java" 0
                                check_jce ${candidate}
                            fi
                        else
                            state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 1
                        fi
                    else
                        state "Java: Unsupported Oracle Java: ${candidate}/bin/java" 1
                    fi
                elif [[ $JDK_TYPE = "OpenJDK" ]]; then
                    if [[ $JDK_VERSION =~ $JDK_VERSION_REGEX ]]; then
                        if [[ ${BASH_REMATCH[1]} -eq 7 ]]; then
                            state "Java: Unsupported OpenJDK: ${candidate}/bin/java" 1
                        elif [[ ${BASH_REMATCH[1]} -eq 8 ]]; then
                            if [[ ${BASH_REMATCH[2]} -lt 181 ]]; then
                                state "Java: Unsupported OpenJDK: ${candidate}/bin/java" 1
                            elif [[ ${BASH_REMATCH[2]} -eq 242 ]]; then
                                # https://bugs.openjdk.java.net/browse/JDK-8215032
                                state "Java: Servers with Kerberos enabled stop functioning when using OpenJDK 1.8u242" 2
                            else
                                state "Java: Supported OpenJDK : ${candidate}/bin/java" 0
                            fi
                        else
                            state "Java: Unsupported OpenJDK: ${candidate}/bin/java" 1
                        fi
                    else
                        state "Java: Unsupported OpenJDK: ${candidate}/bin/java" 1
                    fi
                else
                    state "Java: Unsupported Unknown: ${candidate}/bin/java" 1
                fi
            fi
        done
    done
    if [ "$java_found" = false ] ; then
        state "Java: No JDK installed" 1
    fi
}
function chrony_installation_check() {
    local msg="System: Chronyd Installed"
    rpm -qa | grep chrony-* > /dev/null 2>&1
    if [ $? -eq 0 ]; then
       state "$msg" 0
    else
       state "System: Chronyd Not Installed" 1
    fi
}

function python3_installation_check() {
    local msg="Python: Python3 Installed"
    python3 -V > /dev/null 2>&1
    if [ $? -eq 0 ]; then
       state "$msg" 0
    else
       state "Python: Python3 Not Installed" 1
    fi
}

function krb5_server_check() {
    local msg="System: Krb5 Server Installed"
    rpm -qa | grep krb5-server-* > /dev/null 2>&1
    if [ $? -eq 0 ]; then
       state "$msg" 0
    else
       state "System: Krb5 Server Not Installed" 1
    fi
}

function krb5_workstation_check() {
    local msg="System: Krb5 Workstation Installed"
    rpm -qa | grep krb5-workstation-* > /dev/null 2>&1
    if [ $? -eq 0 ]; then
       state "$msg" 0
    else
       state "System: Krb5 Workstation Not Installed" 1
    fi
}
echo -e "\n"
echo -e "Validation of pre-requisites for Apache Hadoop Installation in (`hostname -i`):"
echo -e "\n"
sudo_privilege_check
check_selinux
check_thp_defrag
check_thp_enabled
check_thp_grub
check_swappiness
chrony_installation_check
krb5_server_check
krb5_workstation_check
check_ipv6
check_java
python3_installation_check
echo -e "\n"
