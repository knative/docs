## Verifying Images

Knative releases from 1.8 onwards are signed with [cosign](https://docs.sigstore.dev/cosign/overview).

- **Verifying Images Signatures**

```
# install cosign and jq  if you don't have it

# download the yaml file, this example uses the serving manifest
curl -fsSLO https://github.com/knative/serving/releases/download/knative-v1.8.0/serving-core.yaml
cat serving-core.yaml | grep 'gcr.io/' | awk '{print $2}' > images.txt
input=images.txt
while IFS= read -r image
do
  COSIGN_EXPERIMENTAL=1 cosign verify "$image" | jq
done < "$input"

kubectl apply -f serving-core.yaml
```
