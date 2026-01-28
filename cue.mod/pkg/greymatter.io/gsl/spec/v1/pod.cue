package v1

#PodSpec: {

	// Optional annotations and labels for the defined edge
	metadata?: #Metadata

	selectorMatchExpressions?: [...#LabelSelectorRequirement]

	// Any additional environment variables to configure on the edge.
	// These may be individual values, or all the key-value pairs from a ConfigMap or Secret
	// Will take precedence over default configured env vars
	env?: [...#EnvironmentVariable]

	// Optional override of the image path to use for the edge.
	image?: string

	// Optional override of the image pull secret to use for the image.
	imagePullSecret?: string

	// Any specific volumes to include in the defined edge. Will take precedence over default
	// configured volumes
	volumes?: [...#Volume]

	volumeMounts?: [...#VolumeMount]

	// Defines how many instances of this edge must be deployed.
	replicas: int | *1

	// Optional resource quota settings for edge replicas.
	// Each replica will have these resource limits applied.
	resources?: #ResourceQuotas
}

#ResourceQuotas: {
	requests: {
		cpu?:    string
		memory?: string
	}
	limits: {
		cpu?:    string
		memory?: string
	}
}

#Metadata: {
	annotations?: [string]: string
	labels?: [string]:      string
}

#LabelSelectorRequirement: {
	key:      string
	operator: "In" | "NotIn" | "Exists" | "DoesNotExist"
	values?: [...string]
}

#EnvironmentVariable: {
	name?: string
	{value: string} | {valueFrom: #ValueFrom}
}

// See https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.31/#envvarsource-v1-core
#ValueFrom: {
	#ConfigMapKeyRef | #FieldRef | #ResourceFieldRef | #SecretKeyRef
}

// Selects a key of a ConfigMap
#ConfigMapKeyRef: {
	configMapKeyRef: {
		key:       string
		name:      string
		optional?: bool
	}
}

// Selects a field of the pod
#FieldRef: {
	fieldRef: {
		apiVersion?: string
		fieldPath:   string
	}
}

// Selects a resource of the container
#ResourceFieldRef: {
	resourceFieldRef: {
		containerName?: string
		divisor?:       uint
		resource:       string
	}
}

// Selects a key of a secret in the pod's namespace
#SecretKeyRef: {
	secretKeyRef: {
		key:       string
		name:      string
		optional?: bool
	}
}

#Volume: {
	name:         string
	mountPath?:   string
	readOnly?:    bool
	subPath?:     string
	subPathExpr?: string
	#CSI | #ConfigMapVolume | #HostPath | #PersistentVolumeClaim | #SecretVolume | #EmptyDirVolume
}

#ConfigMapVolume: {
	configMap: {
		defaultMode?: int
		items?: [...{key: string, path: string, mode?: int}]
		name:      string
		optional?: bool
	}
}

#CSI: {
	csi: {
		driver:            string
		fsType?:           string
		readOnly?:         bool
		volumeAttributes?: _
		nodePublishSecretRef?: {name: string}
	}
}

#HostPath: {
	hostPath: {
		path:  string
		type?: string
	}
}

#PersistentVolumeClaim: {
	persistentVolumeClaim: {
		claimName: string
		readOnly?: bool
	}
}

#SecretVolume: {
	secret: {
		defaultMode?: int
		items?: [...{key: string, path: string, mode?: int}]
		secretName: string
		optional?:  bool
	}
}

#EmptyDirVolume: {
	emptyDir: {
		medium?:    "Memory" | "Default"
		sizeLimit?: string
	}
}

// VolumeMount describes a mounting of a Volume within a container.
#VolumeMount: {
	// This must match the Name of a Volume.
	name: string

	// Mounted read-only if true, read-write otherwise (false or unspecified).
	// Defaults to false.
	// +optional
	readOnly?: bool

	// Path within the container at which the volume should be mounted.  Must
	// not contain ':'.
	mountPath: string

	// Path within the volume from which the container's volume should be mounted.
	// Defaults to "" (volume's root).
	// +optional
	subPath?: string

	// mountPropagation determines how mounts are propagated from the host
	// to container and the other way around.
	// When not set, MountPropagationNone is used.
	// This field is beta in 1.10.
	// +optional
	mountPropagation?: #MountPropagationMode

	// Expanded path within the volume from which the container's volume should be mounted.
	// Behaves similarly to SubPath but environment variable references $(VAR_NAME) are expanded using the container's environment.
	// Defaults to "" (volume's root).
	// SubPathExpr and SubPath are mutually exclusive.
	// +optional
	subPathExpr?: string
}

// MountPropagationMode describes mount propagation.
#MountPropagationMode:
	#MountPropagationNone |
	#MountPropagationHostToContainer |
	#MountPropagationBidirectional

// MountPropagationNone means that the volume in a container will
// not receive new mounts from the host or other containers, and filesystems
// mounted inside the container won't be propagated to the host or other
// containers.
// Note that this mode corresponds to "private" in Linux terminology.
#MountPropagationNone: "None"

// MountPropagationHostToContainer means that the volume in a container will
// receive new mounts from the host or other containers, but filesystems
// mounted inside the container won't be propagated to the host or other
// containers.
// Note that this mode is recursively applied to all mounts in the volume
// ("rslave" in Linux terminology).
#MountPropagationHostToContainer: "HostToContainer"

// MountPropagationBidirectional means that the volume in a container will
// receive new mounts from the host or other containers, and its own mounts
// will be propagated from the container to the host or other containers.
// Note that this mode is recursively applied to all mounts in the volume
// ("rshared" in Linux terminology).
#MountPropagationBidirectional: "Bidirectional"

// The below probe schemas mimic the kubernetes corev1.Probe structure:
// https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Probe
// These probes are set on listeners which signals to Greymatter that this "ingress" listener
// shall be used for health probing by the kubelet. 
// "exec" probes are not supported through listeners. 
// "httpGet", "tcpSocket", and "grpc" probe configurations are automatically
// derived from other sources of an ingress listener. 
#ContainerProbe: {
    initialDelaySeconds?: int
    terminationGracePeriodSeconds?: int
    periodSeconds?: int
    timeoutSeconds?: int
    failureThreshold?: int
    successThreshold?: int
}
