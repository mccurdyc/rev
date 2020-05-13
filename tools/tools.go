// +build tools
// credit: https://github.com/hashicorp/terraform/blob/master/tools/tools.go

package tools

import (
	_ "golang.org/x/tools/cmd/cover"
	_ "honnef.co/go/tools/cmd/staticcheck"
)
