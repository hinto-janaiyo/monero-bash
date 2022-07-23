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

# check for package version updates
pkg::update() {
	# VERBOSE MODE
	if [[ $OPTION_VERBOSE = true ]]; then
		STD_LOG_DEBUG=true
	fi

	log::debug "starting ${FUNCNAME}()"

	# CREATE TMP FILES AND LOCK
	trap 'pkg::tmp::remove; lock::free monero_bash_update' EXIT
	if ! lock::alloc "monero_bash_update"; then
		print::error "Could not get update lock!"
		print::exit  "Is there another [monero-bash] update running?"
	fi
	pkg::tmp::info

	# VARIABLE
	local UPDATE_FOUND INFO HTML
	declare -a SCRATCH

	# TITLE
	print::update

	# ALWAYS UPDATE MONERO-BASH
	struct::pkg bash
	log::debug "starting download thread for: ${PKG[pretty]}"
	# switch to html mode if github api fails
	if ! $DOWNLOAD_CMD "${TMP_INFO[bash]}" "${PKG[link_api]}"; then
		HTML_MODE=true
		printf "${BRED}%s${OFF}%s${BYELLOW}%s${OFF}\n" \
			"GitHub API failure " \
			"| " \
			"Switching to HTML filter mode..."
		if ! $DOWNLOAD_CMD "${TMP_INFO[bash]}" "${PKG[link_html]}"; then
			print::exit "Update failure - could not connect to GitHub"
		fi
	fi
	# filter result
	pkg::update::filter
	# print result and update state
	pkg::update::result

	# START MULTI-THREADED DOWNLOAD ON OTHER PACKAGES
	if [[ $MONERO_VER ]]; then
		struct::pkg monero
		pkg::update::multi
	fi
	if [[ $P2POOL_VER ]]; then
		struct::pkg p2pool
		pkg::update::multi
	fi
	if [[ $XMRIG_VER ]]; then
		struct::pkg xmrig
		pkg::update::multi
	fi

	# WAIT FOR THREADS
	local JOB_LIST=$(jobs -p)
	if [[ $JOB_LIST ]]; then
		log::debug "waiting for download threads to complete"
		if ! wait -n; then
			print::exit "Update failure - could not connect to GitHub"
		fi
	fi

	# FILTER RESULT AND PRINT
	if [[ $MONERO_VER ]]; then
		struct::pkg monero
		pkg::update::filter
		pkg::update::result
	fi
	if [[ $P2POOL_VER ]]; then
		struct::pkg p2pool
		pkg::update::filter
		pkg::update::result
	fi
	if [[ $XMRIG_VER ]]; then
		struct::pkg xmrig
		pkg::update::filter
		pkg::update::result
	fi

	# END
	if [[ $UPDATE_FOUND ]]; then
		echo
		printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}\n" \
			"Updates found, type: " \
			"[monero-bash upgrade] " \
			"to upgrade all packages"
		printf "${BWHITE}%s${BRED}%s${BWHITE}%s${OFF}\n" \
			"Or type: " \
			"[monero-bash <package>] " \
			"to upgrade a specific package"
	else
		print::updated
	fi

	log::debug "update() finished"
	exit 0
}

# a template for multi-threaded updates
# uses struct::pkg to determine package
pkg::update::multi() {
	log::debug "starting download thread for: ${PKG[pretty]}"
	# api/html
	if [[ $HTML_MODE = true ]]; then
		$DOWNLOAD_CMD "${TMP_INFO[${PKG[name]}]}" "${PKG[link_html]}" &
	else
		$DOWNLOAD_CMD "${TMP_INFO[${PKG[name]}]}" "${PKG[link_api]}" &
	fi
	return 0
}

# a template for filtering output
# of the info file created by pkg::update::multi()
pkg::update::filter() {
	if [[ $HTML_MODE = true ]]; then
		SCRATCH=($(grep -o -m 1 "/${PKG[author]}/${PKG[name]}/releases/tag/.*\"" "${TMP_INFO[${PKG[name]}]}"))
		INFO="${SCRATCH[0]}"
		INFO="${INFO//*tag\/}"
		INFO="${INFO//\"}"
	else
		INFO="$(grep -m1 "tag_name" "${TMP_INFO[${PKG[name]}]}")"
		INFO="${INFO//*: }"
		INFO="${INFO//\"}"
		INFO="${INFO//,}"
	fi
	return 0
}

# a template for printing the result
# of pkg::update::filter()
pkg::update::result() {
	# case formatting of package name
	local UPDATE_NAME
	case "${PKG[name]}" in
		*bash*) UPDATE_NAME="monero-bash | ";;
		monero) UPDATE_NAME="Monero      | ";;
		*p2p*)  UPDATE_NAME="P2Pool      | ";;
		*xmr*)  UPDATE_NAME="XMRig       | ";;
	esac
	# print result and update state
	if [[ ${PKG[current_version]} = "${INFO}" ]]; then
		printf "${BWHITE}%s${BGREEN}%s\n" \
			"$UPDATE_NAME" "${PKG[current_version]}"
	else
		sed -i "s/${PKG[var]}_OLD=.*/${PKG[var]}_OLD=true/" "$STATE"
		UPDATE_FOUND=true
		printf "${BWHITE}%s${BRED}%s${BWHITE}%s${BGREEN}%s\n" \
			"$UPDATE_NAME" "${PKG[current_version]} " "-> " "$INFO"
	fi
	return 0
}