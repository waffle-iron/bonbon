defmodule Bonbon.Model.Item.Food.Content.TranslationTest do
    use Bonbon.TranslationCase, field: [
        name: [type: :string],
        description: [type: :string]
    ]
end
