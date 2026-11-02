tofu *args:
    sops exec-env tofu/secrets.sops.env 'tofu -chdir=tofu {{args}}'
