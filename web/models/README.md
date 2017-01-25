Overview
--------

These models are the interface to the underlying database. Currently all models are just Ecto schemas over a PostgreSQL database. Understanding the schemas and how they connect together is crucial to interacting with the database.


The current higher level connections are described in the model below:

```svgbob
                          +----------+
                          |  Region  |
                          +-----+----+
                                |
                                |
                                v 1
+------------+ +--------+ +-----------+ +--------------+
|  Allergen  | |  Diet  | |  Cuisine  | |  Ingredient  |
+----------+-+ +------+-+ +---+-------+ +-+------------+
           |          |       |           |
           .          |       |           .
            \         |       |          /
             \        |       |         /
              \       v M     v 1      /
               \  M +-------------+ M /
                .-->|  Item.Food  |<-.
                    +-------------+
```

An `Item.Food` can have many `Allergen`, `Diet`, and `Ingredient`, but only one `Cuisine`. These many relationships are exposed in `Item.Food.AllergenList`, `Item.Food.DietList`, and `Item.Food.IngredientList` respectively.

A `Cuisine` can have only one `Region`.


The above layout allows us to associate food with what allergies will be triggered from its consumption, what diets are allowed to consume it, what ingredients it consists of, and what style of cuisine it is. e.g. A plain pizza with ham might belong to the cuisine of type `Pizza` (which belongs to the regional style `Italian`), consists of the ingredients `mozzarella`, `ham`, `tomato sauce`, `flour`, `egg`, `yeast`, and so can't be eaten by people following any strict diet, or people with allergies to `gluten`, `egg`, and `meat`.
