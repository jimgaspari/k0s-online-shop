package online_boutique

import (
	gsl "greymatter.io/gsl/spec/v1"
	"online-boutique.module/greymatter:globals"
)

redis_cart: gsl.#Service & {
	context: redis_cart.#NewContext & globals

	name:            "redis-cart"
	display_name:    "Online Boutique Redis Cart"
	version:         "v1.0.0"
	description:     "No description"
	business_impact: "low"
	owner:           "online-boutique"
	capability:      ""
	api_endpoint:    ""

	resources: gsl.#ResourceQuotas & {
		requests: {
			cpu:    "100m"
			memory: "128Mi"
		}
		limits: {
			cpu:    "200m"
			memory: "200Mi"
		}
	}

	ingress: {
		"redis-cart": {
			gsl.#TCPListener
			gsl.#SpireListener & {
				#context: context.SpireContext
				#subjects: ["online-boutique-cartservice"]
			}

			upstream: {
				gsl.#Upstream

				name: "127.0.0.1:6379"

				instances: [
					{
						host: "127.0.0.1"
						port: 6379
					},
				]
			}
		}
		"redis-cart": {
			gsl.#TCPListener
			port: 10911
			health_probes: {
				readiness: gsl.#ContainerProbe
				liveness:  gsl.#ContainerProbe
			}
			upstream: {
				gsl.#Upstream

				name: "127.0.0.1:6379"

				instances: [
					{
						host: "127.0.0.1"
						port: 6379
					},
				]
			}
		}
		"service-info": gsl.#ServiceInfo & {
			gsl.#SpireListener & {
				#context: context.SpireContext
				#subjects: ["prometheus"]
			}
		}
	}
}

exports: "redis-cart": redis_cart
