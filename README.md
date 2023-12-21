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

The main purpose of gem is to be a Ruby library that Terraspace can interact with.  The CLI interface was only built to help quickly test the code with live resources. It's essentially a way to QA.  Here are some examples:

Auth:

    armrest auth app
    armrest auth msi
    armrest auth cli

The auth chain is: app -> msi -> cli

    armrest auth

You can disable MSI with `ARMREST_DISABLE_MSI=1`.

Resource Group:

    armrest resource_group check_existence demo

Storage Account:

    armrest storage_account create demofoobar123v3 --tags name:bob age:8

Blob Service:

    armrest blob_service set_properties --storage-account demofoobar123 --delete-retention-policy days:9 enabled:true --container-delete-retention-policy days:10 enabled:true --is-versioning-enabled

Secret:

    $ export ARMREST_VAULT=demo-dev-vault-test1
    $ armrest secret show demo-dev-pass
    secret1
    $

## Installation

Add to your Gemfile

Gemfile

    gem "armrest"
