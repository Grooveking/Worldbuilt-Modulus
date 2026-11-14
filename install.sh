#!/bin/bash -xe
if ! command -v pwsh >/dev/null 2>&1; then
	echo "Powershell is not installed but is required!"
	echo "Install powershell before running this file"
	echo "Press any key to exit..."
	IFS= read -rsn1
	echo "\n"
	exit 1
fi

cd "$(dirname "$0")/installer"
pwsh ./install.ps1
