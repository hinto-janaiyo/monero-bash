# This file is part of monero-bash - a wrapper for Monero, written in Bash
#
# Copyright (c) 2022 hinto.janaiyo <https://github.com/hinto-janaiyo>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# count and list wallet names
wallet::list() {
	log::debug "starting ${FUNCNAME}()"

	# GET WALLETS
	char WALLET_LIST_ALL
	local WALLET_COUNT WALLET_LIST i
	WALLET_LIST_ALL=("$(ls "$WALLETS" | grep -v ".keys")")
	WALLET_COUNT="$(echo "${WALLET_LIST_ALL[@]}" | wc -l)"

	# MAKE WALLET LIST []
	for i in ${WALLET_LIST_ALL[@]}; do
		WALLET_LIST="[${i}]  $WALLET_LIST"
	done

	# PRINT WALLET COUNT
	printf "${BWHITE}%s${OFF}" "$WALLET_COUNT "
	if [[ $WALLET_COUNT = 1 ]]; then
		printf "%s\n" "wallet found"
	else
		printf "%s\n" "wallets found"
	fi

	# PRINT WALLET LIST
	if [[ $WALLET_COUNT = 0 ]]; then
		echo
	else
		printf "${BWHITE}%s${OFF}\n\n" "$WALLET_LIST"
	fi

	return 0
}