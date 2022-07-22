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

# message to print when [hash/gpg] is wrong
print::compromised::hash() {
	printf "${BWHITE}%s\n${BRED}%s\n${BRED}%s\n${BRED}%s\n${BRED}%s\n${BWHITE}%s\n" \
		"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" \
		" WARNING: HASH ERROR!                       " \
		" [${PKG[pretty]}] hash did not match!       " \
		" [${PKG[author]}] might be compromised!     " \
		" (or more likely, there was an error)       " \
		"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	printf "${BWHITE}%s${BBLUE}%s\n${BWHITE}%s${BRED}%s${OFF}\n" \
		"ONLINE HASH: " \
		"$HASH" \
		"LOCAL HASH: " \
		"$LOCAL_HASH"
	[[ $OPTION_VERBOSE = true ]] && print::verbose
	exit 1
}

print::compromised::gpg() {
	printf "${BWHITE}%s\n${BBLUE}%s\n${BBLUE}%s\n${BBLUE}%s\n${BBLUE}%s\n${BWHITE}%s\n" \
		"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@" \
		" WARNING: GPG ERROR!                       " \
		" [${PKG[pretty]}] GPG signature failed!     " \
		" [${PKG[gpg_owner]}] might be compromised!  " \
		" (or more likely, there was an error)       " \
		"@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
	printf "${BWHITE}%s${BBLUE}%s\n${BWHITE}%s${BRED}%s\n${BWHITE}%s${BYELLOW}%s\n${OFF}%s\n" \
		"ONLINE HASH: " \
		"$HASH" \
		"LOCAL HASH: " \
		"$LOCAL_HASH" \
		"GPG SIGNATURE: " \
		"$GPG_SIG"
	[[ $OPTION_VERBOSE = true ]] && print::verbose
	exit 1
}