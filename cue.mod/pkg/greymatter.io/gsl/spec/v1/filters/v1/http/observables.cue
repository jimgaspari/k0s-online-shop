package http

#ObservablesConfig: {
	emitFullResponse?:    bool
	topic?:               string
	fileName?:            string
	logLevel?:            string
	encryptionAlgorithm?: string
	// Bas64 encrypted bytes
	encryptionKey?:   string
	encryptionKeyID?: uint32
	// NATS publishing configuration
	streamName?:      string
	retentionPolicy?: string
	servers?: [...string]
	maxMessages?:      int32
	duplicateWindows?: int32
	rollingFileConfig?: #RollingFileConfig
	msTimestampEnabled?: bool
}

#ObservablesRouteConfig: {
	emitFullResponse?: bool
}

#RollingFileConfig: {
	maxFileSize?:    int32
	maxFileBackups?: int32
	maxAgeInDays?:   int32
	compressFile?:   bool
}
