package online_boutique

import (
	gsl "greymatter.io/gsl/spec/v1"
	"online-boutique.module/greymatter:globals"
)

paymentservice: gsl.#Service & {
	context: paymentservice.#NewContext & globals

	name:            "paymentservice"
	display_name:    "Online Boutique Paymentservice"
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
		"paymentservice": {
			gsl.#HTTPListener
			gsl.#HTTP2Listener
			gsl.#SpireListener & {
				#context: context.SpireContext
				#subjects: ["online-boutique-checkoutservice", "online-boutique-frontend"]
			}

			routes: {
				"/": {
					upstreams: {
						"127.0.0.1:50051": {
							gsl.#Upstream
							gsl.#HTTP2Upstream

							instances: [
								{
									host: "127.0.0.1"
									port: 50051
								},
							]
						}
					}
				}
			}
		}
		"health-probes": {
			gsl.#HTTPListener
			gsl.#GRPCListener
			port:10911
			// Mark the listener to remap container probes
			health_probes: {
				readiness: gsl.#ContainerProbe
				liveness:  gsl.#ContainerProbe
			}

			routes: {
				"/": {
					upstreams: {
						"health-probes": {
							gsl.#Upstream
							gsl.#GRPCUpstream
							instances: [
								{
									host: "127.0.0.1"
									port: 50051
								},
							]
						}
					}
				}
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

exports: "paymentservice": paymentservice
