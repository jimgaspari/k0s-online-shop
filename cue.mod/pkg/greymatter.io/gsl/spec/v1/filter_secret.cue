package v1

#FilterSecret: {
	type:   string
	filter: string
	path:   string

	(#KubernetesSecret | #VaultSecret)
}

#KubernetesSecret: {
	type:   "kubernetes"
	filter: string
	path:   string

	namespace: string
	name:      string
	key:       string
}

#VaultSecret: {
	type:   "vault"
	filter: string
	path:   string

	vaultPath: string
	mountPath: string
	key:       string
	version:   int | *-1
}
