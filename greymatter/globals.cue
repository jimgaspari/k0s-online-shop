package globals

import (
	gsl "greymatter.io/gsl/spec/v1"
)

globals: gsl.#DefaultContext & {
	edge_host: ""
	namespace: "online-boutique"

	mesh: {
		name: string
	}
}
