# Armrest

[![BoltOps Badge](https://img.boltops.com/boltops/badges/boltops-badge.png)](https://www.boltops.com)

[![Gem Version](https://badge.fury.io/rb/armrest.svg)](https://badge.fury.io/rb/armrest)

A very lightweight Azure library that works with the [Azure REST API](https://docs.microsoft.com/en-us/rest/api/azure/), it is not meant to be exhaustive.

This was built because there doesn't seem to be a good library out there with the Azure features that [Terraspace](https://terraspace.cloud/) and [Terraspace Plugin Azurerm](https://github.com/boltops-tools/terraspace_plugin_azurerm) wanted to use:

* Auth Chain Provider: env vars -> MSI -> CLI creds. [#6](https://github.com/boltops-tools/terraspace_plugin_azurerm/issues/6)
* KeyVault secrets via the REST API

Also, the [Microsoft Azure SDK for Ruby library was deprecated as of Feb 2021](https://github.com/Azure/azure-sdk-for-ruby/blob/master/docs/README.md) and was officially retired. It's core library [ms_rest_azure.gemspec](https://github.com/Azure/azure-sdk-for-ruby/blob/master/runtime/ms_rest_azure/ms_rest_azure.gemspec#L39) have pinned versions of gems like faraday < 2, which causes gem dependency resolution issues.

This library also only makes use of the Ruby standard builtin net/http library so there's no dependency on faraday.

Again, this library has no goals of being extensive. Code generated SDKs is the approach that would take for that, but not dedicating the time to do that for this library.

## Usage: Ruby

Resource group:

```ruby
require "armrest"
resource_group = Armrest::Services::ResourceGroup.new
resource_group.create_or_update(
  name: "my-resource-group",
  location: "eastus",
  tags: {key1: "value1"},
)
```

Refer to the [boltops-tools/terraspace_plugin_azurerm](https://github.com/boltops-tools/terraspace_plugin_azurerm) for more examples.

## Usage: CLI

The main purpose of gem is to be a Ruby library that Terraspace can interact with. The CLI interface was only built to help quickly test the code with live resources. It's essentially a way to QA. Here are some examples:

Auth:

```shell
    armrest auth app
    armrest auth msi
    armrest auth cli
    armrest auth oidc
```

The auth chain is: app -> msi -> cli -> oidc

You can disable MSI with `ARMREST_DISABLE_MSI=1`, and you can also enable or disable OIDC explicitly using environment variables (`ARM_USE_OIDC` or `AZURE_USE_OIDC`).

### OIDC Authentication

The OIDC authentication provider allows you to authenticate using OpenID Connect tokens. This is particularly useful for environments like GitHub Actions or Azure DevOps pipelines.

#### Configuration

You can configure OIDC authentication using the following environment variables:

* `ARM_OIDC_TOKEN` or `AZURE_OIDC_TOKEN`: Directly provide the OIDC token.
* `ARM_OIDC_TOKEN_FILE_PATH` or `AZURE_OIDC_TOKEN_FILE_PATH`: Path to a file containing the OIDC token.
* `ACTIONS_ID_TOKEN_REQUEST_URL` and `ACTIONS_ID_TOKEN_REQUEST_TOKEN`: GitHub Actions OIDC credentials.
* `SYSTEM_OIDCREQUESTURI` and `SYSTEM_ACCESSTOKEN`: Azure DevOps OIDC credentials.

#### Example

To use OIDC authentication, set the required environment variables and run:

```shell
    armrest auth oidc
```

This will acquire an OIDC token and exchange it for an Azure access token.

Resource Group:

```shell
    armrest resource_group check_existence demo
```

Storage Account:

```shell
    armrest storage_account create demofoobar123v3 --tags name:bob age:8
```

Blob Service:

```shell
    armrest blob_service set_properties --storage-account demofoobar123 --delete-retention-policy days:9 enabled:true --container-delete-retention-policy days:10 enabled:true --is-versioning-enabled
```

Secret:

```shell
    $ export ARMREST_VAULT=demo-dev-vault-test1
    $ armrest secret show demo-dev-pass
    secret1
    $
```

## Installation

Add to your Gemfile

Gemfile

```shell
    gem "armrest"
```
