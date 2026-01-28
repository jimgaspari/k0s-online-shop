package network

#ObservablesTCPConfig: {
	// Whether to emit response (or otherwise just request)
	emitFullResponse?: bool
	// The topic name to embed in the event.
	topic?: string
	// File to store event to use (if not using Kafka)
	fileName?: string
	// Log level to use ("warn", "debug" or "info")
	logLevel?: string
	// Algorithm used to encrypt
	encryptionAlgorithm?: string
	// Key to encrypt event
	encryptionKey?:   string
	encryptionKeyID?: uint32
	// Decode
	decodeToProtocol?: string
	decodeSkipFail?:   bool
	// NATS publishing configuration
	streamName?:      string
	retentionPolicy?: string
	servers?: [...string]
	maxMessages?:      int32
	duplicateWindows?: int32
	rollingFileConfig?: #RollingFileConfig
	msTimestampEnabled?: bool
}

#RollingFileConfig: {
	maxFileSize?:    int32
	maxFileBackups?: int32
	maxAgeInDays?:   int32
	compressFile?:   bool
}
