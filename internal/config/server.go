package config

type ServerConfig struct {

	// Port represents the port number on which the server is listening.
	// It is an unsigned integer of 16 bits (uint16).
	// The value of the port can be set using the environment variable PORT.
	// If the environment variable is not set, the default value is 51051.
	Port uint16 `env:"PORT,required" envDefault:"51051"`
}
