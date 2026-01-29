package online_boutique

import (
	gsl "greymatter.io/gsl/spec/v1"
	"online-boutique.module/greymatter:globals"
)

frontend: gsl.#Service & {
	context: frontend.#NewContext & globals

	name:            "frontend"
	display_name:    "Online Boutique Frontend"
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
		"frontend": {
			gsl.#HTTPListener
			gsl.#SpireListener & {
				#context: context.SpireContext
				#subjects: ["online-boutique-edge"]
			}

			routes: {
				"/": {
					upstreams: {
						"127.0.0.1:8080": {
							gsl.#Upstream

							instances: [
								{
									host: "127.0.0.1"
									port: 8080
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
		"health-probes": {
			gsl.#HTTPListener
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
							instances: [
								{
									host: "127.0.0.1"
									port: 8080
								},
							]
						}
					}
				}
			}
		}
	edge: {
		edge_name: "edge"
		routes: {
			"/": {
				prefix_rewrite: "/"

				upstreams: {
					"frontend": {
						gsl.#Upstream
						gsl.#SpireUpstream & {
							#context: {
								globals.globals
								service_name: "edge"
							}

							#subjects: ["online-boutique-frontend"]
						}

						namespace:       "online-boutique"
						target_listener: "frontend"
					}
				}
			}
		}
	}

	egress: {
		"adservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"adservice:9555",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"adservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-adservice"]
							}

							namespace:       "online-boutique"
							target_listener: "adservice"
						}
					}
				}
			}
		}

		"cartservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"cartservice:7070",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"cartservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-cartservice"]
							}

							namespace:       "online-boutique"
							target_listener: "cartservice"
						}
					}
				}
			}
		}

		"productcatalogservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"productcatalogservice:3550",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"productcatalogservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-productcatalogservice"]
							}

							namespace:       "online-boutique"
							target_listener: "productcatalogservice"
						}
					}
				}
			}
		}

		"recommendationservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"recommendationservice:8080",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"recommendationservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-recommendationservice"]
							}

							namespace:       "online-boutique"
							target_listener: "recommendationservice"
						}
					}
				}
			}
		}

		"currencyservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"currencyservice:7000",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"currencyservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-currencyservice"]
							}

							namespace:       "online-boutique"
							target_listener: "currencyservice"
						}
					}
				}
			}
		}

		"checkoutservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"checkoutservice:5050",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"checkoutservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-checkoutservice"]
							}

							namespace:       "online-boutique"
							target_listener: "checkoutservice"
						}
					}
				}
			}
		}

		"shippingservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"shippingservice:50051",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"shippingservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-shippingservice"]
							}

							namespace:       "online-boutique"
							target_listener: "shippingservice"
						}
					}
				}
			}
		}

		"paymentservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"paymentservice:50051",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"paymentservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-paymentservice"]
							}

							namespace:       "online-boutique"
							target_listener: "paymentservice"
						}
					}
				}
			}
		}

		"emailservice": {
			gsl.#AutoEgressListener
			gsl.#HTTP2Listener

			custom_headers: [
				{
					key:   "x-forwarded-proto"
					value: "https"
				},
			]

			domains: [
				"emailservice:5000",
			]

			routes: {
				"/": {
					prefix_rewrite: "/"

					upstreams: {
						"emailservice": {
							gsl.#Upstream
							gsl.#HTTP2Upstream
							gsl.#SpireUpstream & {
								#context: context.SpireContext
								#subjects: ["online-boutique-emailservice"]
							}

							namespace:       "online-boutique"
							target_listener: "emailservice"
						}
					}
				}
			}
		}
	}
}

exports: "frontend": frontend
