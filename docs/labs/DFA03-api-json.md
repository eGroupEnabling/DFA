## DFA03: Parse JSON from a Public API into OneLake

**Objective**: Pull external JSON into OneLake and create a basic recommendations
query pattern for item search.

**Public API endpoint**:

- `https://dummyjson.com/products?limit=30&select=id,title,category,description,price,rating,stock,brand`

**Assets used**:

- `samples/labs/DFA03-products.json` (snapshot pulled from the DummyJSON endpoint)

**Estimated time**: 35-45 minutes

### Steps

1. In your Fabric workspace, create a **Notebook** from your **Lakehouse**.

2. In a Python cell, paste this code and select **Run all** to retrieve and parse the API JSON:
   ```python
   import requests

   url = (
       "https://dummyjson.com/products"
       "?limit=30&select=id,title,category,description,price,rating,stock,brand"
   )

   response = requests.get(url, timeout=30)
   response.raise_for_status()

   (
      spark.createDataFrame(response.json()["products"])
      .selectExpr(
         "cast(id as int) as item_id",
         "title as item_name",
         "category",
         "description",
         "cast(price as double) as price",
         "cast(rating as double) as rating",
         "cast(stock as int) as stock",
         "brand",
      )
      .write.mode("overwrite")
      .format("delta")
      .saveAsTable("products_curated")
   )
   ```

   Use the repository snapshot `samples/labs/DFA03-products.json` as a fallback
   source if the API is unavailable. The snapshot uses the same top-level
   `products` array as the live API response.

3. Go back to the **Lakehouse**, and validate table creation in the **SQL endpoint** with these queries:
   ```sql
   SELECT COUNT(*) AS ProductCount FROM dbo.products_curated;

   SELECT TOP 10 * FROM dbo.products_curated ORDER BY rating DESC, stock DESC;
   ```

4. Create item search query (keyword + category):
   ```sql
   DECLARE @searchTerm NVARCHAR(100) = 'beauty';

   SELECT TOP 20
       item_id,
       item_name,
       category,
       brand,
       price,
       rating,
       stock
   FROM dbo.products_curated
   WHERE LOWER(item_name) LIKE '%' + LOWER(@searchTerm) + '%'
      OR LOWER(category) LIKE '%' + LOWER(@searchTerm) + '%'
      OR LOWER(COALESCE(brand, '')) LIKE '%' + LOWER(@searchTerm) + '%'
   ORDER BY rating DESC, stock DESC, price ASC;
   ```

5. Create basic recommendations query (same category + similar price):
   ```sql
   DECLARE @seedItemId INT = 1;

   WITH seed AS (
       SELECT item_id, category, price
       FROM dbo.products_curated
       WHERE item_id = @seedItemId
   )
   SELECT TOP 10
       p.item_id,
       p.item_name,
       p.category,
       p.brand,
       p.price,
       p.rating,
       p.stock,
       ABS(p.price - s.price) AS price_distance
   FROM dbo.products_curated p
   CROSS JOIN seed s
   WHERE p.item_id <> s.item_id
     AND p.category = s.category
   ORDER BY price_distance ASC, p.rating DESC, p.stock DESC;
   ```

6. Go back to the **Notebook** and add new Python cells for AI-assisted product
   copy. Update the prompt text in each example if you'd like before you run it.

   Example 1: Featured-product campaign copy.
   ```python
   import synapse.ml.spark.aifunc as aifunc

   prompt = (
      "Write one summer-sale subject line under 9 words. Use the product name, "
      "mention the brand only if useful, and invent nothing."
   )

   display(
      spark.sql("""
      SELECT item_name, category, COALESCE(brand, 'Unbranded') AS brand
      FROM products_curated
      ORDER BY rating DESC, stock DESC
      LIMIT 5
      """)
      .ai.generate_response(prompt=prompt, output_col="subject_line")
      .select("item_name", "brand", "subject_line")
   )
   ```

   Example 2: Recommendation copy.
   ```python
   import synapse.ml.spark.aifunc as aifunc

   prompt = (
      "In two sentences, explain why the recommended item fits the original. "
      "Use category, price, and rating only. Invent nothing."
   )

   display(
      spark.sql("""
      WITH seed AS (
         SELECT item_name, category, price
         FROM products_curated
         WHERE item_id = 1
      )
      SELECT
         s.item_name AS seed_item,
         p.item_name AS recommended_item,
         COALESCE(p.brand, 'Unbranded') AS brand,
         p.category,
         p.price,
         p.rating,
         ABS(p.price - s.price) AS price_distance
      FROM products_curated p
      CROSS JOIN seed s
      WHERE p.item_id <> 1
       AND p.category = s.category
      ORDER BY price_distance ASC, p.rating DESC, p.stock DESC
      LIMIT 5
      """)
      .ai.generate_response(prompt=prompt, output_col="why_it_matches")
      .select(
         "seed_item", "recommended_item", "brand", "why_it_matches"
      )
   )
   ```

### Success Criteria

- API JSON is persisted in OneLake table `products_curated`.
- Search and recommendation queries return relevant products.
- The notebook generates row-level AI output for products from `products_curated`.

### Extra Credit

- Apply this notebook pattern to DFA01 and DFA02.
- Use AI functions to summarize, classify, extract, or draft outputs.
