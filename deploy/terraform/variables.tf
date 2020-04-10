variable "cluster-name"{
    default ="{CLUSTER_NAME}"
}
variable "cluster-description"{
    default ="{CLUSTER_DESCRIPTION}"
}
variable "project"{
    default ="{PROJECT_ID}"
}
variable "region"{
    default ="{REGION}"
}
variable "zone"{
    default ="{REGION}-c"
}
variable "node_count"{
    default =1
}
variable "machine_type"{
    default ="n1-standard-1"
}