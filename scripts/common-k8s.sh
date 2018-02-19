#! /bin/bash

# K8s helpers
function delete_pod() {
  pod=${1}

  kubectl delete pod ${pod}
}

function exec_in_pod() {
  pod=${1}
  shift
  cmd=${@}

  kubectl exec ${pod} -it -- ${cmd}
}

function find_pod() {
  name=${1}
  pod=$(kubectl get pods -l app=${name} -o jsonpath='{.items[0].metadata.name}')

  echo ${pod}
}
