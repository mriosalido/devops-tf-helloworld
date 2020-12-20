terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {}

resource "kubernetes_deployment" "helloworld" {
  metadata {
    name = "helloworld"
    labels = {
      App = "HelloWorld"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "HelloWorld"
      }
    }
    template {
      metadata {
        labels = {
          App = "HelloWorld"
        }
      }
      spec {
        container {
          image = "mrv-helloworld:0"
          name  = "helloworld"

          port {
            container_port = 8080
          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "50m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "helloworld" {
  metadata {
    name = "helloworld"
  }
  spec {
    selector = {
      App = kubernetes_deployment.helloworld.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_horizontal_pod_autoscaler" "helloworld" {
  metadata {
    name = "helloworld"
  }

  spec {
    min_replicas = 2
    max_replicas = 10
    target_cpu_utilization_percentage = 15

    scale_target_ref {
      api_version = "apps/v1"
      kind = "Deployment"
      name = "helloworld"
    }

  }
}
