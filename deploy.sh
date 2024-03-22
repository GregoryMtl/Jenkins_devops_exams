helm uninstall "jenkinsexam" -n dev
helm upgrade --install jenkinsexam ./helm  --values=./helm/values.yaml --create-namespace --namespace dev