package online_boutique

import (
	gsl "greymatter.io/gsl/spec/v1"
	"online-boutique.module/greymatter:globals"
)

edge: gsl.#Edge & {
	context: edge.#NewContext & globals

	name:            "edge"
	display_name:    "Online Boutique Edge"
	version:         "v2.4.0-beta.2"
	description:     "No description"
	business_impact: "high"
	owner:           "online-boutique"
	capability:      ""
	api_endpoint:    ""

	resources: gsl.#ResourceQuotas & {
		requests: {
			cpu:    "100m"
			memory: "128Mi"
		}
		limits: {
			cpu:    "300m"
			memory: "1000Mi"
		}
	}

	gateways: [
		gsl.#LoadBalancer & {
			targetListeners: [
				{name: "edge", exposedPort: 443},
			]
		},
	]

	ingress: {
		"edge": {
			gsl.#HTTPListener
			gsl.#TLSListener

			filters: [
				gsl.#DefaultWaf,
			]
		}

		"service-info": gsl.#ServiceInfo & {
			gsl.#SpireListener & {
				#context: context.SpireContext
				#subjects: ["prometheus"]
			}
		}
	}
}

exports: "edge": edge
