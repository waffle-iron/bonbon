# This script handles anything required when generating documentation
# for the project.

Application.ensure_all_started(:simple_markdown_extension_svgbob)


defmodule Documentation do
    require SimpleMarkdownExtensionHighlightJS

    SimpleMarkdownExtensionHighlightJS.impl_renderers
end
