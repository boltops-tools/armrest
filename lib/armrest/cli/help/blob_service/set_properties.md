## Examples

    export STORAGE_ACCOUNT=mystorageaccount
    armrest blob_service set_properties --storage-account $STORAGE_ACCOUNT --delete-retention-policy days:7 enabled:true --container-delete-retention-policy days:8 enabled:true
