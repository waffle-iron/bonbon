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

An `Item.Food` can have many `Allergen`, `Diet`, and `Ingredient`, but only one `Cuisine`.

A `Cuisine` can have only one `Region`.
