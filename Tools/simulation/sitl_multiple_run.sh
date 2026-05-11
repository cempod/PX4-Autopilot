#!/bin/bash
# run multiple instances of the 'px4' binary, but w/o starting the simulator.
# It assumes px4 is already built, with 'make px4_sitl_default'

# The simulator is expected to send to TCP port 4560+i for i in [0, N-1]
# For example jmavsim can be run like this:
#./Tools/simulation/jmavsim/jmavsim_run.sh -p 4561 -l

sitl_num=2
[ -n "$1" ] && sitl_num="$1"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
src_path="$SCRIPT_DIR/../../"

build_path=${src_path}/build/px4_sitl_default

# Pick px4 vs px4.exe so this script also runs from Git Bash on Windows.
px4_bin="$build_path/bin/px4"
[ -x "$px4_bin.exe" ] && px4_bin="$px4_bin.exe"

echo "killing running instances"
if command -v pkill >/dev/null 2>&1; then
	pkill -x px4 || true
fi
if command -v taskkill >/dev/null 2>&1; then
	taskkill //IM px4.exe //F >/dev/null 2>&1 || true
fi

sleep 1

export PX4_SIM_MODEL=gazebo-classic_iris

n=0
while [ $n -lt $sitl_num ]; do
	working_dir="$build_path/instance_$n"
	[ ! -d "$working_dir" ] && mkdir -p "$working_dir"

	pushd "$working_dir" &>/dev/null
	echo "starting instance $n in $(pwd)"
	"$px4_bin" -i $n -d "$build_path/etc" >out.log 2>err.log &
	popd &>/dev/null

	n=$(($n + 1))
done
