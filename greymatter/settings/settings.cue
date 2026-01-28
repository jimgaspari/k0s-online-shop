package settings

import (
	gsl "greymatter.io/gsl/spec/v1"
)

project: gsl.#Project & {
	tcm: gsl.#GreymatterService & {
		log_level: "info"
		containers: {
			"greymatter-tcm": {
				resources: {
					requests: {
						cpu:    "100m"
						memory: "128Mi"
					}
					limits: {
						cpu:    "1"
						memory: "2Gi"
					}
				}
			}
			"greymatter-sidecar": {
				resources: {
					requests: {
						cpu:    "100m"
						memory: "128Mi"
					}
					limits: {
						cpu:    "200m"
						memory: "200Mi"
					}
				}
			}
		}
	}

	epo: gsl.#GreymatterService & {
		log_level: "info"
		replicas:  1
		containers: {
			"greymatter-epo": {
				resources: {
					requests: {
						cpu:    "10m"
						memory: "10Mi"
					}
					limits: {
						cpu:    "1"
						memory: "2Gi"
					}
				}
			}
		}
	}

	spo: gsl.#GreymatterService & {
		log_level: "info"
		replicas:  1
		containers: {
			"greymatter-spo": {
				resources: {
					requests: {
						cpu:    "10m"
						memory: "10Mi"
					}
					limits: {
						cpu:    "1"
						memory: "2Gi"
					}
				}
			}
		}
	}
}
