#!/bin/bash
# addd 2016-03-24 by RGerhards, released under ASL 2.0

uname
if [ $(uname) = "SunOS" ] ; then
   echo "Solaris: FIX ME"
   exit 77
fi

. $srcdir/privdrop_common.sh
rsyslog_testbench_setup_testuser

. ${srcdir:=.}/diag.sh init
generate_conf
add_conf '
global(privdrop.group.keepsupplemental="on")
template(name="outfmt" type="list") {
	property(name="msg" compressSpace="on")
	constant(value="\n")
}
action(type="omfile" template="outfmt" file=`echo $RSYSLOG_OUT_LOG`)
'
add_conf "\$PrivDropToGroup ${TESTBENCH_TESTUSER[groupname]}"
startup
shutdown_when_empty
wait_shutdown
grep "groupid.*${TESTBENCH_TESTUSER[gid]}" < $RSYSLOG_OUT_LOG
if [ ! $? -eq 0 ]; then
  echo "message indicating drop to group \"${TESTBENCH_TESTUSER[groupname]}\" (#${TESTBENCH_TESTUSER[gid]}) is missing:"
  cat $RSYSLOG_OUT_LOG
  exit 1
fi;

exit_test
