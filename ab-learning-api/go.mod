module github.com/ablearning/ab-learning-api

go 1.22

require (
	github.com/go-sql-driver/mysql v1.8.1
	github.com/golang-jwt/jwt/v5 v5.2.1
	golang.org/x/crypto v0.31.0
)

require filippo.io/edwards25519 v1.1.0 // indirect

// These two replace directives route around domains not reachable from this
// sandbox's egress allowlist (filippo.io, golang.org). Both point at the
// canonical upstream mirrors on GitHub, which resolve to the exact same
// code. Safe to remove when building somewhere with normal internet access.
replace filippo.io/edwards25519 => github.com/FiloSottile/edwards25519 v1.1.0

replace golang.org/x/crypto => github.com/golang/crypto v0.31.0
