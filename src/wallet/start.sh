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

# start monero-wallet-cli.
# called by: wallet::create()
#            wallet::select()
wallet::start() {
	log::debug "starting wallet: $WALLETS/$WALLET_SELECTION"

	# Check for Monero
	safety::pkg monero

	# Create files within /.monero-bash/export_import
	log::debug "cd'ing to $EXPORT_IMPORT for wallet files"
	cd "$EXPORT_IMPORT"

	# Auto-start monerod
	if [[ $AUTO_START_MONEROD = true ]]; then
		struct::pkg monero
		process::start
	fi

	___ENDOF___ERROR___TRACE___
	# Start monero-wallet-cli
	if "$PKG_MONERO/monero-wallet-cli" \
		--wallet-file "$WALLETS/$WALLET_SELECTION" \
		--config-file "$CONFIG_WALLET" \
		--password "$(crypto::decrypt "$WALLET_PASSWORD" "$(cat $CRYPTO_KEY)")"; then
		log::debug "monero-wallet-cli exit successfully"
	else
		local WALLET_ERROR=true
		print::error "monero-wallet-cli error has occurred"
	fi

	___BEGIN___ERROR___TRACE___
	# Auto-stop monerod
	if [[ $AUTO_STOP_MONEROD = true ]]; then
		struct::pkg monero
		process::stop
	fi

	[[ $WALLET_ERROR = true ]] && exit 1 || exit 0
}
