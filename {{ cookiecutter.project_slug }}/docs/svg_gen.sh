#/usr/bin/env bash

# Color Credits: https://tailwindcolor.com

pushd docs

for file in $(fd -i -e md); do
  pnpx @mermaid-js/mermaid-cli mmdc --input "${file}" --output "out/${file}.svg"
done

popd