package db

import (
	"database/sql"
	"github.com/caarlos0/env/v11"
	"github.com/quinta-nails/companies/internal/config"
)

func NewDB() (*Queries, error) {
	cfg := config.DatabaseConfig{}
	if err := env.Parse(&cfg); err != nil {
		return nil, err
	}

	db, err := sql.Open("postgres", cfg.URL.String())
	if err != nil {
		return nil, err
	}

	err = db.Ping()
	if err != nil {
		return nil, err
	}

	return New(db), nil

}
