## Examples

    armrest completion

Prints words for TAB auto-completion.

    armrest completion
    armrest completion hello
    armrest completion hello name

To enable, TAB auto-completion add the following to your profile:

    eval $(armrest completion_script)

Auto-completion example usage:

    armrest [TAB]
    armrest hello [TAB]
    armrest hello name [TAB]
    armrest hello name --[TAB]
