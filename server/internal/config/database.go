package config

import (
	"net/url"
	"os"
	"strings"
)

const localDefaultDatabaseURL = "postgres://multica:multica@localhost:5432/multica?sslmode=disable"

// DatabaseURL returns the database connection URL and normalizes sslmode when needed.
func DatabaseURL() string {
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		return localDefaultDatabaseURL
	}

	sslMode := strings.TrimSpace(os.Getenv("DATABASE_SSLMODE"))
	if sslMode == "" && isRailwayEnvironment() {
		sslMode = "require"
	}
	if sslMode == "" {
		return dbURL
	}

	parsed, err := url.Parse(dbURL)
	if err != nil {
		return dbURL
	}

	q := parsed.Query()
	if q.Get("sslmode") != "" {
		return dbURL
	}
	q.Set("sslmode", sslMode)
	parsed.RawQuery = q.Encode()
	return parsed.String()
}

func isRailwayEnvironment() bool {
	return os.Getenv("RAILWAY_ENVIRONMENT") != "" || os.Getenv("RAILWAY_PROJECT_ID") != ""
}
