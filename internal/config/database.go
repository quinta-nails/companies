package config

import "net/url"

type DatabaseConfig struct {

	// URL is the configuration field for the database URL. It is used by the DatabaseConfig struct
	// to define the URL for the database connection. The URL is fetched from the environment variable
	// DATABASE_URL, and if not found, it falls back to the default value:
	// "postgres://postgres:postgres@localhost:5432/users?sslmode=disable".
	URL url.URL `env:"DATABASE_URL,required" envDefault:"postgres://postgres:postgres@localhost:5432/users?sslmode=disable"`
}
