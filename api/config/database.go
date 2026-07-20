package config

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/go-sql-driver/mysql"
)

func ConnectDB() *sql.DB {
	// Menghubungkan ke port custom 3309 dengan user non-root
	dbUser := "pusdat_usr"
	dbPass := "]:BnY-0726*Ba.!"
	//dbUser := "root"
	//dbPass := ""
	dbHost := "127.0.0.1"
	dbPort := "3306"
	dbName := "pusdat_db"

	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true", dbUser, dbPass, dbHost, dbPort, dbName)
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		log.Fatalf("Gagal inisialisasi database: %v", err)
	}

	if err := db.Ping(); err != nil {
		log.Fatalf("Database tidak merespon: %v", err)
	}

	// Security Tuning Connection Pool
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(5)

	return db
}
