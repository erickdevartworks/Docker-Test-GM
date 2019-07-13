#!/bin/bash
set -e

testAlias+=(
	[gamblecoind:trusty]='gamblecoind'
)

imageTests+=(
	[gamblecoind]='
		rpcpassword
	'
)
